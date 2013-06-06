class Itinerary
  class GeocodeTool < Tool

    def self.name
      'geocode'
    end

    def parse(args)
      @recs = args.map { |id| @itinerary[id] or raise "No record with id #{id.inspect}" }
    end

    def run
      @recs.each do |rec|
        rec.geocode or raise "Failed to geocode #{rec.address.inspect} (entry left in #{rec.path})"
        rec.save!
      end
    end

  end
end