[![Build Status](https://api.shippable.com/projects/540e7b993479c5ea8f9ec1f2/badge?branchName=master)](https://app.shippable.com/projects/540e7b993479c5ea8f9ec1f2/builds/latest)
[![Code Climate](https://codeclimate.com/github/kaspernj/active-record-transactioner/badges/gpa.svg)](https://codeclimate.com/github/kaspernj/active-record-transactioner)
[![Test Coverage](https://codeclimate.com/github/kaspernj/active-record-transactioner/badges/coverage.svg)](https://codeclimate.com/github/kaspernj/active-record-transactioner)

# active-record-transactioner

## Usage

### Iterate a million times - will save each 1000 in a transaction with `save!`.
```ruby
ActiveRecordTransactioner.new do |trans|
  models.each do |model|
    trans.queue(model)
  end
end
```

You can also do it a bit more complicated with some custom options.
```ruby
ActiveRecordTransactioner.new(
  call_args: ["Hello world!"],
  call_method: :save!,
  transaction_method: :transaction,
  transaction_size: 1000
) do |trans|
  models.each do |model|
    trans.queue(model)
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
