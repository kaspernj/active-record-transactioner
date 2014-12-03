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

  ALLOWED_ARGS = DEFAULT_ARGS.keys

  def initialize(args = {})
    args.each { |key, val| raise "Invalid key: '#{key}'." unless ALLOWED_ARGS.include?(key) }

    @args = DEFAULT_ARGS.merge(args)
    parse_and_set_args

    if block_given?
      begin
        yield self
      ensure
        flush
        join
      end
    end
  end

  #Adds another model to the queue and calls 'flush' if it is over the limit.
  def save!(model)
    raise ActiveRecord::RecordInvalid, model unless model.valid?
    queue(model, type: :save!, validate: false)
  end

  def destroy!(model)
    queue(model, type: :destroy!)
  end

  #Adds another model to the queue and calls 'flush' if it is over the limit.
  def queue(model, args = {})
    args[:type] ||= :save!

    @lock.synchronize do
      klass = model.class

      @lock_models[klass] ||= Mutex.new
      @models[klass] ||= []
      @models[klass] << {model: model, type: args[:type]}
      @count += 1
    end

    flush if should_flush?
  end

  #Flushes the specified method on all the queued models in a thread for each type of model.
  def flush
    wait_for_threads if @args[:threadded]

    @lock.synchronize do
      @models.each do |klass, models|
        next if models.empty?

        @models[klass] = []
        @count -= models.length

        if @args[:threadded]
          work_threadded(klass, models)
        else
          work_models_through_transaction(klass, models)
        end
      end
    end
  end

  #Waits for any remaining running threads.
  def join
    @lock_threads.synchronize do
      @threads.each do |thread|
        thread.join
      end
    end
  end

private

  def parse_and_set_args
    @models = {}
    @threads = []
    @count = 0
    @lock = Monitor.new
    @lock_threads = Monitor.new
    @lock_models = {}

    if @args[:transaction_size]
      @transaction_size = @args[:transaction_size].to_i
    else
      @transaction_size = 1000
    end

    @debug = @args[:debug]
  end

  def debug(str)
    puts "{ActiveRecordTransactioner}: #{str}" if @debug
  end

  def wait_for_threads
    break_loop = false
    while !break_loop
      debug "Trying to lock..." if @debug
      @lock.synchronize do
        debug "Running threads: #{@threads.length} / #{@args[:max_running_threads]}"
        if @threads.length < @args[:max_running_threads]
          break_loop = true
        else
          debug "Waiting for threads #{@threads.length} / #{@args[:max_running_threads]}" if @debug
        end
      end

      sleep 0.2 unless break_loop
    end

    debug "Done waiting." if @debug
  end

  def work_models_through_transaction(klass, models)
    @lock_models[klass].synchronize do
      debug "Opening new transaction by using '#{@args[:transaction_method]}'." if @debug

      klass.__send__(@args[:transaction_method]) do
        models.each do |work|
          if work[:type] == :save!
            validate = work.key?(:validate) ? work[:validate] : true
            work[:model].save! validate: validate
          elsif work[:type] == :destroy!
            work[:model].destroy!
          else
            raise "Invalid type: '#{work[:type]}'."
          end
        end
      end
    end
  end

  def work_threadded(klass, models)
    thread = Thread.new do
      begin
        work_models_through_transaction(klass, models)
      ensure
        debug "Removing thread #{Thread.current.__id__}" if @debug

        @threads.delete(Thread.current)
        @lock.synchronize { ActiveRecord::Base.connection.close if ActiveRecord::Base.connection }
      end
    end

    @lock_threads.synchronize do
      threads << thread
      @threads << thread
    end
  end

  def should_flush?
    @count >= @transaction_size
  end
end
