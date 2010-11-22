require 'pp'
require 'rubygems'
require 'mongo_mapper'
require 'csv'

MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017, :logger => Logger.new(STDOUT))
MongoMapper.database = 'places_dev'


class Place
  include MongoMapper::Document
  
  key :state, String
  key :name, String
  key :loc, Hash
end


Place.ensure_index([[:loc, "2d"]])
Place.ensure_index(:name)
Place.ensure_index(:state)
Place.ensure_index([[:name, 1], [:state, 1]])

CSV.foreach('places.txt', :col_sep => '|', :headers => true) do |row|
  place = Place.new
  place.state = row['STATE_ALPHA']
  place.name = row['FEATURE_NAME']
  place.loc = {:lat => row['PRIM_LAT_DEC'].to_f, :lon => row['PRIM_LONG_DEC'].to_f}
  place.save
end
