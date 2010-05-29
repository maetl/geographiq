require 'sinatra/base'
require 'rack/conneg'
require 'active_record'
require 'yaml'

db_config = YAML::load(File.open(File.dirname(__FILE__) + '/../config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)

module Geographiq
  class Application < Sinatra::Base
    
    use(Rack::Conneg) do |negotiator|
      negotiator.set :accept_all_extensions, false
      negotiator.set :fallback, :html
      negotiator.provide([:txt, :json])
    end
    
    before do
      if negotiated?
        content_type negotiated_type
      end
    end
    
    get '/languages' do
      respond_with Index::Name.languages.basic.where('exonym = endonym')
    end
    
    get '/languages/all' do
      respond_with Index::Name.languages.where('exonym = endonym')
    end
    
    get '/languages/:id' do
      respond_with Index::Name.languages.basic.where(:exonym => params[:id])
    end
    
    get '/languages/all/:id' do
      respond_with Index::Name.languages.where(:exonym => params[:id])
    end
    
    get '/languages/romanized/:id' do
      if ['ru', 'ja'].include? params[:id]
        respond_with Index::Name.languages.basic.where(:exonym => params[:id])
      else
        content_type 'text/plain'
        error 404, "Not Available"
      end
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
        [obj.endonym, obj.term].join(';') + "\n"
      end
    end
    
    def render_json relation
      collection = Hash.new
      relation.each do |obj|
        collection.store(obj.endonym, obj.term)
      end
      collection.to_s
    end
    
  end
  
  module Index
    
    class Name < ActiveRecord::Base
      set_table_name :geographiq_names_index
      scope :languages, where(:category => 'languages')
      scope :basic, where(:is_basic => true)
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