require "spec_helper"
require "tmpdir"

describe "ActiveRecordTransactioner" do
  it "saves the expected models" do
    require_relative "test_classes/active_record_transactioner_test_class"

    trans = ActiveRecordTransactioner.new(transaction_size: 2)

    model1 = ActiveRecordTransactionerTestClass.new
    model2 = ActiveRecordTransactionerTestClass.new
    model3 = ActiveRecordTransactionerTestClass.new

    trans.save!(model1)
    trans.save!(model2)

    trans.join

    expect(model1.save_called).to be true
    expect(model2.save_called).to be true
    expect(model3.save_called).to be false

    called = false
    ActiveRecordTransactioner.new do |transactioner|
      called = true
      expect(transactioner).to be_a ActiveRecordTransactioner
    end

    expect(called).to be true
  end

  it "doesnt fail under the Rails reverse bug" do
    trans = ActiveRecordTransactioner.new(transaction_size: 1)
    model1 = ActiveRecordTransactionerTestClass.new
    trans.save!(model1)
    trans.join

    expect(ActiveRecordTransactionerTestClass::ARGS[:nilraise]).to be false
  end
end
