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
  }

  EMPTY_ARGS = []

  ALLOWED_ARGS = DEFAULT_ARGS.keys

  def initialize(args = {})
    args.each_key { |key| raise "Invalid key: '#{key}'." unless ALLOWED_ARGS.include?(key) }

    @args = DEFAULT_ARGS.merge(args)
    parse_and_set_args

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

  def update_columns(model, updates)
    queue(model, type: :update_columns, validate: false, method_args: [updates])
  end

  def update_column(model, column_name, new_value)
    update_columns(model, column_name => new_value)
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

  def parse_and_set_args
    @models = {}
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
    print "{ActiveRecordTransactioner}: #{str}\n" if @debug
  end

  def wait_for_threads
    loop do
      debug "Running threads: #{@threads.length} / #{@max_running_threads}" if @debug
      if allowed_to_start_new_thread?
        break
      else
        debug "Waiting for threads #{@threads.length} / #{@max_running_threads}" if @debug
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
    end
  end

  def work_threadded(klass, models)
    @lock_threads.synchronize do
      @threads << Thread.new do
        begin
          ActiveRecord::Base.connection_pool.with_connection do
            work_models_through_transaction(klass, models)
          end
        rescue => e
          puts e.inspect
          puts e.backtrace

          raise e
        ensure
          debug "Removing thread #{Thread.current.__id__}" if @debug
          @lock_threads.synchronize { @threads.delete(Thread.current) }

          debug "Threads count after remove: #{@threads.length}" if @debug
        end
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
end
