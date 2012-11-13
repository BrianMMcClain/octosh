require 'spec_helper'

describe Octosh::Worker do
  
  it "should instantiate" do
    worker = Octosh::Worker.new('127.0.0.1', 'bob', 'password')
    
    worker.should_not be_nil
    worker.host.should == '127.0.0.1'
    worker.user.should == 'bob'
    worker.password.should == 'password'
  end
  
end