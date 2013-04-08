require "monitor"

class ActiveRecordTransactioner
  DEFAULT_ARGS = {
    :call_args => [],
    :call_method => :save!,
    :transaction_size => 1000
  }
  
  def initialize(args = {})
    @args = DEFAULT_ARGS.merge(args)
    @models = {}
    @threads = []
    @count = 0
    @lock = Monitor.new
    
    if block_given?
      begin
        yield
      ensure
        flush
      end
    end
  end
  
  def queue(model)
    @lock.synchronize do
      klass = model.class
      @models[klass] = {} if !@models.key?(klass)
      @models[klass] << model
      @count += 1
      
      flush if @count >= @args[:transaction_size]
    end
  end
  
  def flush
    threads = []
    
    @lock.synchronize do
      @models.each do |klass, val|
        next unless val.empty?
        
        models = val
        @models[klass] = []
        @count -= models.length
        
        threads << Thread.new do
          begin
            klass.transaction do
              models.each do |model|
                model.__send__(*@args[:call_args])
              end
            end
          rescue => e
            puts e.inspect
            puts e.backtrace
          end
        end
      end
    end
    
    return {
      :threads => threads
    }
  end
end