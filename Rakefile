require 'active_record'
require 'active_record/schema'
require 'hpricot'
require 'andand'
require 'open-uri'

db_config = YAML::load(File.open(File.dirname(__FILE__) + '/config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)

$Locales = ['en', 'es', 'fr', 'de']

desc "installs a clean version of the schema"
task :install do
  begin
    ActiveRecord::Schema.drop_table('geographiq_names')
  rescue
    nil
  end

  ActiveRecord::Schema.define do
    create_table "geographiq_names", :force => true do |t|
      t.column "term", :string, :limit => 140, :null => false
      t.column "category", :string, :limit => 80, :null => false
      t.column "is_basic", :boolean, :null => false
      t.column "endonym", :string, :limit => 64, :null => false
      t.column "exonym", :string, :limit => 64, :null => false
    end
  end  
end

desc "import collected text into active schema"
task :import => :install do
  require 'app/geographiq'
  $Locales.each do |id|
    languages = File.open("tmp/languages.#{id}.txt")
    languages.readlines.each do |line|
      parts = line.split(':')
      language = Geographiq::Index::Name.new
      language.category = "languages"
      language.exonym = id
      language.endonym = parts[0]
      language.term = parts[1].strip
      language.is_basic = language.endonym.length == 2
      language.save
    end
  end
end

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

  cldr_path = 'tmp/cldr.'+ args[:lang] + '.html'
  languages_path = 'tmp/languages.'+ args[:lang] + '.txt'
  territories_path = 'tmp/territories.'+ args[:lang] + '.txt'

  html = open(cldr_path) { |f| Hpricot(f) }
  languages_txt = ""
  territories_txt = ""

  (html/"table[@border='1']//tr").each do |tr|
    # --
    meta_name = tr.at("td:nth(2)").andand.inner_html
    if meta_name == "language"
      iso_code = tr.at("td:nth(3)")
      if args[:lang] == "en"
        term = tr.at("td:nth(4)")
      else
        term = tr.at("td:nth(5)")
      end
      languages_txt << iso_code.inner_html + ":" + term.inner_html + "\n"
    elsif meta_name == "territory"
      iso_code = tr.at("td:nth(3)")
      if args[:lang] == "en"
        term = tr.at("td:nth(4)")
      else
        term = tr.at("td:nth(5)")
      end
      territories_txt << iso_code.inner_html + ":" + term.inner_html + "\n"
    end
    # --
  end
  
  File.open(languages_path, 'w') {|f| f.write(languages_txt) }
  File.open(territories_path, 'w') {|f| f.write(territories_txt) }
end