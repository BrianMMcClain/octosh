require 'net/ssh'
require 'net/scp'
require 'uuid'
require 'pathname'

module Octosh  
  class Worker
    
    attr_reader :host, :user, :password, :ssh, :options
        
    @connected = false
    
    def initialize(host, user, pass, options = {})
      @host = host
      @user = user
      @password = pass
      @options = options
    end
    
    def connected?
      return @connected
    end
    
    def connect_if_not_connected
      if not connected?
        connect
      end
    end
    
    def connect
      if not connected?
        forward_agent = @options[:forward_agent] || false
        @ssh = Net::SSH.start(@host, @user, :password => @password, :forward_agent => forward_agent)
        @connected = true
        return true
      end
      
      return false
    end
    
    def disconnect
      if connected?
        @ssh.close
        @ssh = nil
        @connected = false
        return true
      end
      
      return false
    end
    
    def exec(command)
      connect_if_not_connected
      channel = @ssh.open_channel do |ch|
        ch.exec(command) do |ch, success|
          raise "Error executing #{command}" unless success
          
          ch.on_data do |c, data|
            if block_given?
              yield data.to_s
            else
              puts data.to_s
            end
          end
          
          ch.on_extended_data do |c, type, data|
            return data.to_s
          end
          
          ch.on_close do
            # For now do nothing
          end
        end
      end
      
      channel.wait
    end
    
    def put(local_path, remote_path)
      connect_if_not_connected      
      @ssh.scp.upload!(local_path, remote_path)
    end
    
    def get(remote_path, local_path)
      connect_if_not_connected
      @ssh.scp.download!(remote_path, local_path)
    end
    
    def read(remote_path)
      connect_if_not_connected
      return @ssh.scp.download!(remote_path)
    end
    
    def exec_script(script_path)
      tmp_script_name = "octosh-#{Pathname.new(script_path).basename.to_s}-#{UUID.new.generate}"
      self.put(script_path, "/tmp/#{tmp_script_name}")
      self.exec("chmod +x /tmp/#{tmp_script_name}")
      self.exec("/tmp/#{tmp_script_name}") do |output|
        if block_given?
          yield output
        else
          puts output
        end
      end
    end
  end
end