require "monitor"

class ActiveRecordTransactioner
  DEFAULT_ARGS = {
    :call_args => [],
    :call_method => :save!,
    :transaction_method => :transaction,
    :transaction_size => 1000
  }
  
  ALLOWED_ARGS = DEFAULT_ARGS.keys
  
  def initialize(args = {})
    args.each do |key, val|
      raise "Invalid key: '#{key}'." unless ALLOWED_ARGS.include?(key)
    end
    
    @args = DEFAULT_ARGS.merge(args)
    @models = {}
    @threads = []
    @count = 0
    @lock = Monitor.new
    @lock_threads = Monitor.new
    
    if block_given?
      begin
        yield
      ensure
        flush
      end
    end
  end
  
  #Adds another model to the queue and calls 'flush' if it is over the limit.
  def queue(model)
    @lock.synchronize do
      klass = model.class
      @models[klass] = [] if !@models.key?(klass)
      @models[klass] << model
      @count += 1
      flush if @count >= @args[:transaction_size]
    end
  end
  
  #Flushes the specified method on all the queued models in a thread for each type of model.
  def flush
    threads = []
    
    @lock.synchronize do
      @models.each do |klass, val|
        next if val.empty?
        
        models = val
        @models[klass] = []
        @count -= models.length
        
        thread = Thread.new do
          begin
            klass.__send__(@args[:transaction_method]) do
              models.each do |model|
                model.__send__(@args[:call_method], *@args[:call_args])
              end
            end
          rescue => e
            puts e.inspect
            puts e.backtrace
          ensure
            @threads.delete(Thread.current)
          end
        end
        
        @lock_threads.synchronize do
          threads << thread
          @threads << thread
        end
      end
    end
    
    return {
      :threads => threads
    }
  end
  
  #Waits for any remaining running threads.
  def join
    @lock_threads.synchronize do
      @threads.each do |thread|
        thread.join
      end
    end
  end
end