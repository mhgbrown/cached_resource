require 'spec_helper'

describe CachedResource do

  before(:all) do
    class Thing < ActiveResource::Base
      self.site = "http://api.thing.com"
      cached_resource
    end

    @thing = {:thing => {:id => 1, :name => "Ada"}}
    @other_thing = {:thing => {:id => 1, :name => "Ari"}}
    @thing_json = @thing.to_json
    @other_thing_json = @other_thing.to_json
  end

  after(:all) do
    Thing.cached_resource.cache.clear
    Object.send(:remove_const, :Thing)
  end

  describe "when enabled" do
    before(:each) do
      # it's on by default, but lets call the method
      # to make sure it works
      Thing.cached_resource.cache.clear
      Thing.cached_resource.on!

      ActiveResource::HttpMock.reset!
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/things/1.json", {}, @thing_json
      end
    end

    it "should cache a response" do
      result = Thing.find(1)
      Thing.cached_resource.cache.read("thing/1").should == result
    end

    it "should read a response when the request is made again" do
      # make a request
      Thing.find(1)
      # make the same request
      Thing.find(1)
      # only one request should have happened
      ActiveResource::HttpMock.requests.length.should == 1
    end

    it "should remake a request when reloaded" do
      # make a request
      Thing.find(1)
      # make the same request, but reload it
      Thing.find(1, :reload => true)
      # we should get two requests
      ActiveResource::HttpMock.requests.length.should == 2
    end

    it "should rewrite the cache when the request is reloaded" do
      # make a request
      Thing.find(1)
      # get the cached result of the request
      old_result = Thing.cached_resource.cache.read("thing/1")

      # change the response
      ActiveResource::HttpMock.reset!
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/things/1.json", {}, @other_thing_json
      end

      Thing.find(1, :reload => true)
      new_result = Thing.cached_resource.cache.read("thing/1")
      # since active resources are equal if and only if they
      # are the same object or an instance of the same class,
      # not new?, and have the same id.
      new_result.name.should_not == old_result.name
    end

    it "should remake the request when the ttl expires" do
      # set cache time to live to 1 second
      Thing.cached_resource.ttl = 1
      # make a request
      Thing.find(1)
      # wait for the cache to expire
      sleep(1.5)
      # make the same request
      Thing.find(1)
      ActiveResource::HttpMock.requests.length.should == 2
    end

    describe "when collection synchronize is enabled" do
      before(:each) do
        Thing.cached_resource.cache.clear
        Thing.cached_resource.collection_synchronize = true

        ActiveResource::HttpMock.reset!
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/things/1.json", {}, @thing_json
          mock.get "/things.json", {}, [@thing[:thing]].to_json(:root => :thing)
        end

        # make a request for all things
        Thing.all
      end

      it "should write cache entries for its members" do
        result = Thing.find(1)
        # only the all request should have been made
        ActiveResource::HttpMock.requests.length.should == 1
        # the result should be cached with the appropriate key
        Thing.cached_resource.cache.read("thing/1").should == result
      end

      it "should rewrite cache entries for its members when reloaded" do
        # get the soon to be stale result so that we have a cache entry
        old_result = Thing.find(1)
        # change the server
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/things/1.json", {}, @other_thing_json
          mock.get "/things.json", {}, [@other_thing[:thing]].to_json(:root => :thing)
        end
        # reload the collection
        Thing.all(:reload => true)
        # get the updated result, read from the cache
        result = Thing.find(1)
        Thing.cached_resource.cache.read("thing/all")[0].should == result
        Thing.cached_resource.cache.read("thing/all")[0].name.should == result.name
      end

      it "should update the collection when an individual request is reloaded" do
        # change the server
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/things/1.json", {}, @other_thing_json
          mock.get "/things.json", {}, [@other_thing[:thing]].to_json(:root => :thing)
        end

        # reload the individual
        result = Thing.find(1, :reload => true)
        Thing.cached_resource.cache.read("thing/all")[0].should == result
        Thing.cached_resource.cache.read("thing/all")[0].name.should == result.name
      end

      it "should update both the collection and the member cache entries when a subset of the collection is retrieved" do
        # create cache entries for
        old_individual = Thing.find(1)
        old_collection = Thing.all

        # change the server
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/things.json?name=Ari", {}, [@other_thing[:thing]].to_json(:root => :thing)
        end

        # make a request for a subset of the "mother" collection
        result = Thing.find(:all, :params => {:name => "Ari"})
        # the collection should be updated to reflect the server change
        Thing.cached_resource.cache.read("thing/all")[0].should == result[0]
        Thing.cached_resource.cache.read("thing/all")[0].name.should == result[0].name
        # the individual should be updated to reflect the server change
        Thing.cached_resource.cache.read("thing/1").should == result[0]
        Thing.cached_resource.cache.read("thing/1").name.should == result[0].name
      end
    end

    describe "when collection synchronize is disabled" do
      before(:each) do
        Thing.cached_resource.cache.clear
        Thing.cached_resource.collection_synchronize = false

        ActiveResource::HttpMock.reset!
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/things/1.json", {}, @thing_json
          mock.get "/things.json", {}, [@thing[:thing]].to_json(:root => :thing)
        end

        # make a request for all things
        Thing.all
      end

      it "should not write cache entries for its members" do
        result = Thing.find(1)
        # both the all in the before each and this request should have been made
        ActiveResource::HttpMock.requests.length.should == 2
      end

      it "should not update the collection when an individual request is reloaded" do
        # change the server
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/things/1.json", {}, @other_thing_json
          mock.get "/things.json", {}, [@other_thing[:thing]].to_json(:root => :thing)
        end

        # reload the individual
        result = Thing.find(1, :reload => true)
        # the ids are the same, but the names should be different
        Thing.cached_resource.cache.read("thing/all")[0].name.should_not == result.name
      end
    end
  end

  describe "when disabled" do
    before(:each) do
      Thing.cached_resource.cache.clear
      Thing.cached_resource.off!

      ActiveResource::HttpMock.reset!
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/things/1.json", {}, @thing_json
      end
    end

    it "should cache a response" do
      result = Thing.find(1)
      Thing.cached_resource.cache.read("thing/1").should == result
    end

    it "should always remake the request" do
      Thing.find(1)
      ActiveResource::HttpMock.requests.length.should == 1
      Thing.find(1)
      ActiveResource::HttpMock.requests.length.should == 2
    end

    it "should rewrite the cache for each request" do
      Thing.find(1)
      old_result = Thing.cached_resource.cache.read("thing/1")

      # change the response
      ActiveResource::HttpMock.reset!
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/things/1.json", {}, @other_thing_json
      end

      Thing.find(1)
      new_result = Thing.cached_resource.cache.read("thing/1")
      # since active resources are equal if and only if they
      # are the same object or an instance of the same class,
      # not new?, and have the same id.
      new_result.name.should_not == old_result.name
    end
  end
end