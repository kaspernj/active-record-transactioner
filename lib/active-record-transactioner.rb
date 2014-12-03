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
    @models = {}
    @threads = []
    @count = 0
    @lock = Monitor.new
    @lock_threads = Monitor.new
    @lock_models = {}
    @debug = @args[:debug]

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
  def queue(model)
    @lock.synchronize do
      klass = model.class

      @lock_models[klass] ||= Mutex.new
      @models[klass] ||= []
      @models[klass] << model
      @count += 1
    end

    flush if @count >= @args[:transaction_size]
  end

  #Flushes the specified method on all the queued models in a thread for each type of model.
  def flush
    if @args[:threadded]
      threads = []
      wait_for_threads
    end

    @lock.synchronize do
      @models.each do |klass, models|
        next if models.empty?

        @models[klass] = []
        @count -= models.length

        if @args[:threadded]
          thread = Thread.new do
            begin
              save_models_through_transaction(klass, models)
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
        else
          save_models_through_transaction(klass, models)
        end
      end
    end

    return {threads: threads}
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

  def save_models_through_transaction(klass, models)
    @lock_models[klass].synchronize do
      debug "Opening new transaction by using '#{@args[:transaction_method]}'." if @debug

      klass.__send__(@args[:transaction_method]) do
        models.each do |model|
          debug "Saving #{model.class.name}(#{model.id}) with method #{@args[:call_method]}" if @debug
          model.__send__(@args[:call_method], *@args[:call_args])
        end
      end
    end
  end
end
