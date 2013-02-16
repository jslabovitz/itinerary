#!/usr/bin/env ruby
#encoding: utf-8

require 'pp'
require 'builder'

$LOAD_PATH.unshift Pathname.new(__FILE__).dirname + '../lib'

require 'record'

kml_path = Pathname.new('~/Projects/johnlabovitz.com/site/content/_static').expand_path + 'letterpress-map.kml'
route_path = Pathname.new('route')

###

visited = Record.all.select { |r| r.visited && r.visited < DateTime.now }.sort_by(&:visited)

route = route_path.readlines.map do |place|
  results = Geocoder.search(place)
  result = results.first or raise "Can't geocode #{place.inspect}"
  HashStruct.new(
    :city => result.city,
    :state => result.state_code,
    :country => result.country_code,
    :latitude => result.coordinates[0],
    :longitude => result.coordinates[1])
end

puts "Mapping #{visited.length} visits and #{route.length} legs"

kml = Builder::XmlMarkup.new(:indent => 2)
kml.instruct!(:xml, :version => '1.0', :encoding => 'UTF-8')
kml.kml(:xmlns => 'http://www.opengis.net/kml/2.2') do
  kml.Document do
    kml.name('Letterpress documentary')

    # draw points for visits
    visited.each do |rec|
      kml.Placemark(:id => rec.id) do
        unless rec.city
          rec.geocode
          rec.save!
          raise "No city: #{rec.id}" unless rec.city
        end
        kml.name("%s (%s, %s) – %s" % [rec.name, rec.city, rec.state, rec.visited.strftime('%-d %b %Y')])
        #FIXME: generate better description using HTML & CDATA
        kml.description("\"%s\"" % [rec.description])
        kml.Point do
          kml.coordinates(rec.kml_coordinates)
        end
      end
    end

    # draw lines for legs of route
    kml.Placemark(:id => 'route') do
      kml.LineString do
        kml.extrude(1)
        kml.tessellate(1)
        kml.coordinates do
          kml << route.map { |leg| [leg.longitude, leg.latitude].join(',') }.join("\n")
        end
      end
    end
  end
end

kml_path.open('w') { |io| io.print kml.target! }
;;warn "Wrote KML to #{kml_path}"