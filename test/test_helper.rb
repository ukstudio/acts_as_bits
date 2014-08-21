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
require __DIR__ + '/../lib/acts_as_bits'

# create tables
load(__DIR__ + "/schema.rb")

class Mixin < ActiveRecord::Base
  acts_as_bits :flags, %w( admin composer )
  acts_as_bits :positions, [
                            [:top,    "TOP"],
                            [:right,  "RIGHT"],
                            [:bottom, "BOTTOM"],
                            [:left,   "LEFT"],
                           ]
  acts_as_bits :blank_flags, [:flag1, nil, :flag3]
end

