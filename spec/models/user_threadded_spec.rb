require "spec_helper"

describe User do
  def transactioner
    ActiveRecordTransactioner.new(debug: false, transaction_size: 50, threadded: true) do |transactioner|
      yield transactioner
    end
  end

  it_should_behave_like "basic user operations"
end
