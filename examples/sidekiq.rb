# require 'switch_gear_sidekiq-middlware'
require 'sidekiq'
require 'switch_gear'
require 'redis'


class HardWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(name)
    http_result = ["Success!", "Fail"].sample
    raise RuntimeError.new("Failed to fetch something for #{name}") if http_result == "Fail"
    Sidekiq.logger.info "#{http_result} getting something for #{name}"
  end
end

# use your own redis connecton or checkout one from the sidekiq pool
redis = Redis.new || Sidekiq::Client.new.redis_pool.checkout
Sidekiq.logger.level = :debug

breaker = SwitchGearSidekiq::Breaker.new do |cb|
  cb.client = redis
  cb.worker = HardWorker
  cb.failure_limit = 2
  cb.reset_timeout = 5
  cb.logger = Sidekiq.logger
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SwitchGearSidekiq::Middleware, breakers: [breaker]
  end
end

["joe", "jane", "mary", "steve", "harry", "jeff", "sally", "tracy", "anna"].each { |handle| HardWorker.perform_async(handle) }
