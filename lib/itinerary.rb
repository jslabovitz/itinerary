require 'pp'
require 'pathname'

require 'geocoder'
require 'hashstruct'
require 'haversine'
require 'builder'
require 'daybreak'

require 'itinerary/version'
require 'itinerary/record'
require 'itinerary/view'
require 'itinerary/views/html'
require 'itinerary/views/kml'
require 'itinerary/views/tab'
require 'itinerary/views/text'
# require 'itinerary/briar_scraper'

class Itinerary

  DefaultRadius = 100

  attr_accessor :name
  attr_accessor :root
  attr_accessor :route

  def initialize(options={})
    @name = options[:name]
    @root = options[:root] or raise "Must specify root"
    @root = Pathname.new(@root).expand_path
    @geocoding_cache_path = options[:geocoding_cache] || '.geocoding-cache'
    setup_geocoding_cache
    @entries = []
    read_entries
    read_routes
  end

  def cleanup
    @geocoding_cache.close
  end

  def entries_path
    @root + 'entries'
  end

  def route_path
    @root + 'route'
  end

  def read_entries
    ;;warn "[initialize] reading entries from #{entries_path}"
    entries_path.find do |path|
      import_entry(path) if path.file? && path.basename.to_s[0] != '.'
    end
    sort_entries
    ;;warn "[initialize] read #{@entries.length} entries"
  end

  def sort_entries
    @entries.sort_by! { |r| r.visited || r.contacted || DateTime.now }
  end

  def import_entry(path)
    @entries << Record.load(path)
  end

  def read_routes
    ;;warn "[initialize] reading route from #{route_path}"
    if route_path.exist?
      @route = route_path.readlines.map { |p| geocode_search(p) }
    end
    ;;warn "[initialize] read #{@route.length} legs of route"
  end

  def setup_geocoding_cache
    @geocoding_cache = Daybreak::DB.new(@geocoding_cache_path)
    @geocoding_cache.compact
    Geocoder.configure(:cache => @geocoding_cache)
  end

  def geocode_search(place)
    begin
      results = Geocoder.search(place)
      @geocoding_cache.flush
      result = results.first or raise "No geocoding result for place #{place.inspect}"
      HashStruct.new(
        :city => result.city,
        :state => result.state_code,
        :country => result.country_code,
        :latitude => result.coordinates[0],
        :longitude => result.coordinates[1])
    rescue => e
      warn "Error when geocoding place #{place.inspect}: #{e}"
      nil
    end
  end

  def make_tool(cmd, args)
    if (klass = Tool.find_tool(cmd))
      klass.new(self, args)
    end
  end

  def entries(filters=nil)
    matched = @entries.dup
    ;;warn "[entries] filtering #{matched.length} entries: #{filters.inspect}"
    if filters
      filters.each do |key, value|
        case key
        when :near
          coordinates = case value
          when Array
            value
          when Pathname
            rec = self[value] or raise "Record #{value.inspect} not found"
            raise "#{rec.path} is not geocoded" unless rec.geocoded?
            rec.coordinates
          when String
            results = Geocoder.search(value)
            result = results.first or raise "Can't find location #{value.inspect}"
            result.coordinates
          end
          raise "No coordinates found for #{value.inspect}" unless coordinates
          matched.select! { |r| r.near(coordinates, filters[:radius] || DefaultRadius) }
        when :radius
          # ignored here -- used above
        when :flags
          matched.select! do |rec|
            value.find { |v| rec.method("#{v}?").call }
          end
        else
          raise "Unknown field: #{key.inspect}" unless Record.field(key) || Record.instance_methods.include?(key)
          matched.select! { |r| r[key] == value }
        end
      end
    end
    ;;warn "[entries] filtered #{matched.length} entries: #{filters.inspect}"
    matched
  end

  def near(coords, radius)
    matches = {}
    @entries.each do |rec|
      if (distance = rec.near(coords, radius))
        matches[distance] ||= []
        matches[distance] << rec
      end
    end
    matches
  end

  def [](path)
    @entries.find { |r| r.path.relative_path_from(entries_path).to_s == path }
  end

  def parse_params(params)
    filters = HashStruct.new
    options = HashStruct.new
    params.select.each do |key, value|
      case key.to_sym
      when :near
        filters.near = value
      when :radius
        filters.radius = value.to_f
      when :flags
        filters.flags = value.split(',').map { |f| f.to_sym }
      when :show_fields
        options.show_fields = value.split(',').map { |f| f.to_sym }
      when :hide_fields
        options.hide_fields = value.split(',').map { |f| f.to_sym }
      # when :fuzz
      #   options.fuzz_placemarks = value
      else
        filters[key.to_sym] = value
      end
    end
    [filters, options]
  end

end