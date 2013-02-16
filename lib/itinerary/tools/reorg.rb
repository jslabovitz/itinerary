module Itinerary
  module Tools
    class Reorg < Tool

      #FIXME: combine this with 'convert' and 'geocode'?

      def self.name
        'reorg'
      end

      def parse(args)
      end

      def run
        Record.each do |rec|
          if rec.path =~ /^unknown/ && rec.geocoded?
            old_path = rec.path
            rec.path = rec.make_path
            rec.save!
            (DataDir + old_path).unlink
            ;;puts "Moved #{old_path} => #{rec.path}"
          end
        end
      end

    end
  end
end