require 'colorize'

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
        puts worker.host.colorize(worker.options[:color].to_sym)
      end
      
      while true
        print ">> "
        command = ""
        begin
          command = gets.chomp!
        rescue Interrupt
          disconnect
          exit
        end
        preprocess_command(command || "")
        Parallel.each(@workers, :in_threads => @workers.length) do |worker|
          output = worker.exec(command) do |output|
            print output.colorize(worker.options[:color].to_sym)
          end
        end
      end
    end
    
    def preprocess_command(command)
      if command.downcase == "exit"
        disconnect
        exit
      end
    end
    
    def disconnect
      @workers.each do |worker|
        print "Closing connection to #{worker.host} . . . ".colorize(worker.options[:color].to_sym)
        worker.disconnect
        puts "OK".colorize(worker.options[:color].to_sym)
      end
    end
  end
end