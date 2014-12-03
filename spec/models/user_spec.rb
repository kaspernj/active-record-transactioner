require "spec_helper"

describe User do
  before do
    ActiveRecordTransactioner.new(transaction_size: 50) do |transactioner|
      100.times do |count|
        user = User.new(username: "User #{count}", email: "user#{count}@example.com")
        transactioner.save!(user)
      end
    end
  end

  it "can create a lot of models" do
    User.count.should eq 100
  end

  it "can both insert and update a lot of records correct" do
    ActiveRecordTransactioner.new(transaction_size: 50) do |transactioner|
      200.times do |count|
        user = User.find_or_initialize_by(email: "user#{count}@example.com")
        user.username = "User upset #{count}"
        transactioner.save!(user)
      end
    end

    User.count.should eq 200
  end

  it "can delete a lot of records" do
    ActiveRecordTransactioner.new(transaction_size: 50) do |transactioner|
      User.limit(50).each do |user|
        transactioner.destroy!(user)
      end
    end

    User.count.should eq 50
  end
end
