require 'spec_helper'

describe Octosh::Worker do
  
  it "should instantiate" do
    worker = Octosh::Worker.new('127.0.0.1', 'bob', 'password')
    
    worker.should_not be_nil
    worker.host.should == '127.0.0.1'
    worker.user.should == 'bob'
    worker.password.should == 'password'
  end
  
  it "should #connect_if_not_connected" do
    worker = Octosh::Worker.new('127.0.0.1', 'bob', 'password')
    
    Net::SSH.should_receive(:start).with("127.0.0.1", "bob", :password => "password", :forward_agent=>false)
    worker.connect_if_not_connected
  end
  
  it "should #exec a command" do
    worker = Octosh::Worker.new('127.0.0.1', 'bob', 'password')
    worker.should_receive(:exec)
    worker.exec("date")
  end
  
  it "should #exec_script" do
    worker = Octosh::Worker.new('127.0.0.1', 'bob', 'password')
    worker.should_receive(:put).with("/tmp/somescript.sh", kind_of(String))
    worker.should_receive(:exec).with(kind_of(String))
    worker.should_receive(:exec).with(kind_of(String))
    
    worker.exec_script("/tmp/somescript.sh")
  end
end