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
        
        opts.on_tail('-h', '--help', 'Display this screen' ) do
          puts opts
          exit
        end
      end.parse!
      
      puts options.config
      
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
      else
        puts "Error -- Must either provide an Octo config file or arguments for inline execution (--hosts along with -b or -s)"
        exit
      end
      
      puts options.inspect
    end
  end
end