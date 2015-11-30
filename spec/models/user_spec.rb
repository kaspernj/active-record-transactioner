require "spec_helper"

describe User do
  def transactioner
    ActiveRecordTransactioner.new(transaction_size: 50) do |transactioner|
      yield transactioner
    end
  end

  it_should_behave_like "basic user operations"
end