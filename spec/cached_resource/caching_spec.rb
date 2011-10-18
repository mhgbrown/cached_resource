require 'spec_helper'

describe CachedResource do

  before(:all) do
    class Thing < ActiveResource::Base
      self.site = "http://api.thing.com"
    end

    @thing = {:thing => {:id => 1, :name => "Ada"}}
    @other_thing = {:thing => {:id => 1, :name => "Ari"}}
    @thing_json = @thing.to_json
    @other_thing_json = @other_thing.to_json
  end

  describe "when enabled" do

    before(:all) do
      # it's on by default, but lets call the method
      # to make sure it works
      CachedResource.on!

      ActiveResource::HttpMock.reset!
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/things/1.json", {}, @thing_json
      end
    end

    it "should cache a response" do
      result = Thing.find(1)
      CachedResource.config.cache.read("thing/1").should == result
    end

    it "should read a response when the request is made again" do
      Thing.find(1)
      # only one request should have been made by the test
      # before this one
      ActiveResource::HttpMock.requests.length.should == 1
    end

    it "should remake a request when reloaded" do
      Thing.find(1, :reload => true)
      ActiveResource::HttpMock.requests.length.should == 2
    end

    it "should rewrite the cache when the request is reloaded" do
      old_result = CachedResource.config.cache.read("thing/1")

      # change the response
      ActiveResource::HttpMock.reset!
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/things/1.json", {}, @other_thing_json
      end

      Thing.find(1, :reload => true)
      new_result = CachedResource.config.cache.read("thing/1")
      # since active resources are equal if and only if they
      # are the same object or an instance of the same class,
      # not new?, and have the same id.
      new_result.name.should_not == old_result.name
    end
  end

  describe "when disabled" do

    before(:all) do
      CachedResource.off!

      ActiveResource::HttpMock.reset!
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/things/1.json", {}, @thing_json
      end
    end

    it "should cache a response" do
      result = Thing.find(1)
      CachedResource.config.cache.read("thing/1").should == result
    end

    it "should always remake the request" do
      Thing.find(1)
      ActiveResource::HttpMock.requests.length.should == 2
      Thing.find(1)
      ActiveResource::HttpMock.requests.length.should == 3
    end

    it "should rewrite the cache for each request" do
      old_result = CachedResource.config.cache.read("thing/1")

      # change the response
      ActiveResource::HttpMock.reset!
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/things/1.json", {}, @other_thing_json
      end

      Thing.find(1)
      new_result = CachedResource.config.cache.read("thing/1")
      # since active resources are equal if and only if they
      # are the same object or an instance of the same class,
      # not new?, and have the same id.
      new_result.name.should_not == old_result.name
    end
  end
end