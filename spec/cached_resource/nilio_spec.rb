require 'spec_helper'

describe CachedResource::NilIO do
  before(:all) do
    @null_device = CachedResource::NilIO.new
  end

  it "should discard any data written" do
    @null_device.write("I am writing something")
    @null_device.readlines.should be_blank
  end

  it "should provide no data when read" do
    @null_device.read(200).should == nil
  end

  it "should report EOF" do
    @null_device.eof?.should == true
  end
end