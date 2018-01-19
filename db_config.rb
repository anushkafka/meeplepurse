# settings for active records
require 'active_record'
require_relative 'models/purchase'
require_relative 'models/user'

options = {
  adapter: 'postgresql',
  database: 'meeplepurse'
}
ActiveRecord::Base.establish_connection( ENV['DATABASE_URL'] || options)