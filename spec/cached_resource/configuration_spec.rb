require "spec_helper"

class Foo < ActiveResource::Base
  cached_resource
end

class Bar < ActiveResource::Base
  cached_resource ttl: 1,
    race_condition_ttl: 5,
    cache: "cache",
    logger: "logger",
    enabled: false,
    collection_synchronize: true,
    collection_arguments: [:every],
    custom: "irrelevant",
    cache_collections: true
end

class Bar2 < Bar; end

class Bar3 < Bar
  # override the superclasses configuration
  self.cached_resource = CachedResource::Configuration.new(ttl: 60)
end

describe CachedResource::Configuration do
  let(:configuration) { described_class.new }
  let(:default_logger) { defined?(ActiveSupport::Logger) ? ActiveSupport::Logger : ActiveSupport::BufferedLogger }

  describe "#off!" do
    subject { configuration }
    before { subject.on! }
    after { subject.off! }

    it "sets cache off" do
      expect { subject.off! }.to change { subject.enabled }.from(true).to(false)
    end
  end

  describe "#on!" do
    subject { configuration }
    before { subject.off! }
    after { subject.off! }

    it "sets cache off" do
      expect { subject.on! }.to change { subject.enabled }.from(false).to(true)
    end
  end

  context "defaults" do
    it "should be enabled" do
      expect(configuration.enabled).to eq(true)
    end

    it "should have a cache expiry of 1 week" do
      expect(configuration.ttl).to eq(604800)
    end

    it "should have key length of Configuration::MAX_KEY_LENGTH" do
      expect(configuration.max_key_length).to eq(CachedResource::Configuration::MAX_KEY_LENGTH)
    end

    it "should disable collection synchronization" do
      expect(configuration.collection_synchronize).to eq(false)
    end

    it "should default to :all for collection arguments" do
      expect(configuration.collection_arguments).to eq([:all])
    end

    it "should cache collections" do
      configuration.cache_collections == true
    end

    describe "outside a Rails environment" do
      it "should be logging to a buffered logger attached to a NilIO" do
        expect(configuration.logger.class).to eq(default_logger)
        # ActiveSupport switched around the log destination variables
        # Check if either are what we expect to be compatible
        old_as = configuration.logger.instance_variable_get(:@log).instance_of?(NilIO)
        new_as = configuration.logger.instance_variable_get(:@log_dest).instance_of?(NilIO)
        newer_as = configuration.logger.instance_variable_get(:@logdev).instance_variable_get(:@dev).instance_of?(NilIO)
        expect(old_as || new_as || newer_as).to eq(true)
      end

      it "should cache responses in a memory store" do
        expect(configuration.cache.class).to eq(ActiveSupport::Cache::MemoryStore)
      end
    end

    describe "inside a Rails environment" do
      before(:each) do
        stub_const("Rails", double(:Rails, logger: "logger", cache: "cache"))
      end

      it "should be logging to the rails logger" do
        expect(configuration.logger).to eq("logger")
      end

      it "should cache responses in a memory store" do
        expect(configuration.cache).to eq("cache")
      end
    end
  end

  context "when initialized through cached resource" do
    it "should relfect the specified options" do
      cr = Bar.cached_resource
      expect(cr.ttl).to eq(1)
      expect(cr.race_condition_ttl).to eq(5)
      expect(cr.cache).to eq("cache")
      expect(cr.logger).to eq("logger")
      expect(cr.enabled).to eq(false)
      expect(cr.collection_synchronize).to eq(true)
      expect(cr.collection_arguments).to eq([:every])
      expect(cr.custom).to eq("irrelevant")
      expect(cr.cache_collections).to eq(true)
    end
  end

  context "when multiple are initialized through cached resource" do
    it "they should have different configuration objects" do
      expect(Foo.cached_resource.object_id).not_to eq(Bar.cached_resource.object_id)
    end
  end

  context "when cached resource is inherited" do
    it "it should make sure each subclass has the same configuration" do
      expect(Bar.cached_resource.object_id).to eq(Bar2.cached_resource.object_id)
    end
  end

  context "when cached resource is inherited and then overriden" do
    it "only overwrites explicitly set options" do
      cr = Bar3.cached_resource
      expect(Bar3.cached_resource.ttl).to eq(60)
      expect(cr.cache.class).to eq(ActiveSupport::Cache::MemoryStore)
      expect(cr.logger.class).to eq(default_logger)
      expect(cr.enabled).to eq(true)
      expect(cr.collection_synchronize).to eq(false)
      expect(cr.collection_arguments).to eq([:all])
      expect(cr.custom).to eq(nil)
      expect(cr.ttl_randomization).to eq(false)
      expect(cr.ttl_randomization_scale).to eq(1..2)
      expect(cr.cache_collections).to eq(true)
      expect(cr.race_condition_ttl).to eq(86400)
    end
  end

  # At the moment, not too keen on implementing some fancy
  # randomness validator.
  context "when ttl randomization is enabled" do
    before(:each) do
      @ttl = 1
      configuration.ttl = @ttl
      configuration.ttl_randomization = true
      configuration.send(:sample_range, 1..2, @ttl)
      # next ttl: 1.72032449344216
    end

    it "it should produce a random ttl between ttl and ttl * 2" do
      generated_ttl = configuration.generate_ttl
      expect(generated_ttl).not_to eq(10)
      expect(@ttl..(2 * @ttl)).to include(generated_ttl)
    end

    describe "when a ttl randomization scale is set" do
      before(:each) do
        @lower = 0.5
        @upper = 1
        configuration.ttl_randomization_scale = @lower..@upper
        # next ttl 0.860162246721079
      end

      it "should produce a random ttl between ttl * lower bound and ttl * upper bound" do
        lower = @ttl * @lower
        upper = @ttl * @upper
        expect(lower..upper).to include(configuration.generate_ttl)
      end
    end
  end
end
