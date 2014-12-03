require "spec_helper"
require "timeout"

describe User do
  it "can create a lot of models" do
    Timeout.timeout(2) do
      ActiveRecordTransactioner.new do |transactioner|
        1_000.times do |count|
          user = User.new(username: "User #{count}", email: "user#{count}@example.com")
          transactioner.queue(user)
        end
      end
    end

    User.count.should eq 1000
  end
end
