class ActiveRecordTransactionerTestClass
  attr_reader :save_called
  
  def initialize
    @save_called = false
  end
  
  def self.transaction
    Thread.current[:trans] = self.name
    
    begin
      yield
    ensure
      Thread.current[:trans] = nil
    end
  end
  
  def save!
    raise "Failure - no transaction: #{Thread.current[:trans]}, #{self.class.name}" if Thread.current[:trans] != self.class.name
    @save_called = true
  end
end