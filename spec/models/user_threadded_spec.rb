require "spec_helper"

describe User do
  def transactioner(&blk)
    ActiveRecordTransactioner.new(transaction_size: 50, threadded: true, &blk)
  end

  it_behaves_like "basic user operations"
end
