require 'sinatra/base'
require 'rack/conneg'
require 'active_record'
require 'yaml'

db_config = YAML::load(File.open(File.dirname(__FILE__) + '/../config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)

module Geographiq
  class Application < Sinatra::Base
    
    use(Rack::Conneg) do |conneg|
      conneg.set :accept_all_extensions, false
      conneg.set :fallback, :html
      conneg.provide([:txt, :json])
    end
    
    before do
      if negotiated?
        content_type negotiated_type
      end
    end
    
    get '/languages' do
      languages = Index::Name.languages.where('exonym = endonym')
      respond_with languages
    end
    
    get '/languages/:id' do
      languages = Index::Name.languages.where(:exonym => params[:id])
      respond_with languages
    end
    
    def respond_with relation
      respond_to do |accept|
        accept.txt    { render_txt  relation }
        accept.json   { render_json relation }
        accept.other {
          content_type 'text/plain'
          error 406, "Not Acceptable"
        }
      end      
    end
    
    def render_txt relation
      relation.collect do |obj|
        [obj.endonym, obj.term].join(':') + "\n"
      end
    end
    
    def render_json relation
      collection = { }
      relation.each do |obj|
        collection << { obj.endonym => obj.term }
      end
    end
    
  end
  
  module Index
    
    class Name < ActiveRecord::Base
      scope :languages, where(:category => 'languages')
    end
    
  end
  
  class Documentation
    
    def initialize(path)
      @public_path = path
    end
    
    def generate
      # does nothing yet
    end
    
  end
end