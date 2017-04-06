# SwitchGearSidekiq::Middleware

This gem is a small [Sidekiq](https://www.github.com/mperham/sidekiq) middlware that uses the [SwitchGear](https://www.github.com/allcentury/switch_gear) gem to allow for a circuit breaker to be used across sidekiq jobs.  This is done using the `Redis` client found in `SwitchGear`.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'switch_gear_sidekiq-middleware'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install switch_gear_sidekiq-middleware

## Usage

You need to add the middlware to your sidekiq initializer like so:

```ruby
# use your own redis connecton or checkout one from the sidekiq pool
redis = Redis.new || Sidekiq::Client.new.redis_pool.checkout

breaker = SwitchGearSidekiq::Breaker.new do |cb|
  cb.client = redis
  cb.worker = YourWorkerClass
  cb.failure_limit = 2
  cb.reset_timeout = 5
  cb.logger = Sidekiq.logger
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SwitchGearSidekiq::Middleware, breakers: [breaker]
  end
end
```

You can pass an array of breakers to the middleware.  The middleware looks up the breaker by the worker class you pass in and needs to match the worker Sidekiq would initialize when it's popped off the queue.

There is a helper class called `SwitchGearSidekiq::Breaker` which is a really thin wrapper around [SwitchGear::CircuitBreaker::Redis](https://www.github.com/allcentury/switch_gear).  Please see that gems documentation on what can be configured.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/allcentury/switch_gear_sidekiq-middleware. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

