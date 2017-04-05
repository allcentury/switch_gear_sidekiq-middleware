require 'spec_helper'

describe SwitchGearSidekiq::Breaker do
  let(:breaker) do
    described_class.new do |b|
      b.worker = Helpers::SomeWorker
    end
  end
  it 'is really just a redis client' do
    expect(breaker).to be_a SwitchGear::CircuitBreaker::Redis
  end
  it 'needs a worker' do
    expect {
      described_class.new { }
    }.to raise_error(ArgumentError, /worker/)
  end
  context 'defaults' do
    it 'uses sidekiq logger' do
      expect(breaker.logger).to be Sidekiq.logger
    end
    it 'uses worker name for redis namespace' do
      expect(breaker.namespace).to eq "circuit_breaker_#{breaker.worker}"
    end
  end
end
