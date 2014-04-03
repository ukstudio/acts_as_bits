def __DIR__; File.dirname(__FILE__); end

require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_record'
require 'active_record/fixtures'

config = YAML::load_file(__DIR__ + '/database.yml')
ActiveRecord::Base.logger = Logger.new(__DIR__ + "/debug.log")
if ActiveRecord::Base.respond_to? :colorize_loging=
  ActiveRecord::Base.colorize_logging = false
end
ActiveRecord::Base.configurations = config
ActiveRecord::Base.establish_connection(ENV['DB'] || 'postgresql')

$:.unshift __DIR__ + '/../lib'
require __DIR__ + '/../init'

# create tables
load(__DIR__ + "/schema.rb")

# insert sample data to the tables from 'fixtures/*.yml'
Test::Unit::TestCase.fixture_path = __DIR__ + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)
Test::Unit::TestCase.use_instantiated_fixtures  = true

