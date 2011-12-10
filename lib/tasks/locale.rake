Bundler.require :development
require 'fileutils'

LOCALES="en,zh-CN"
DEFAULT='zh-CN'

namespace :locale do

  # TODO create en.yml then cp to other-lang.yml 
  desc "create models/<model>/en.yml. not overwrite existing data."
  task :create  => :environment do
    ActiveRecord::Base.connection.tables.each do |name|
      # model_name
      model_name = name.singularize
      locale = "en"

      # model_keys
      begin
        model = model_name.camelize.constantize 
      rescue NameError
        next
      end

      cols = model.content_columns
      cols.delete_if {|c| %w[created_at updated_at].include? c.name}
      model_keys = cols.map {|c| c.name}

      file = "config/locales/models/#{model_name}/#{locale}.yml"
      puts "create #{file}"
      FileUtils.mkdir_p File.dirname(file) rescue Errno::EEXIST

      data = File.exists?(file) ? YAML.load(open(file)) : {}
      yaml = generate_yaml(data, locale, model_name, model_keys)

      open(file, "w"){|f| f.write(yaml)}
    end
  end

  # thread problem
  # rake aborted!
  # SSL_connect SYSCALL returned=5 errno=0 state=SSLv2/v3 read server hello A
  desc "translate config/locales/views by google translator based on DEFAULT. not overwrite existing data" 
  task :translate => :environment do
    ToLang.start('AIzaSyBXwbwOuNbWl9EG6ZZWCEkjlka84FskcHk')
    # arguments
    locales = (ENV["LOCALE"] || LOCALES).split(',') - [DEFAULT]
    dir = ENV["DIR"] || "views"

    threads = []
    locales.each do |locale|
      threads << Thread.new do
        Dir["config/locales/#{dir}/**/#{DEFAULT}.yml"].each do |file_en|

          file = File.dirname(file_en) + "/#{locale}.yml"
          puts "translating #{file} ..."

          FileUtils.mkdir_p File.dirname(file) rescue Errno::EEXIST

          data_en = YAML.load(open(file_en))[DEFAULT]
          data = File.exists?(file) ? ((y=YAML.load(open(file))) ? y : {}) : {}
          data = data[locale] ? data[locale] : {} 

          # merge and translate
          data = each_r(data_en, data) do |v1, v2|
            v2 ? v2 : translate(v1, locale) 
          end
          data = {locale => data }

          # generate_yaml
          open(file, "w"){|f| f.write(data.ya2yaml)}

          #puts "translated #{file}"
        end  # Dir[]
      end  # Thread.new
      threads.each{|t|t.join}
    end

  end # task

end 

# en:
#   activerecord:
#     models:
#       <name>:
#     attributes:
#       <model>:
#         <key>:

# convert /._column/ => column
def generate_yaml(data, locale_name, model_name, model_keys)
  # fill missing fields
  a = (data[locale_name] ||= {})
  a = b = (a["activerecord"] ||= {})

  a = (a["models"] ||= {})
  a[model_name] ||= model_name.camelize
  #a = (a[model_name] ||= {})
  #a["one"] ||= model_name.camelize
  #a["other"] ||= model_name.camelize.pluralize

  b = (b["attributes"] ||= {})
  b = (b[model_name] ||= {})

  #  c_key => key
  model_keys.each do |key|
    key.sub!(/^(._)?/, "")
    b[key] ||= key.humanize
  end

  data.ya2yaml
end


# based on a
#
# Example:
# 	each_r(a,b) do |v1, v2|
# 		v2 ? v1 : v2
# 	end
def each_r(a, b, &blk)
	rst = {}
	_each_r(rst, a, b, &blk)
	rst
end

def _each_r(rst, a, b, &blk)
  threads = []
  out = []

	a.each do |k,v|
		if Hash===v
			_each_r((rst[k]={}), v, (b[k] ? b[k] : {}), &blk)
		else
			rst[k] = blk.call(v, b[k])
		end
	end
end

# support "%{model}"
# 
# current don't use google
def translate(data, locale)
  # "xx %{model} "
  ret=""
  data.scan(/(.*?)(%\{.*?\}|\z)/) do |a,b|
    next if a.empty?
    ret << 
      begin
        a.translate(locale) 
      rescue RuntimeError
        a
      end
    ret << b
  end
  ret
end
