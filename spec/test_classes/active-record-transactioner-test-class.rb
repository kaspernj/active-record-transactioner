class ActiveRecordTransactionerTestClass
  attr_reader :save_called, :args
  
  ARGS = {:nilraise => false}
  
  def initialize
    @save_called = false
  end
  
  def self.transaction
    if ActiveRecordTransactionerTestClass::ARGS[:nilraise]
      nilobj = nil
      ActiveRecordTransactionerTestClass::ARGS[:nilraise] = false
      nilobj.reverse
    end
    
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