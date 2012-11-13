module Octosh
  class Worker
    
    attr_reader :host, :user, :password
    
    def initialize(host, user, pass)
      @host = host
      @user = user
      @password = pass
    end
    
    def exec(command)
      output = ""
      Net::SSH.start(@host, @user, :password => @password) do |ssh|
        output = ssh.exec!(command)
      end
      
      return output
    end
  end
end