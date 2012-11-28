require 'optparse'
require 'ostruct'
require 'parallel'

$:.push File.dirname(__FILE__) + '../'
require 'octosh'

module Octosh
  class CLI
    
    class MODE
      CONFIG = :config
      INLINE = :inline
      INTERACTIVE = :interactive
    end
    
    @password = nil
    
    def self.start
      options = {}
      
      # Default configuration
      options[:default_user] = "root"
      options[:password_prompt] = true
      options[:uniform_password] = false
      options[:forward_agent] = false
      options[:interactive] = false

      optparse = OptionParser.new do|opts|
        opts.banner = "Usage: octosh [options] [octo config file]"
        
        opts.on('-c', '--config FILE', 'Octo config file') do |file|
          options[:config] = file
        end
        
        opts.on('-i', '--interactive', 'Interactive shell prompt') do
          options[:interactive] = true
        end
          
        opts.on('-b', '--bash COMMAND', 'Explicitly define a command(s) to run on all hosts (Requires --hosts switch)') do |bash|
          options[:bash] = bash
        end
        
        opts.on('-s', '--script SCRIPT', 'Path to script to run on all hosts (Requires --hosts switch)') do |script|
          options[:script] = script
        end
        
        opts.on('-r', '--hosts USER@HOST,USER@HOST', Array, 'Lists of hosts to use when using inline execution (with -b or -s switches)') do |list|
          options[:hosts] = list
        end
        
        opts.on('-u', '--user USER', 'User to use when a user isn\'t defined in the --hosts list (ie. just IP address)') do |user|
          options[:default_user] = user
        end
        
        opts.on('-p', '--uniform-password', 'Uniform password') do
          options[:uniform_password] = true
        end
        
        opts.on('--forward-agent', 'Forward Agent') do
          options[:forward_agent] = true
        end
        
        opts.on_tail('-h', '--help', 'Display this screen' ) do
          puts opts
          exit
        end
      end.parse!
      
      if not ARGV.empty? and not options[:config]
        puts "Using config file"
        options[:config] = ARGV[0]
        options[:mode] = Octosh::CLI::MODE::CONFIG
      elsif ARGV.empty? and options[:config]
        puts "Using config file"
        options[:mode] = Octosh::CLI::MODE::CONFIG
      elsif not ARGV.empty? and options[:config]
        puts "Two config files specified (#{options[:config]} and #{ARGV[0]}), using explicit config file (#{options[:config]})"
        options[:mode] = Octosh::CLI::MODE::CONFIG
      elsif options[:interactive]
        puts "Interactive mode"
        options[:mode] = Octosh::CLI::MODE::INTERACTIVE
        shell = Octosh::Shell.new(options[:hosts], options)
        shell.start
      elsif (options[:bash] or options[:script]) and options[:hosts]
        puts "Using inline execution"
        options[:mode] = Octosh::CLI::MODE::INLINE
        
        if options[:bash] and options[:script]
          "Error -- Cannot specify both an inline command to run (-b) and a script file (-s)"
          exit
        elsif options[:bash]
          puts "Inline bash"
          self.inline_bash(options[:hosts], options[:bash], options[:default_user], options)
        elsif options[:script]
          puts "Call script on each server"
          self.exec_script(options[:hosts], options[:script], options[:default_user], options)
        else
          "Error -- Something broke"
          exit
        end
          
      else
        puts "Error -- Must either provide an Octo config file or arguments for inline execution (--hosts along with -b or -s)"
        exit
      end

    end
    
    def self.prompt_for_password(password_prompt, uniform_password, host="current host")
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
    
    def self.inline_bash(hosts, bash, user, options)
      workers = []
      
      hosts.each do |host|
        prompt_for_password(options[:password_prompt], options[:uniform_password])
        exec_user,hostname = ""
        if host.include? '@'
          # USer defined with host, override provided user
          exec_user,hostname = host.split('@')
        else
          exec_user = user
          hostname = host
        end
        
        worker = Octosh::Worker.new(hostname, exec_user, @password, options)
        workers << worker
      end
      
      Parallel.each(workers, :in_threads => workers.length) do |worker|
        #puts "#{worker.host} -- #{}"
        worker.exec(bash) do |output|
          puts "#{worker.host} -- #{output}"
        end
      end
    end
    
    def self.exec_script(hosts, script, user, options)
      workers = []
      
      hosts.each do |host|
        prompt_for_password(options[:password_prompt], options[:uniform_password])
        exec_user,hostname = ""
        if host.include? '@'
          # USer defined with host, override provided user
          exec_user,hostname = host.split('@')
        else
          exec_user = user
          hostname = host
        end
        worker = Octosh::Worker.new(hostname, exec_user, @password, options)
        workers << worker
      end
      
      Parallel.each(workers, :in_threads => workers.length) do |worker|
        worker.exec_script(script) do |output|
          puts "#{worker.host} -- #{output}"
        end
      end
      
    end
    
  end
end