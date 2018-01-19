# settings for active records
require 'active_record'

options = {
  adapter: 'postgresql',
  database: 'meeplepurse'
}
ActiveRecord::Base.establish_connection( ENV['DATABASE_URL'] || options)