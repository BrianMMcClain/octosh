module Octosh

  module COLORS
    COLORS = [:default, :blue, :green, :yellow, :red, :magenta, :cyan, :white, :light_black, :light_red, :light_green, :light_yellow, :light_blue, :light_magenta, :light_cyan]
  end
  
  class Helper
    
    def self.password_prompt(prompt="Password: ")
      require 'highline/import'
      ask(prompt) do |p|
        p.echo = false
      end
    end
    
  end
end