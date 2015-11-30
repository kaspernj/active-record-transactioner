class ActiveRecordTransactionerTestClass
  attr_reader :save_called, :args

  ARGS = {nilraise: false}

  def initialize
    @save_called = false
  end

  def self.transaction
    Thread.current[:trans] = name

    begin
      yield
    ensure
      Thread.current[:trans] = nil
    end
  end

  def save!(_args = {})
    raise "Failure - no transaction: #{Thread.current[:trans]}, #{self.class.name}" if Thread.current[:trans] != self.class.name
    @save_called = true
  end

  def valid?
    true
  end
end
