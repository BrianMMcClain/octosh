require 'net/ssh'
require 'net/scp'

module Octosh
  class Worker
    
    attr_reader :host, :user, :password, :ssh
    
    def initialize(host, user, pass)
      @host = host
      @user = user
      @password = pass
      
      @ssh = Net::SSH.start(@host, @user, :password => @password)
    end
    
    def exec(command)
      return @ssh.exec!(command)
    end
    
    def put(local_path, remote_path)
      @ssh.scp.upload!(local_path, remote_path)
    end
    
    def get(remote_path, local_path)
      @ssh.scp.download!(remote_path, local_path)
    end
    
    def read(remote_path)
      return @ssh.scp.download!(remote_path)
    end
  end
end