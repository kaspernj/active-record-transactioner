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
    expect(User.count).to eq 100
  end

  it "can both insert and update a lot of records correct" do
    transactioner do |trans|
      200.times do |count|
        user = User.find_or_initialize_by(email: "user#{count}@example.com")
        user.username = "User upsert #{count}"

        trans.save!(user)
      end
    end

    expect(User.count).to eq 200

    count = 0
    User.order(:id).each do |user|
      expect(user.email).to eq "user#{count}@example.com"
      count += 1
    end
  end

  it "#update_columns" do
    transactioner do |trans|
      count = 0
      User.find_each do |user|
        trans.update_columns(user, email: "test#{count}@example.com") # rubocop:disable Rails/SkipsModelValidations
        count += 1
      end
    end

    count = 0
    User.find_each do |user|
      expect(user.email).to eq "test#{count}@example.com"
      count += 1
    end

    expect(User.count).to eq 100
  end

  it "can delete a lot of records" do
    transactioner do |trans|
      User.limit(50).each do |user|
        trans.destroy!(user)
      end
    end

    expect(User.count).to eq 50
  end

  it "does bulk inserts" do
    User.delete_all

    transactioner do |trans|
      300.times do |count|
        trans.bulk_create!(User.new(email: "test#{count}@example.com"))
      end
    end

    count = 0
    User.order(:id).each do |user|
      expect(user.email).to eq "test#{count}@example.com"
      count += 1
    end

    expect(count).to eq 300
  end
end
