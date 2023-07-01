require "spec_helper"

describe User do
  def transactioner(&)
    ActiveRecordTransactioner.new(transaction_size: 50, &)
  end

  it_behaves_like "basic user operations"
end
