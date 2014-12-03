require "spec_helper"
require "tmpdir"

describe "ActiveRecordTransactioner" do
  before do
    file_path = "#{Dir.tmpdir}/active_record_transactioner_test.sqlite3"
    File.unlink(file_path) if File.exists?(file_path)

    ActiveRecord::Base.establish_connection(
      adapter: "sqlite3",
      database: file_path
    )
  end

  it "works" do
    require_relative "test_classes/active-record-transactioner-test-class"

    trans = ActiveRecordTransactioner.new(transaction_size: 2)

    model1 = ActiveRecordTransactionerTestClass.new
    model2 = ActiveRecordTransactionerTestClass.new
    model3 = ActiveRecordTransactionerTestClass.new

    trans.queue(model1)
    trans.queue(model2)

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
    trans.queue(model1)
    trans.join

    ActiveRecordTransactionerTestClass::ARGS[:nilraise].should eq false
  end
end
