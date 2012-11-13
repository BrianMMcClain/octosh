require 'optparse'
require 'ostruct'

module Octosh
  class CLI
    def self.start
      options = OpenStruct.new

      optparse = OptionParser.new do|opts|
        opts.banner = "Usage: octosh [options]"
        
        opts.on( '-s', '--script', 'Run a bash script on every host') do | script |
          options.script = script
          
          if options.script and options.command
            puts "Error: Cannot specify both a script and a command to run"
            exit
          end
        end
        
        opts.on( '-c', '--comand', 'Command to run on every host' ) do | command |
          options.command = command
          
          if options.script and options.command
            puts "Error: Cannot specify both a script and a command to run"
            exit
          end
        end
        
        opts.on_tail( '-h', '--help', 'Display this screen' ) do
          puts opts
          exit
        end
      end.parse!
    end
  end
end