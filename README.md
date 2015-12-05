[![Build Status](https://api.shippable.com/projects/540e7b993479c5ea8f9ec1f2/badge?branchName=master)](https://app.shippable.com/projects/540e7b993479c5ea8f9ec1f2/builds/latest)
[![Code Climate](https://codeclimate.com/github/kaspernj/active-record-transactioner/badges/gpa.svg)](https://codeclimate.com/github/kaspernj/active-record-transactioner)
[![Test Coverage](https://codeclimate.com/github/kaspernj/active-record-transactioner/badges/coverage.svg)](https://codeclimate.com/github/kaspernj/active-record-transactioner)

# active-record-transactioner

Queue saving and destroying of many models into transactions through multiple threads for optimal database-performance in ActiveRecord.

## Install

Add to your Gemfile and bundle:
```ruby
gem 'active-record-transactioner'
```

## Usage

### Iterate a million times - will update each 1000 records in a single transaction with `save!`.
```ruby
ActiveRecordTransactioner.new do |trans|
  models.each do |model|
    model.some_attribute = "some_value"
    trans.save!(model)
  end
end
```

You can also do it a bit more complicated with some custom options.
```ruby
ActiveRecordTransactioner.new(
  transaction_method: :transaction,
  transaction_size: 1000,
  threadded: false
) do |trans|
  models.each do |model|
    model.some_attribute = "some_value"
    trans.save!(model)
  end
end
```

### Update columns
```ruby
ActiveRecordTransactioner.new do |trans|
  models.each do |model|
    trans.update_columns(model, some_column: "new_value")
  end
end
```

### Inserts in a single SQL statement (bulk inserts)
```ruby
ActiveRecordTransactioner.new do |trans|
  1000.times do |count|
    trans.bulk_create!(User.new(email: "test#{count}@example.com"))
  end
end
```

### Destroy
```ruby
ActiveRecordTransactioner.new do |trans|
  models.each do |model|
    trans.destroy!(model)
  end
end
```

### Threadded

The "threadded" and "max_running_threads" options will start new threads to do the saving of the models, while continuing to queue up new models in the primary thread. This way the database can utilize multiple cores, and if you use a threadded VM like JRuby or Rubinius, you will utilize even more.

This can help greatly speed up the processing of records.

Be aware that the saving of only one type of model, will be limited to only one thread, so it will make sense to try and queue up as many type of models as possible. Like users, orders and so on.

```ruby
ActiveRecordTransactioner.new(
  threadded: true,
  max_running_threads: 3
) do |trans|
  models.each do |model|
    model.some_attribute = "some_value"
    trans.save!(model)
  end
end
```

## Contributing to active-record-transactioner

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2013 Kasper Johansen. See LICENSE.txt for
further details.
