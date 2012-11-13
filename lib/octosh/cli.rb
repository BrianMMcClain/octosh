require 'optparse'
require 'ostruct'

$:.push File.dirname(__FILE__) + '../'
require 'octosh'

module Octosh
  class CLI
    
    class MODE
      CONFIG = :config
      INLINE = :inline
    end
    
    def self.start
      options = OpenStruct.new

      optparse = OptionParser.new do|opts|
        opts.banner = "Usage: octosh [options] [octo config file]"
        
        opts.on('-c', '--config FILE', 'Octo config file') do |file|
          options.config = file
        end
        
        opts.on('-b', '--bash COMMAND', 'Explicitly define a command(s) to run on all hosts (Requires --hosts switch)') do |bash|
          options.bash = bash
        end
        
        opts.on('-s', '--script SCRIPT', 'Path to script to run on all hosts (Requires --hosts switch)') do |script|
          options.script = script
        end
        
        opts.on('-r', '--hosts USER@HOST,USER@HOST', Array, 'Lists of hosts to use when using inline execution (with -b or -s switches)') do |list|
          options.hosts = list
        end
        
        opts.on('-u', '--user', 'User to use when a user isn\'t defined in the --hosts list (ie. just IP address)') do |user|
          options.default_user = user
        end
        
        options.password_prompt = false
        opts.on('-p', '--password', 'Prompt for password') do
          options.password_prompt = true
        end
        
        options.uniform_password = false
        opts.on('-a', '--uniform-password', 'Use the same password for all hosts') do
          options.uniform_password = true
        end
        
        opts.on_tail('-h', '--help', 'Display this screen' ) do
          puts opts
          exit
        end
      end.parse!
      
      if not ARGV.empty? and not options.config
        options.config = ARGV[0]
        options.mode = Octosh::CLI::MODE::CONFIG
      elsif ARGV.empty? and options.config
        options.mode = Octosh::CLI::MODE::CONFIG
      elsif not ARGV.empty? and options.config
        puts "Two config files specified (#{options.config} and #{ARGV[0]}), using explicit config file (#{options.config})"
        options.mode = Octosh::CLI::MODE::CONFIG
      elsif (options.bash or options.script) and options.hosts
        puts "Using inline execution"
        options.mode = Octosh::CLI::MODE::INLINE
        
        if options.bash and options.script
          "Error -- Cannot specify both an inline command to run (-b) and a script file (-s)"
          exit
        elsif options.bash
          self.inline_bash(options.hosts, options.bash, options.password_prompt, options.uniform_password)
        elsif options.script
          pass
        else
          "Error -- Something broke"
          exit
        end
          
      else
        puts "Error -- Must either provide an Octo config file or arguments for inline execution (--hosts along with -b or -s)"
        exit
      end

    end
    
    def self.inline_bash(hosts, bash, password_prompt=true, uniform_password=false)
      
      password = nil
      
      hosts.each do |host|
        if password_prompt
          # Password authentication
          if uniform_password and password.nil?
            # One password for all hosts
            password = Octosh::Helper.password_prompt("Password: ")
          elsif not uniform_password
            # One password for each host
            password = Octosh::Helper.password_prompt("Password for #{host}: ")
          end
          user,hostname = host.split("@")
          worker = Octosh::Worker.new(hostname, user, password)
          puts worker.exec(bash)
        else
          # Identify file authentication
        end
      end
    end
    
  end
end