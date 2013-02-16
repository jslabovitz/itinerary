require 'pp'
require 'pathname'

require 'geocoder'
require 'hashstruct'
require 'haversine'

require 'itinerary/version'
require 'itinerary/record'
# require 'itinerary/briar_scraper'

module Itinerary

  DataDir ||= Pathname.new(ENV['DATA_DIR'] || 'entries')

end