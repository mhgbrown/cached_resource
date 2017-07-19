require 'spec_helper'

RSpec.describe CachedResource do
  before do
    class BaseThing < ActiveResource::Base
    end

    class FirstChildThing < BaseThing
      self.site = 'http://api.first-child-thing.com'
      cached_resource
    end

    class SecondChildThing < BaseThing
      self.site = 'http://api.second-child-thing.com'
    end
  end

  after do
    [:BaseThing, :FirstChildThing, :SecondChildThing].each do |klass|
      Object.send(:remove_const, klass)
    end
  end

  describe '.inherited' do
    it 'should include descendants when calling .descendants' do
      BaseThing.descendants.sort_by { |klass| klass.name }.should == [FirstChildThing, SecondChildThing]
    end
  end
end
