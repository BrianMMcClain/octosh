module Octosh
  class Worker
    
    attr_reader :host, :user
    
    def initalize(host, user)
      @host = host
      @user = user
    end
  
  end
end