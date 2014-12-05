shared_examples_for "basic user operations" do
  before do
    transactioner do |trans|
      100.times do |count|
        user = User.new(username: "User #{count}", email: "user#{count}@example.com")
        trans.save!(user)
      end
    end
  end

  it "can create a lot of models" do
    User.count.should eq 100
  end

  it "can both insert and update a lot of records correct" do
    transactioner do |trans|
      200.times do |count|
        user = User.find_or_initialize_by(email: "user#{count}@example.com")
        user.username = "User upsert #{count}"
        trans.save!(user)
      end
    end

    count = 0
    User.find_each do |user|
      user.email.should eq "user#{count}@example.com"
      count += 1
    end

    User.count.should eq 200
  end

  it "can delete a lot of records" do
    transactioner do |trans|
      User.limit(50).each do |user|
        trans.destroy!(user)
      end
    end

    User.count.should eq 50
  end
end
