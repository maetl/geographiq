require 'active_record'
require 'active_record/schema'
require 'hpricot'
require 'andand'
require 'open-uri'

db_config = YAML::load(File.open(File.dirname(__FILE__) + '/config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)

namespace :schema do
  
  desc "installs a clean version of the schema"
  task :install do
    begin
      ActiveRecord::Schema.drop_table('names')
    rescue
      nil
    end

    ActiveRecord::Schema.define do
      create_table "names", :force => true do |t|
        t.column "term", :string, :limit => 140, :null => false
        t.column "category", :string, :limit => 80, :null => false
        t.column "is_basic", :boolean
        t.column "endonym", :string, :limit => 5, :null => false
        t.column "exonym", :string, :limit => 5, :null => false
      end
    end  
  end
  
  desc "import collected text into active schema"
  task :import do
    
  end
  
end

namespace :lang do
  
  desc "wipe temporary data files"
  task :trash do
    sh "rm -rf tmp/*"  
  end
  
  desc "download CLDR definition for supported locale"
  task :collect, :lang do |t, args|
    cache_path = 'tmp/cldr.'+ args[:lang] + '.html'
    unless File.exists? cache_path
      sh "curl -o #{cache_path} http://unicode.org/repos/cldr-tmp/trunk/diff/summary/#{args[:lang]}.html"
    end
  end
  
  desc "pumps in data from CLDR table for supported locale"
  task :extract, :lang do |t, args|

    cldr_html = 'tmp/cldr.'+ args[:lang] + '.html'
    cldr_txt = 'tmp/cldr.'+ args[:lang] + '.txt'

    html = open(cldr_html) { |f| Hpricot(f) }
    txt = ""

    (html/"table[@border='1']//tr").each do |tr|
      
      meta_name = tr.at("td:nth(2)")
      if meta_name.andand.inner_html == "language"
        iso_code = tr.at("td:nth(3)")
        if args[:lang] == "en"
          term = tr.at("td:nth(4)")
        else
          term = tr.at("td:nth(5)")
        end
        txt << iso_code.inner_html + ":" + term.inner_html + "\n"
      end
      
    end
    
    File.open(cldr_txt, 'w') {|f| f.write(txt) }
  end
  
end