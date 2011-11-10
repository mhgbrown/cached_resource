require 'ostruct'
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
        Object.send(:remove_const, :Rails)
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
        cached_resource :ttl => 1, :cache => "cache", :logger => "logger", :enabled => false, :custom => "irrelevant"
      end
    end

    it "should relfect the specified options" do
      Foo.cached_resource.ttl.should == 1
      Foo.cached_resource.cache.should == "cache"
      Foo.cached_resource.logger.should == "logger"
      Foo.cached_resource.enabled.should == false
      Foo.cached_resource.custom.should == "irrelevant"
    end
  end
end