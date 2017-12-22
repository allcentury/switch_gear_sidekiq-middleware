require "spec_helper"

describe SwitchGearSidekiq::Middleware do
  let(:redis) { double('redis') }
  let(:worker) { Helpers::SomeWorker.new }
  let(:job) do
      { 'class' => 'Helpers::SomeWorker', 'args' => [1,2,'foo'] }
  end
  let(:middleware) do
    described_class.new(breakers: [breaker])
  end
  let(:breaker) do
    SwitchGearSidekiq::Breaker.new do |b|
      b.client = redis
      b.worker = Helpers::SomeWorker
      b.failure_limit = 2
      b.reset_timeout = 5
      b.logger = Logger.new(STDOUT)
    end
  end

  before do
    Sidekiq.redis {|c| c.flushdb }
  end

  it 'supports custom middleware' do
    chain = Sidekiq::Middleware::Chain.new
    chain.add described_class, breakers: [breaker]

    expect(chain.entries.last.klass).to be described_class
  end
  it "has a version number" do
    expect(SwitchGearSidekiq::Middleware::VERSION).not_to be nil
  end

  describe 'with middlware configured' do
    it 'runs the job normally without error' do
      allow(redis).to receive(:get).with(/state/).and_return("closed")
      allow(redis).to receive(:del)
      expect(redis).to receive(:set).with(/state/, /closed/)
      expect(worker).to_not receive(:perform_in)
      middleware.call(worker, job, 'default') do
        'running job...'
      end
    end

    it 're-enqueues a job ' do
      allow(redis).to receive(:get).with(/state/).and_return("open")
      allow(breaker).to receive(:check_reset_timeout)
      expect(worker.class).to receive(:perform_in).with(breaker.reset_timeout + 1, *job['args'])
      middleware.call(worker, job, 'default') do
        'running job...'
      end
    end

    it "does nothing if a breaker isn't configured" do
      expect(redis).to_not receive(:get)
      expect(Sidekiq.logger).to receive(:debug).with(/No breaker found/)
      middleware.call(OtherWorker, job, 'default') do
        'running job...'
      end
    end
  end

  class OtherWorker; end
end
