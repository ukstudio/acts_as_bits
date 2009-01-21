require 'rubygems'
require 'spec'
require 'active_record'

__DIR__ = File.dirname(__FILE__)
config = YAML::load_file(__DIR__ + '/database.yml')
ActiveRecord::Base.configurations = config
ActiveRecord::Base.establish_connection(ENV['DB'] || 'postgresql')
load(__DIR__ + "/schema.rb")

$:.unshift __DIR__ + "/../lib"
require 'acts_as_bits'

require File.join(__DIR__, "fixtures/mixin")
