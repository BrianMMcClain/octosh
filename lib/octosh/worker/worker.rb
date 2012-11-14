require 'net/ssh'
require 'net/scp'
require 'uuid'
require 'pathname'

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
      channel = @ssh.open_channel do |ch|
        ch.exec(command) do |ch, success|
          raise "Error executing #{command}" unless success
          
          ch.on_data do |c, data|
            puts "#{@host} -- #{data.to_s}"
          end
          
          ch.on_extended_data do |c, type, data|
            puts "#{@host} -- #{data}"
          end
          
          ch.on_close do
            puts "Octosh execution complete!"
          end
        end
      end
      
      channel.wait
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
    
    def exec_script(script_path)
      tmp_script_name = "octosh-#{Pathname.new(script_path).basename.to_s}-#{UUID.new.generate}"
      self.put(script_path, "/tmp/#{tmp_script_name}")
      self.exec("chmod +x /tmp/#{tmp_script_name}")
      return self.exec("/tmp/#{tmp_script_name}")
    end
  end
end