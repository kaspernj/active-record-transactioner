require "spec_helper"
require "tmpdir"

describe "ActiveRecordTransactioner" do
  it "works" do
    require_relative "test_classes/active-record-transactioner-test-class"

    trans = ActiveRecordTransactioner.new(transaction_size: 2)

    model1 = ActiveRecordTransactionerTestClass.new
    model2 = ActiveRecordTransactionerTestClass.new
    model3 = ActiveRecordTransactionerTestClass.new

    trans.save!(model1)
    trans.save!(model2)

    trans.join

    model1.save_called.should eq true
    model2.save_called.should eq true
    model3.save_called.should eq false

    called = false
    ActiveRecordTransactioner.new do |trans|
      called = true
      trans.class.should eql(ActiveRecordTransactioner)
    end

    called.should eq true
  end

  it "should not fail under the Rails reverse bug" do
    trans = ActiveRecordTransactioner.new(transaction_size: 1)
    model1 = ActiveRecordTransactionerTestClass.new
    trans.save!(model1)
    trans.join

    ActiveRecordTransactionerTestClass::ARGS[:nilraise].should eq false
  end
end
