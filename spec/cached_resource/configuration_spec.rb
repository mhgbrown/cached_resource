require 'spec_helper'

describe "CachedResource::Configuration" do

  let(:configuration) { CachedResource::Configuration.new }

  describe "by default" do
    it "should be enabled" do
      configuration.enabled.should == true
    end

    it "should have a cache expiry of 1 week" do
      configuration.ttl.should == 604800
    end

    it "should disable collection synchronization" do
      configuration.collection_synchronize.should == false
    end

    it "should default to :all for collection arguments" do
      configuration.collection_arguments.should == [:all]
    end

    describe "outside a Rails environment" do
      it "should be logging to a buffered logger attached to a NilIO" do
        configuration.logger.class.should == ActiveSupport::BufferedLogger
        # ActiveSupport switched around the log destination variables
        # Check if either are what we expect to be compatible
        old_as = configuration.logger.instance_variable_get(:@log).class == NilIO
        new_as = configuration.logger.instance_variable_get(:@log_dest).class == NilIO
        (old_as || new_as).should == true
      end

      it "should cache responses in a memory store" do
        configuration.cache.class.should == ActiveSupport::Cache::MemoryStore
      end
    end

    describe "inside a Rails environment" do
      before(:each) do
        Rails = OpenStruct.new(:logger => "logger", :cache => "cache")
        load "cached_resource/configuration.rb"
      end

      after(:each) do
        # remove the rails constant and unbind the
        # cache and logger from the configuration
        # defaults
        Object.send(:remove_const, :Rails)
        load "cached_resource/configuration.rb"
      end

      it "should be logging to the rails logger" do
        configuration.logger.should == "logger"
      end

      it "should cache responses in a memory store" do
        configuration.cache.should == "cache"
      end
    end
  end

  describe "when initialized through cached resource" do
    before(:each) do
      class Foo < ActiveResource::Base
        cached_resource :ttl => 1,
                        :cache => "cache",
                        :logger => "logger",
                        :enabled => false,
                        :collection_synchronize => true,
                        :collection_arguments => [:every],
                        :custom => "irrelevant"
      end
    end

    after(:each) do
      Object.send(:remove_const, :Foo)
    end

    it "should relfect the specified options" do
      cr = Foo.cached_resource
      cr.ttl.should == 1
      cr.cache.should == "cache"
      cr.logger.should == "logger"
      cr.enabled.should == false
      cr.collection_synchronize.should == true
      cr.collection_arguments.should == [:every]
      cr.custom.should == "irrelevant"
    end
  end

  # re-evaluate
  describe "when multiple are initialized through cached resource" do
    before(:each) do
      class Foo < ActiveResource::Base
        cached_resource
      end

      class Bar < ActiveResource::Base
        cached_resource
      end
    end

    after(:each) do
      Object.send(:remove_const, :Foo)
      Object.send(:remove_const, :Bar)
    end

    it "they should have different configuration objects" do
      Foo.cached_resource.object_id.should_not == Bar.cached_resource.object_id
    end

    it "they should have the same attributes" do
      Foo.cached_resource.instance_variable_get(:@table).should == Bar.cached_resource.instance_variable_get(:@table)
    end

  end

  describe "when cached resource is inherited" do
    before(:each) do
      class Bar < ActiveResource::Base
        cached_resource :ttl => 1,
                        :cache => "cache",
                        :logger => "logger",
                        :enabled => false,
                        :collection_synchronize => true,
                        :collection_arguments => [:every],
                        :custom => "irrelevant"
      end

      class Foo < Bar
      end
    end

    after(:each) do
      Object.send(:remove_const, :Foo)
      Object.send(:remove_const, :Bar)
    end

    it "it should make sure each subclass has the same configuration" do
      Bar.cached_resource.object_id.should == Foo.cached_resource.object_id
    end

  end

  describe "when cached resource is inherited and then overriden" do
    before(:each) do
      class Bar < ActiveResource::Base
        cached_resource :ttl => 1,
                        :cache => "cache",
                        :logger => "logger",
                        :enabled => false,
                        :collection_synchronize => true,
                        :collection_arguments => [:every],
                        :custom => "irrelevant"
      end

      class Foo < Bar
        # override the superclasses configuration
        self.cached_resource = CachedResource::Configuration.new(:ttl => 60)
      end
    end

    after(:each) do
      Object.send(:remove_const, :Foo)
      Object.send(:remove_const, :Bar)
    end

    it "should have the specified options" do
      Foo.cached_resource.ttl.should == 60
    end

    it "should have the default options for anything unspecified" do
      cr = Foo.cached_resource
      cr.cache.class.should == ActiveSupport::Cache::MemoryStore
      cr.logger.class.should == ActiveSupport::BufferedLogger
      cr.enabled.should == true
      cr.collection_synchronize.should == false
      cr.collection_arguments.should == [:all]
      cr.custom.should == nil
      cr.ttl_randomization.should == false
      cr.ttl_randomization_scale.should == (0..1)
    end

  end

  # At the moment, not too keen on implementing some fancy
  # randomness validator.
  describe "when ttl randomization is enabled" do
    before(:each) do
      @ttl = 10
      configuration.ttl = @ttl
      configuration.ttl_randomization = true
      configuration.send(:sample_range, 0..@ttl, @ttl)
      # next ttl: 10.207519493594015
    end

    it "it should produce a random ttl between ttl and ttl * 2" do
      generated_ttl = configuration.generate_ttl
      generated_ttl.should_not == 10
      (@ttl..(2 * @ttl)).should include(generated_ttl)
    end

    describe "when a ttl randomization scale is set" do
      before(:each) do
        @lower = -0.5
        @upper = 0.5
        configuration.ttl_randomization_scale = @lower..@upper
        # next ttl 5.207519493594015
      end

      it "should produce a random ttl between ttl + ttl * lower bound and ttl + ttl * upper bound" do
        lower = @ttl + @ttl * @lower
        upper = @ttl + @ttl * @upper
        (lower..upper).should include(configuration.generate_ttl)
      end
    end
  end
end