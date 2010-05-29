require 'rubygems'
require 'sinatra/base'
require 'rack/conneg'

module Geographiq
  class Application < Sinatra::Base
    
    use(Rack::Conneg) do |conneg|
      conneg.set :accept_all_extensions, false
      conneg.set :fallback, :html
      #conneg.ignore_contents_of(File.join(File.dirname(__FILE__),'docs'))
      conneg.provide([:txt])
    end
    
    before do
      if negotiated?
        content_type negotiated_type
      end
    end
    
    get '/languages' do
      respond_to do |accept|
        accept.txt   { "Hello World" }
        accept.other {
          content_type 'text/plain'
          error 406, "Not Acceptable"
        }
      end
    end
    
  end
  
  class Documentation
    
    def initialize(path)
      @public_path = path
    end
    
    def generate
      
    end
    
  end
end