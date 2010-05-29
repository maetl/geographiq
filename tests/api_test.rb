require 'test/unit'
require 'rubygems'
require 'rack/test'

require File.dirname(__FILE__) + '/../index'

class ApiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Geographiq::Application
  end

  def test_it_says_title
    get '/'
    assert last_response.ok?
    assert_equal 'Geographiq', last_response.body
  end
end