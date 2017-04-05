require 'switch_gear'

module SwitchGearSidekiq
  class Breaker < ::SwitchGear::CircuitBreaker::Redis
    attr_accessor :worker
    def initialize
      yield self
      @namespace = "circuit_breaker_#{worker}"
      @logger = logger || Sidekiq.logger
      # dummy lambda to allow easy invocation of job
      @circuit = circuit || -> (sk_job) { sk_job.call }
      run_validations
    end

    def to_s
      <<~EOF
        [SwitchGearSidekiq::Breaker] - Breaker config
        namespace: #{namespace}
        logger: #{logger}
        circuit: #{circuit}
        reset_timeout: #{reset_timeout}
        failure_limit: #{failure_limit}
      EOF
    end

    private

    def run_validations
      msg = "Missing worker"
      fail msg if !worker
    end
  end
end
