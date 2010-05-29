require 'test/unit'
require 'rubygems'
require 'rack/test'

require File.dirname(__FILE__) + '/../lib/geographiq'

class ApiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Geographiq::Application
  end

  def test_basic_languages_endonyms
    get '/languages.txt'
    assert last_response.ok?
    assert last_response.body.include? 'en;English'
    assert last_response.body.include? 'de;Deutsch'
  end

  def test_basic_languages_exonyms
    get '/languages/en.txt'
    assert last_response.ok?
    assert last_response.body.include? 'en;English'
    assert last_response.body.include? 'de;German'
  end 
  
  def test_all_languages_endonyms
    get '/languages/all.txt'
    assert last_response.ok?
    assert last_response.body.include? 'de;Deutsch'
  end
  
  def test_all_languages_exonyms
    get '/languages/all/de.txt'
    assert last_response.ok?
    assert last_response.body.include? 'nap;Neapolitanisch'
  end
  
end