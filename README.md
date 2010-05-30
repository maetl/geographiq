Geographiq
==========

Un indice global géographique. Source code for the <http://geographiq.info> web service.

Dependencies
------------

Example configuration for **Gem Bundler**, which is confirmed to run on the **Heroku Bamboo** stack:

<pre>gem 'pg', :group => :production
gem 'sqlite3-ruby', :group => :development
gem 'sinatra'
gem 'activerecord', '3.0.0.beta', :require => 'active_record'
gem 'rack-conneg'
gem 'andand'
gem 'hpricot'</pre>

Note: **Hpricot** is only used for importing locale data in the Rakefile and is not needed for the app to run.

**ActiveRecord >= 3.0.0beta** is required as the app uses the new named scope features.

Installation
------------

<pre>local$ git clone maetl/geographiq geographiq
local$ cd geographiq</pre>

First, clear out any local database taples and load the default locale data:

<pre>local/geographiq$ rake import</pre>

Then start the app in preview mode using **Sinatra**:

<pre>local/geographiq$ ruby lib/geographiq.rb
== Sinatra/1.0 has taken the stage on 4567 for development with backup from WEBrick
[2010-05-30 17:31:10] INFO  WEBrick 1.3.1
[2010-05-30 17:31:10] INFO  ruby 1.8.7 (2009-06-12) [i686-darwin9]
[2010-05-30 17:31:10] INFO  WEBrick::HTTPServer#start: pid=76385 port=4567</pre>

Or bounce it up on **Rack**, perhaps using **Shotgun** (<http://github.com/rtomayko/shotgun>):

<pre>local/geographiq$ shotgun config.ru
== Shotgun starting Rack::Handler::WEBrick at http://localhost:9393
[2010-05-30 17:36:15] INFO  WEBrick 1.3.1
[2010-05-30 17:36:15] INFO  ruby 1.8.7 (2009-06-12) [i686-darwin9]
[2010-05-30 17:36:15] INFO  WEBrick::HTTPServer#start: pid=76776 port=9393</pre>

Live
----

<http://geographiq.info/>

Hosted on <http://heroku.com>

Credits
-------

(c) 2010, Mark Rickerby <http://maetl.net>