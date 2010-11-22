require 'pp'
require 'rubygems'
require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017, :logger => Logger.new(STDOUT))
MongoMapper.database = 'places_dev'


# Mongo doesn't seem to like the name 'County'...not sure why?
class CountyPlace
  include MongoMapper::Document
  
  key :state, String
  key :name, String
  key :loc, Hash
end


CountyPlace.ensure_index([[:loc, "2d"]])
CountyPlace.ensure_index(:name)
CountyPlace.ensure_index(:state)
CountyPlace.ensure_index([[:name, 1], [:state, 1]])



# Stupid government, this isn't a CSV or TSV for that matter
#
# Columns 1-2: United States Postal Service State Abbreviation
# Columns 3-4: State Federal Information Processing Standard (FIPS) code
# Columns 5-7: FIPS county code
# Columns 8-71: Name
# Columns 72-80: Total Population (2000)
# Columns 81-89: Total Housing Units (2000)
# Columns 90-103: Land Area (square meters) - Created for statistical purposes only.
# Columns 104-117: Water Area (square meters) - Created for statistical purposes only.
# Columns 118-129: Land Area (square miles) - Created for statistical purposes only.
# Columns 130-141 Water Area (square miles) - Created for statistical purposes only.
# Columns 142-151 Latitude (decimal degrees) First character is blank or "-" denoting North or South latitude respectively
# Columns 152-162 Longitude (decimal degrees) First character is blank or "-" denoting East or West longitude respectively
File.read('county2k.txt').each_line do |line|
  state = line[0..1].strip
  name  = line[7..70].strip
  loc   = {:lat => line[141..150].strip.to_f, :lon => line[151..161].strip.to_f}
  
  county = CountyPlace.new
  county.state = state
  county.name = name
  county.loc = loc
  county.save
end
