require 'sinatra'
require 'rack/conneg'
require 'active_record'
require 'yaml'

db_config = YAML::load(File.open(File.dirname(__FILE__) + '/../config/database.yml'))
ActiveRecord::Base.establish_connection(db_config['production'])

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
      respond_with Index::Name.languages.basic.asc.where('exonym = endonym')
    end
    
    get '/languages/all' do
      respond_with Index::Name.languages.asc.where('exonym = endonym')
    end
    
    get '/languages/:id' do
      respond_with Index::Name.languages.asc.basic.where(:exonym => params[:id])
    end
    
    get '/languages/all/:id' do
      respond_with Index::Name.languages.asc.where(:exonym => params[:id])
    end
    
    get '/states' do
      
    end
    
    get '/countries' do
      
    end
    
    get '/regions' do
      
    end
    
    get '/languages/romanize/:id' do
      if ['ru', 'ja', 'uk'].include? params[:id]
        respond_with Index::Name.languages.basic.asc.where(:exonym => params[:id]), :ascii
      else
        content_type 'text/plain'
        error 404, "Unavailable format"
      end
    end
    
    def respond_with relation, type = :native
      respond_to do |accept|
        accept.txt    { render_txt  relation, type }
        accept.json   { render_json relation, type }
        accept.other {
          content_type 'text/plain'
          error 406, "Unsupported type"
        }
      end
    end
    
    def render_txt relation, type
      relation.collect do |obj|
        [obj.endonym, obj.read_attribute(type)].join(';') + "\n"
      end
    end
    
    def render_json relation, type
      collection = Hash.new
      relation.each do |obj|
        collection.store(obj.endonym, obj.read_attribute(type))
      end
      collection.to_s
    end
    
  end
  
  module Index
    
    class Name < ActiveRecord::Base
      set_table_name :geographiq_names_index
      scope :languages, where(:category => 'languages')
      scope :basic, where(:is_basic => true)
      scope :asc, order('endonym ASC')
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
