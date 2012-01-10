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
        configuration.logger.instance_variable_get(:@log).class.should == CachedResource::NilIO
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
      Foo.cached_resource.ttl.should == 1
      Foo.cached_resource.cache.should == "cache"
      Foo.cached_resource.logger.should == "logger"
      Foo.cached_resource.enabled.should == false
      Foo.cached_resource.collection_synchronize.should == true
      Foo.cached_resource.collection_arguments.should == [:every]
      Foo.cached_resource.custom.should == "irrelevant"
    end
  end

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

    it "they should have the same cache" do
      Foo.cached_resource.cache.should == Bar.cached_resource.cache
      Foo.cached_resource.cache.object_id.should == Bar.cached_resource.cache.object_id
    end

    it "they should have the same ttl" do
      Foo.cached_resource.ttl.should == Bar.cached_resource.ttl
    end

    it "they should have the same logger" do
      Foo.cached_resource.logger.should == Bar.cached_resource.logger
      Foo.cached_resource.logger.object_id.should == Bar.cached_resource.logger.object_id
    end

    it "they should have the same enablement" do
      Foo.cached_resource.enabled.should == Bar.cached_resource.enabled
    end

  end

end