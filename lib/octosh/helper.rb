module Octosh
  class Helper
    
    def self.password_prompt(prompt="Password: ")
      require 'highline/import'
      ask(prompt) do |p|
        p.echo = false
      end
    end
    
  end
end