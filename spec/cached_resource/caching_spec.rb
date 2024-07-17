require "spec_helper"

CACHE = ActiveSupport::Cache::MemoryStore.new

class Thing < ActiveResource::Base
  self.site = "http://api.thing.com"
  cached_resource
end

class NotTheThing < ActiveResource::Base
  self.site = "http://api.notthething.com"
  cached_resource
end

def read_from_cache(key, model = Thing)
  model.send(:cache_read, key)
end

describe CachedResource::Caching do
  let(:thing) { {thing: {id: 1, name: "Ada"}} }
  let(:thing_collection) { [{id: 1, name: "Ada"}, {id: 2, name: "Ada", major: "CS"}] }
  let(:thing_collection2) { [{id: 2, name: "Ada", major: "CS"}] }
  let(:other_thing) { {thing: {id: 1, name: "Ari"}} }
  let(:thing2) { {thing: {id: 2, name: "Joe"}} }
  let(:other_thing2) { {thing: {id: 2, name: "Jeb"}} }
  let(:thing3) { {thing: {id: 3, name: "Stu"}} }
  let(:string_thing) { {thing: {id: "fded", name: "Lev"}} }
  let(:other_string_thing) { {thing: {id: "fded", name: "Lon"}} }
  let(:date_thing) { {thing: {id: 4, created_at: DateTime.new(2020)}} }
  let(:nil_thing) { nil.to_json }
  let(:empty_array_thing) { [].to_json }
  let(:not_the_thing) { {not_the_thing: {id: 1, name: "Not"}} }
  let(:not_the_thing_collection) { [{not_the_thing: {id: 1, name: "Not"}}] }

  let(:thing_cached_resource) do
    double(:thing_cached_resource,
      cache_collections: true,
      cache_key_prefix: nil,
      cache: CACHE,
      collection_arguments: [:all],
      collection_synchronize: false,
      enabled: true,
      generate_ttl: 604800,
      logger: double(:thing_logger, info: nil, error: nil),
      race_condition_ttl: 86400,
      ttl_randomization_scale: 1..2,
      ttl_randomization: false,
      ttl: 604800)
  end

  let(:not_the_thing_cached_resource) do
    double(:not_the_thing_cached_resource,
      cache_collections: true,
      cache_key_prefix: nil,
      cache: CACHE,
      collection_arguments: [:all],
      collection_synchronize: false,
      enabled: true,
      generate_ttl: 604800,
      logger: double(:not_the_thing_logger, info: nil, error: nil),
      race_condition_ttl: 86400,
      ttl_randomization_scale: 1..2,
      ttl_randomization: false,
      ttl: 604800)
  end

  before do
    CACHE.clear
    allow(Thing).to receive(:cached_resource).and_return(thing_cached_resource)
    allow(NotTheThing).to receive(:cached_resource).and_return(not_the_thing_cached_resource)
    ActiveResource::HttpMock.reset!
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/things/1.json", {}, thing.to_json
      mock.get "/things/1.json?foo=bar", {}, thing.to_json
      mock.get "/things/fded.json", {}, string_thing.to_json
      mock.get "/things.json?name=42", {}, nil_thing, 404
      mock.get "/things.json?name=43", {}, empty_array_thing
      mock.get "/things/4.json", {}, date_thing.to_json
      mock.get "/not_the_things/1.json", {}, not_the_thing.to_json
      mock.get "/things.json", {}, thing_collection.to_json
      mock.get "/not_the_things.json", {}, not_the_thing_collection.to_json
    end
  end

  context "when caching is enabled" do
    before do
      allow(thing_cached_resource).to receive(:enabled).and_return(true)
      allow(not_the_thing_cached_resource).to receive(:enabled).and_return(true)
    end

    context "Caching single resource" do
      it "caches a response" do
        result = Thing.find(1)
        Thing.find(1)
        expect(read_from_cache("thing/1")).to eq(result)
        expect(ActiveResource::HttpMock.requests.length).to eq(1)
      end

      it "caches without whitespace in keys" do
        result = Thing.find(1, from: "path", params: {foo: "bar"})
        expect(read_from_cache('thing/1/{:from=>"path",:params=>{:foo=>"bar"}}')).to eq(result)
      end

      it "empties the cache when clear_cache is called" do
        Thing.find(1)
        expect { Thing.clear_cache }.to change { read_from_cache("thing/1") }.from(kind_of(Thing)).to(nil)
      end

      it "does not empty cache of other ActiveResource objects" do
        Thing.find(1)
        NotTheThing.find(1)
        expect { Thing.clear_cache }.to change { read_from_cache("thing/1") }.from(kind_of(Thing)).to(nil).and(
          not_change { read_from_cache("notthething/1", NotTheThing) }
        )
      end

      it "empties all shared cache when clear_cache is called on Thing with :all option set" do
        Thing.find(1)
        NotTheThing.find(1)
        expect { Thing.clear_cache(all: true) }.to change { read_from_cache("thing/1") }.to(nil).and(
          change { read_from_cache("notthething/1", NotTheThing) }.to(nil)
        )
      end

      it "caches a response with the same persistence" do
        result1 = Thing.find(1)
        expect(result1.persisted?).to be true
        result2 = Thing.find(1)
        expect(result2.persisted?).to eq(result1.persisted?)
      end

      it "remakes a request when reloaded" do
        Thing.find(1)
        expect { Thing.find(1, reload: true) }.to change(ActiveResource::HttpMock.requests, :length).from(1).to(2)
      end

      it "rewrites the cache when the request is reloaded" do
        Thing.find(1)
        old_result = read_from_cache("thing/1").dup

        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/things/1.json", {}, other_thing.to_json
        end

        expect { Thing.find(1, reload: true) }.to change { read_from_cache("thing/1").name }.from(old_result.name)
      end

      it "does not return a frozen object on first request, or subsequent" do
        result1 = Thing.find(1)
        expect(result1).not_to be_frozen
        expect(Thing.find(1)).not_to be_frozen
        expect(result1).not_to be_frozen
      end
    end

    context "Caching a collection" do
      it "does not cache an empty array response" do
        Thing.find(:all, params: {name: "43"})
        expect(read_from_cache("thing/all/name/43")).to be_nil
      end

      it "does not cache a nil response" do
        Thing.find(:all, params: {name: "42"})
        expect(read_from_cache("thing/all/name/42")).to be_nil
      end

      it "empties the cache when clear_cache is called" do
        Thing.all
        expect { Thing.clear_cache }.to change { read_from_cache("thing/all") }.from(kind_of(Enumerable)).to(nil)
      end

      it "does not empty cache of other ActiveResource objects" do
        Thing.all
        NotTheThing.all
        expect { Thing.clear_cache }.to change { read_from_cache("thing/all") }.from(kind_of(Enumerable)).to(nil).and(
          not_change { read_from_cache("notthething/all", NotTheThing) }
        )
      end

      it "remakes a request when reloaded" do
        Thing.all
        expect { Thing.all(reload: true) }.to change(ActiveResource::HttpMock.requests, :length).from(1).to(2)
      end
    end

    context "Caching collection is turned off" do
      before do
        allow(thing_cached_resource).to receive(:cache_collections).and_return(false)
      end

      it "always remakes a request" do
        Thing.all
        expect { Thing.all }.to change(ActiveResource::HttpMock.requests, :length).from(1).to(2)
      end

      context "custom collection arguments" do
        before do
          allow(thing_cached_resource).to receive(:collection_arguments).and_return([:all, params: {name: 42}])
        end

        it "checks for custom collection arguments" do
          Thing.all
          expect { Thing.find(:all, params: {name: 42}) }.to change(ActiveResource::HttpMock.requests, :length).from(1).to(2)
        end
      end
    end

    context "TTL" do
      let(:now) { Time.new(1999, 12, 31, 12, 0, 0) }
      let(:travel_seconds) { 1000 }

      before do
        Timecop.freeze(now)
        allow(thing_cached_resource).to receive(:generate_ttl).and_return(travel_seconds)
      end

      after do
        Timecop.return
      end

      it "remakes the request when the ttl expires" do
        expect { Thing.find(1) }.to change { ActiveResource::HttpMock.requests.length }.from(0).to(1)
        Timecop.travel(now + travel_seconds)
        expect { Thing.find(1) }.to change { ActiveResource::HttpMock.requests.length }.from(1).to(2)
      end
    end

    context "when cache prefix is set" do
      context "cache_key_prefix is a string" do
        before { allow(thing_cached_resource).to receive(:cache_key_prefix).and_return("prefix123") }
        it "caches with the cache_key_prefix" do
          result = Thing.find(1)
          expect(read_from_cache("prefix123/thing/1")).to eq(result)
        end
      end

      context "cache_key_prefix is a callable" do
        before do
          allow(thing_cached_resource).to receive(:cache_key_prefix).and_return(proc { "prefix123" })
        end

        it "caches with the cache_key_prefix" do
          result = Thing.find(1)
          expect(read_from_cache("prefix123/thing/1")).to eq(result)
          allow(thing_cached_resource).to receive(:cache_key_prefix).and_return(proc { "prefix456" })
          result = Thing.find(1, reload: true)
          expect(read_from_cache("prefix456/thing/1")).to eq(result)
        end
      end
    end

    context "when ActiveSupport.parse_json_times is enabled" do
      before(:all) do
        Time.zone = "UTC"
        ActiveSupport.parse_json_times = true
      end

      after(:all) do
        ActiveSupport.parse_json_times = false
        Time.zone = nil
      end

      it "returns a time object when a time attribute is present in the response" do
        result = Thing.find(4)
        expect(result.created_at).to be_a(Time)
      end
    end

    context "cache_collection_synchronize" do
      before do
        allow(thing_cached_resource).to receive(:collection_synchronize).and_return(true)
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/things/1.json", {}, thing.to_json
          mock.get "/things.json", {}, [thing2[:thing], other_string_thing[:thing]].to_json
        end
      end

      it "should rewrite cache entries for its members when reloaded" do
        old_results = Thing.all(reload: true)
        # Update response
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/things/1.json", {}, other_thing.to_json
        end

        new_result = Thing.find(1, reload: true)

        expect(old_results).not_to include(new_result)
        expect(read_from_cache("thing/all")).to include(new_result)
      end
    end

    context "Cache clearing" do
      it "clears the cache" do
        Thing.find(1)
        expect { Thing.clear_cache }.to change { read_from_cache("thing/1") }.to(nil)
      end
    end
  end

  context "when caching is disabled" do
    before do
      allow(thing_cached_resource).to receive(:enabled).and_return(false)
      allow(not_the_thing_cached_resource).to receive(:enabled).and_return(false)
    end

    it "does not cache a response" do
      Thing.find(1)
      expect(read_from_cache("thing/1")).to be_nil
    end

    it "does not cache a nil response" do
      Thing.find(:all, params: {name: "42"})
      expect(read_from_cache("thing/all/name/42")).to be_nil
    end

    it "does not cache an empty array response" do
      Thing.find(:all, params: {name: "43"})
      expect(read_from_cache("thing/all/name/43")).to be_nil
    end
  end

  describe ".cache_key_delete_pattern" do
    let(:cache_class) { "Redis" }

    before do
      allow(Thing.cached_resource).to receive(:cache).and_return(cache_class)
    end

    context "with cache ActiveSupport::Cache::MemoryStore" do
      let(:cache_class) { ActiveSupport::Cache::MemoryStore.new }
      it do
        expect(Thing.send(:cache_key_delete_pattern)).to eq(/^thing\//)
      end
    end

    context "with cache ActiveSupport::Cache::FileStore" do
      let(:cache_class) { ActiveSupport::Cache::FileStore.new("tmp/") }
      it do
        expect(Thing.send(:cache_key_delete_pattern)).to eq(/^thing\//)
      end
    end

    context "default" do
      it do
        expect(Thing.send(:cache_key_delete_pattern)).to eq("thing/*")
      end
    end
  end

  describe ".clear_cache" do
    it "clears the cache immediately" do
      expect(thing_cached_resource.cache).to receive(:delete_matched)
      expect(Thing.clear_cache).to be true
      expect(thing_cached_resource.logger).to have_received(:info).with(/CLEAR/)
    end

    context "when options are provided" do
      it "clears all cache if options[:all] is true" do
        options = {all: true}
        expect(thing_cached_resource.cache).to receive(:clear).and_call_original
        Thing.clear_cache(options)
      end

      it "deletes matched cache keys if options[:all] is not provided" do
        options = {all: false}
        allow(thing_cached_resource.cache).to receive(:delete_matched)
        Thing.clear_cache(options)
        expect(thing_cached_resource.cache).to have_received(:delete_matched)
      end
    end

    context 'when using a cache store that does not support "delete_matched"' do
      before do
        mem_cache_store = double(:cache_store_without_delete_matched, clear: nil)
        allow(thing_cached_resource).to receive(:cache).and_return(mem_cache_store)
      end

      it "clears the cache if Dalli is defined" do
        expect(thing_cached_resource.cache).to receive(:clear)
        Thing.clear_cache
        expect(thing_cached_resource.logger).to have_received(:info).with(/CLEAR ALL/)
      end
    end
  end
end
