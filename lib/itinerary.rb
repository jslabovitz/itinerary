require 'pp'
require 'pathname'

require 'geocoder'
require 'hashstruct'
require 'haversine'

require 'itinerary/version'
require 'itinerary/record'
# require 'itinerary/briar_scraper'

module Itinerary

  def self.root
    @@root
  end

  def self.root=(root)
    @@root = Pathname.new(root).expand_path
  end

end