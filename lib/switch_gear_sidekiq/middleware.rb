require 'switch_gear_sidekiq/breaker'

module SwitchGearSidekiq
  class Middleware
    VERSION = "0.1.1"

    attr_reader :breakers

    def initialize(breakers:)
      @breakers = breakers.each_with_object({}) do |breaker, hash|
        hash[breaker.worker] = breaker
      end
      run_validations
    end

    def call(worker, msg, queue, &block)
      breaker = breakers[worker.class]

      if !breaker
        Sidekiq.logger.debug "No breaker found for #{worker.class}"
        yield
        return
      end

      Sidekiq.logger.debug "Breaker being used: #{breaker}"

      breaker.call(block)
    rescue SwitchGear::CircuitBreaker::OpenError
      retry_in = breaker.reset_timeout + 1
      fail_msg = "Circuit is open for worker: #{breaker.worker} - blocking all calls;"
      fail_msg += "  Jobs will try again in: #{retry_in} "
      Sidekiq.logger.warn fail_msg

      # Here we'll re-enqueue the job to be 1 second above the reset_timeout period
      worker.class.perform_in(retry_in, *msg['args'])
    end

    private

    def run_validations
      msg = "You must pass in an instance of a SwitchGear::CircuitBreaker"
      fail msg if breakers.any? { |klass, breaker| !breaker.is_a? SwitchGear::CircuitBreaker }
    end
  end
end
