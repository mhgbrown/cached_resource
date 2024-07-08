require 'spec_helper'

RSpec.describe CachedResource::Model do
  let(:logger) { double(:Logger, error: nil)}
  let(:dummy_class) do
    Class.new(ActiveResource::Base) do
      include CachedResource::Model
    end
  end

  describe '.cached_resource' do
    context 'when cached resource is not set up' do
      it 'initializes and returns a new cached resource configuration' do
        options = { logger: logger }
        allow(CachedResource::Configuration).to receive(:new).with(options).and_call_original

        cached_resource = dummy_class.cached_resource(options)

        expect(cached_resource).to be_a(CachedResource::Configuration)
        expect(dummy_class.instance_variable_get(:@cached_resource)).to eq(cached_resource)
        expect(CachedResource::Configuration).to have_received(:new).with(options)
      end
    end

    context 'when cached resource is already set up' do
      it 'returns the existing cached resource configuration' do
        existing_config = CachedResource::Configuration.new
        dummy_class.instance_variable_set(:@cached_resource, existing_config)

        cached_resource = dummy_class.cached_resource

        expect(cached_resource).to eq(existing_config)
      end
    end
  end

  describe '.setup_cached_resource!' do
    it 'creates a new cached resource configuration' do
      options = { logger: logger }
      allow(CachedResource::Configuration).to receive(:new).with(options).and_call_original

      dummy_class.setup_cached_resource!(options)

      expect(dummy_class.instance_variable_get(:@cached_resource)).to be_a(CachedResource::Configuration)
      expect(CachedResource::Configuration).to have_received(:new).with(options)
    end

    context 'when concurrent_write is enabled' do
      before do
        allow(CachedResource::Configuration).to receive(:new).and_return(
          double(concurrent_write: true, logger: logger)
        )
      end

      it 'requires concurrent/promise' do
        expect { dummy_class.setup_cached_resource!(concurrent_write: true) }.not_to raise_error(LoadError)
      end

      context 'When "concurrent/promise" is not installed' do
        before do
          allow(dummy_class).to receive(:require).with("concurrent/promise").and_raise(LoadError)
        end

        it 'requires concurrent/promise' do
          expect(logger).to receive(:error).with(
            "`concurrent_write` option is enabled, but `concurrent-ruby` is not an installed dependency"
          ).once
          expect { dummy_class.setup_cached_resource!(concurrent_write: true) }.to raise_error(LoadError)
        end
      end
    end
  end

  describe '.inherited' do
    let(:child_class) { Class.new(dummy_class) }

    context 'when cached resource is defined in superclass' do
      it 'copies the cached resource configuration to the subclass' do
        existing_config = CachedResource::Configuration.new
        dummy_class.instance_variable_set(:@cached_resource, existing_config)

        expect(child_class.cached_resource).to eq(existing_config)
      end
    end

    context 'when cached resource is not defined in superclass' do
      it 'does not set cached resource configuration in the subclass' do
        expect(child_class.instance_variable_defined?(:@cached_resource)).to be_falsey
      end
    end
  end
end
