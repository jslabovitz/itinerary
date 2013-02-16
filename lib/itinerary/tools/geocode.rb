module Itinerary
  module Tools
    class Geocode < Tool

      def self.name
        'geocode'
      end

      def parse(args)
        @force = (args.first == '--force')
      end

      def run
        Record.each do |rec|
          if !rec.geocoded? || @force
            ;;puts "geocoding: #{rec.path}"
            rec.geocode
            rec.save!
            ;;puts rec.to_text
            ;;puts "Saved to #{rec.path.inspect}"
          end
        end
      end

    end
  end
end