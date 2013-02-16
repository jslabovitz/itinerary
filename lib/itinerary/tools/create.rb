module Itinerary
  module Tools
    class Create < Tool

      def self.name
        'create'
      end

      def parse(args)
      end

      def run
        path = (DataDir + 'unknown/untitled').expand_path

        rec = Record.new(
          :path => path,
          :person => 'FIXME',
          :organization => 'FIXME',
          :address => 'FIXME',
          :email => 'FIXME',
          :phone => 'FIXME',
          :uri => 'FIXME',
          :description => 'FIXME',
          :ref => 'FIXME',
        )
        rec.save!
        rec.edit(:wait => true)

        rec = Record.load(path)
        rec.geocode
        rec.path = rec.make_path
        rec.save!
        path.unlink
      end

    end
  end
end