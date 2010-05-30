require 'active_record'
require 'active_record/schema'
require 'hpricot'
require 'andand'
require 'open-uri'

db_config = YAML::load(File.open(File.dirname(__FILE__) + '/config/database.yml'))
ActiveRecord::Base.establish_connection(db_config['production'])

#
# These are the languages to install by default.
#
# We're not dumping them in all at once, because it seems
# some curation and inspection is necessary to prune the 
# lists into better shape
#
$Locales = ['en', 'es', 'fr', 'de', 'da', 'sv', 'pl', 'ru', 'it', 'cs', 'ja', 'pt', 'ro', 'fi', 'nl', 'tr','hu', 'uk']

desc "installs a clean version of the schema"
task :install do
  begin
    ActiveRecord::Schema.drop_table('geographiq_names')
  rescue
    nil
  end

  ActiveRecord::Schema.define do
    create_table "geographiq_names", :force => true do |t|
      t.column "category", :string, :limit => 80, :null => false
      t.column "is_basic", :boolean, :null => false
      t.column "endonym", :string, :limit => 64, :null => false
      t.column "exonym", :string, :limit => 64, :null => false
      t.column "native", :string, :limit => 140, :null => false
      t.column "romanized", :string, :limit => 140, :null => false
    end
  end  
end

desc "import collected text into active schema"
task :import => :install do
  require 'lib/geographiq'
  $Locales.each do |id|
    languages = File.open("lib/resources/languages/#{id}.txt")
    languages.readlines.each do |line|
      parts = line.split(':')
      item = Geographiq::Index::Name.new
      item.category = "languages"
      item.exonym = id
      item.endonym = parts[0].strip
      item.native = parts[1].strip
      item.romanized = parts[2] ? parts[2].strip : item.native
      item.is_basic = item.endonym.length == 2
      item.save
    end
  end
end

desc "download CLDR definition for supported locale"
task :collect, :lang do |t, args|
  cache_path = 'tmp/cldr.'+ args[:lang] + '.html'
  unless File.exists? cache_path
    sh "curl -o #{cache_path} http://unicode.org/repos/cldr-tmp/trunk/diff/summary/#{args[:lang]}.html"
  end
end

desc "pumps in data from CLDR table for supported locale"
task :extract do
  $Locales.each do |id|
    cldr_path = 'tmp/cldr.'+ id + '.html'
    languages_path = 'lib/resources/languages/'+ id + '.txt'
    territories_path = 'lib/resources/territories/'+ id + '.txt'

    html = open(cldr_path) { |f| Hpricot(f) }
    languages_txt = ""
    territories_txt = ""

    (html/"table[@border='1']//tr").each do |tr|
      # --
      meta_name = tr.at("td:nth(2)").andand.inner_html
      if meta_name == "language"
        iso_code = tr.at("td:nth(3)").inner_html
        if id == "en"
          term = tr.at("td:nth(4)").inner_html
        else
          span = tr.at("td:nth(5)//span")
          if span
            term = span.inner_html + ":" + span['title']
          else
            term = tr.at("td:nth(5)").inner_html
          end
        end
        languages_txt << iso_code + ":" + term + "\n"
      elsif meta_name == "territory"
        iso_code = tr.at("td:nth(3)")
        if id == "en"
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
end