module Octosh
  
  module Commands
    GET = :get
    PUT = :put
    EXIT = :exit
  end
  
  class Shell
    
    @workers = []
    @password = nil
    
    def initialize(hosts, options)
      colors = Octosh::COLORS::COLORS.dup
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
        worker_options = options.dup
        worker_options[:color] = colors.shift
        colors << worker_options[:color]
        worker = Octosh::Worker.new(hostname, exec_user, @password, worker_options)
        worker.connect
        @workers << worker
      end
    end
    
    def colorize(text, color_code)
      "\e[#{color_code}m#{text}\e[0m"
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
      
      puts "Starting Octoshell connected to #{@workers.length} hosts"
      @workers.each do |worker|
        puts "   #{colorize(worker.host, worker.options[:color])}"
      end
      
      while true
        print ">> "
        command = gets
        Parallel.each(@workers, :in_threads => @workers.length) do |worker|
          print colorize(worker.exec(command), worker.options[:color])
        end
      end
    end
  end
end