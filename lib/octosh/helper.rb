module Octosh
  
  module OUTPUT_COLORS
    RED = 31
    GREEN = 32
    YELLOW = 33
    BLUE = 34
    MAGENTA = 35
    CYAN = 36
  end
  
  module COLORS
    COLORS = [Octosh::OUTPUT_COLORS::BLUE, Octosh::OUTPUT_COLORS::YELLOW, Octosh::OUTPUT_COLORS::GREEN, Octosh::OUTPUT_COLORS::MAGENTA, Octosh::OUTPUT_COLORS::CYAN]
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