require 'erb'
require 'yaml'
require 'active_support'
require 'active_support/core_ext'
require 'logging'
require 'active_record'

database_configs = YAML.load(ERB.new(File.binread('config/database.yaml')).result).with_indifferent_access

ActiveRecord::Base.logger = Logging.logger('log/debug.log')
ActiveRecord::Base.establish_connection(database_configs[:development])
