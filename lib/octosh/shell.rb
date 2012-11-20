module Octosh
  class Shell
    
    @workers = []
    @password = nil
    
    def initialize(hosts, options)
      @workers = []
      hosts.each do |host|
        prompt_for_password(options[:password_prompt], options[:uniform_password])
        exec_user,hostname = ""
        if host.include? '@'
          # USer defined with host, override provided user
          exec_user,hostname = host.split('@')
        else
          exec_user = options[:default_user]
          hostname = host
        end
        worker = Octosh::Worker.new(hostname, exec_user, @password, options)
        worker.connect
        @workers << worker
      end
    end
    
    def prompt_for_password(password_prompt, uniform_password, host="current host")
      if password_prompt
        # Password authentication
        if uniform_password and @password.nil?
          # One password for all hosts
          @password = Octosh::Helper.password_prompt("Password: ")
        elsif not uniform_password
          # One password for each host
          @password = Octosh::Helper.password_prompt("Password for #{host}: ")
        end
      end
    end
    
    def start
      while true
        print ">> "
        command = gets
        Parallel.each(@workers, :in_threads => @workers.length) do |worker|
          puts "#{worker.host} -- #{worker.exec(command)}"
        end
      end
    end
  end
end