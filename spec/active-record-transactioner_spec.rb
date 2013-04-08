require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiveRecordTransactioner" do
  it "works" do
    require_relative "test_classes/active-record-transactioner-test-class"
    
    trans = ActiveRecordTransactioner.new(:transaction_size => 2)
    
    model1 = ActiveRecordTransactionerTestClass.new
    model2 = ActiveRecordTransactionerTestClass.new
    model3 = ActiveRecordTransactionerTestClass.new
    
    trans.queue(model1)
    trans.queue(model2)
    
    trans.join
    
    model1.save_called.should eql(true)
    model2.save_called.should eql(true)
    model3.save_called.should eql(false)
    
    called = false
    ActiveRecordTransactioner.new do |trans|
      called = true
      trans.class.should eql(ActiveRecordTransactioner)
    end
    
    called.should eql(true)
  end
end
