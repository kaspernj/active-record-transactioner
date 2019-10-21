# rubocop:disable Naming/FileName
# rubocop:enable Naming/FileName

require "monitor"

class ActiveRecordTransactioner
  DEFAULT_ARGS = {
    call_args: [],
    call_method: :save!,
    transaction_method: :transaction,
    transaction_size: 1000,
    threadded: false,
    max_running_threads: 2,
    debug: false
  }.freeze

  EMPTY_ARGS = [].freeze

  ALLOWED_ARGS = DEFAULT_ARGS.keys

  def initialize(args = {})
    args.each_key { |key| raise "Invalid key: '#{key}'." unless ALLOWED_ARGS.include?(key) }

    @args = DEFAULT_ARGS.merge(args)
    parse_and_set_args
    detect_database_syntax

    return unless block_given?

    begin
      yield self
    ensure
      flush
      join if threadded?
    end
  end

  # Adds another model to the queue and calls 'flush' if it is over the limit.
  def save!(model)
    raise ActiveRecord::RecordInvalid, model unless model.valid?

    queue(model, type: :save!, validate: false)
  end

  def bulk_create!(model)
    attributes = model.attributes
    attributes.delete("id")
    attributes.delete("created_at")
    attributes.delete("updated_at")

    klass = model.class
    @bulk_creates[klass] ||= []
    @bulk_creates[klass] << attributes

    @count += 1
  end

  def update_columns(model, updates)
    queue(model, type: :update_columns, validate: false, method_args: [updates])
  end

  def update_column(model, column_name, new_value)
    update_columns(model, column_name => new_value) # rubocop:disable Rails/SkipsModelValidations
  end

  def destroy!(model)
    queue(model, type: :destroy!)
  end

  # Adds another model to the queue and calls 'flush' if it is over the limit.
  def queue(model, args = {})
    args[:type] ||= :save!

    @lock.synchronize do
      klass = model.class

      validate = args.key?(:validate) ? args[:validate] : true

      @lock_models[klass] ||= Monitor.new

      @models[klass] ||= []
      @models[klass] << {
        model: model,
        type: args.fetch(:type),
        validate: validate,
        method_args: args[:method_args] || EMPTY_ARGS
      }

      @count += 1
    end

    flush if should_flush?
  end

  # Flushes the specified method on all the queued models in a thread for each type of model.
  def flush
    wait_for_threads if threadded?

    @lock.synchronize do
      @bulk_creates.each do |klass, attribute_array|
        if threadded?
          bulk_insert_attribute_array_threadded(klass, attribute_array)
        else
          bulk_insert_attribute_array(klass, attribute_array)
        end
      end

      @models.each do |klass, models|
        next if models.empty?

        @models[klass] = []
        @count -= models.length

        if threadded?
          work_threadded(klass, models)
        else
          work_models_through_transaction(klass, models)
        end
      end
    end
  end

  # Waits for any remaining running threads.
  def join
    threads_to_join = @lock_threads.synchronize { @threads.clone }

    debug "Threads to join: #{threads_to_join}" if @debug
    threads_to_join.each(&:join)
  end

  def threadded?
    @args[:threadded]
  end

private

  def detect_database_syntax
    if postgres?
      @table_quote = '"'
      @column_quote = '"'
    else
      @table_quote = "`"
      @column_quote = "`"
    end
  end

  def parse_and_set_args
    @models = {}
    @bulk_creates = {}
    @threads = []
    @count = 0
    @lock = Monitor.new
    @lock_threads = Monitor.new
    @lock_models = {}
    @max_running_threads = @args[:max_running_threads].to_i
    @transaction_size = @args[:transaction_size].to_i
    @debug = @args[:debug]
  end

  def debug(str)
    print "{ActiveRecordTransactioner}: #{str}\n" if @debug # rubocop:disable Rails/Output
  end

  def postgres?
    ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
  end

  def wait_for_threads
    loop do
      debug "Running threads: #{@threads.length} / #{@max_running_threads}" if @debug

      if allowed_to_start_new_thread?
        break
      elsif @debug
        debug "Waiting for threads #{@threads.length} / #{@max_running_threads}"
      end

      sleep 0.2
    end

    debug "Done waiting." if @debug
  end

  def work_models_through_transaction(klass, models)
    debug "Synchronizing model: #{klass.name}"

    @lock_models[klass].synchronize do
      debug "Opening new transaction by using '#{@args[:transaction_method]}'." if @debug

      klass.__send__(@args[:transaction_method]) do
        work_models(models)
      end
    end
  end

  def work_models(models)
    debug "Going through models." if @debug
    models.each do |work|
      debug work if @debug

      work_type = work.fetch(:type)
      model = work.fetch(:model)

      if work_type == :save!
        validate = work.key?(:validate) ? work[:validate] : true
        model.save! validate: validate
      elsif work_type == :update_columns || work_type == :destroy!
        model.__send__(work_type, *work.fetch(:method_args))
      else
        raise "Invalid type: '#{work[:type]}'."
      end
    end

    debug "Done working with models." if @debug
  end

  def work_threadded(klass, models)
    @lock_threads.synchronize do
      @threads << Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          work_models_through_transaction(klass, models)
        end
      rescue StandardError => e
        puts e.inspect # rubocop:disable Rails/Output
        puts e.backtrace # rubocop:disable Rails/Output

        raise e
      ensure
        debug "Removing thread #{Thread.current.__id__}" if @debug
        @lock_threads.synchronize { @threads.delete(Thread.current) }

        debug "Threads count after remove: #{@threads.length}" if @debug
      end
    end

    debug "Threads-count after started to work: #{@threads.length}"
  end

  def should_flush?
    @count >= @transaction_size
  end

  def allowed_to_start_new_thread?
    @lock_threads.synchronize { return @threads.length < @max_running_threads }
  end

  def bulk_insert_attribute_array_threadded(klass, attribute_array)
    @lock_threads.synchronize do
      @threads << Thread.new do
        bulk_insert_attribute_array(klass, attribute_array)
      rescue StandardError => e
        puts e.inspect # rubocop:disable Rails/Output
        puts e.backtrace # rubocop:disable Rails/Output

        raise e
      ensure
        debug "Removing thread #{Thread.current.__id__}" if @debug
        @lock_threads.synchronize { @threads.delete(Thread.current) }

        debug "Threads count after remove: #{@threads.length}" if @debug
      end
    end
  end

  def bulk_insert_attribute_array(klass, attribute_array)
    sql = "INSERT INTO #{@table_quote}#{klass.table_name}#{@table_quote} ("

    first = true
    attribute_array.first.each_key do |key|
      if first
        first = false
      else
        sql << ", "
      end

      sql << "#{@column_quote}#{key}#{@column_quote}"
    end

    sql << ") VALUES ("

    first_insert = true
    attribute_array.each do |attributes|
      if first_insert
        first_insert = false
      else
        sql << "), ("
      end

      first_value = true
      attributes.each_value do |value|
        if first_value
          first_value = false
        else
          sql << ", "
        end

        sql << klass.connection.quote(value)
      end
    end

    sql << ")"

    klass.connection.execute(sql)

    @lock.synchronize do
      @count -= attribute_array.length
    end
  end
end
