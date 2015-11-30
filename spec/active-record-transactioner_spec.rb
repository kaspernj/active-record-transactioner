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

    expect(model1.save_called).to eq true
    expect(model2.save_called).to eq true
    expect(model3.save_called).to eq false

    called = false
    ActiveRecordTransactioner.new do |transactioner|
      called = true
      expect(transactioner).to be_a ActiveRecordTransactioner
    end

    expect(called).to eq true
  end

  it "doesnt fail under the Rails reverse bug" do
    trans = ActiveRecordTransactioner.new(transaction_size: 1)
    model1 = ActiveRecordTransactionerTestClass.new
    trans.save!(model1)
    trans.join

    expect(ActiveRecordTransactionerTestClass::ARGS[:nilraise]).to eq false
  end
end
