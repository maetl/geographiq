require 'rubygems'
require 'sinatra/base'

module Geographiq
  class Application < Sinatra::Base
    get '/' do
      "Geographiq"
    end
  end
end