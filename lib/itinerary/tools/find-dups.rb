module Itinerary
  module Tools
    class FindDups < Tool

      def self.name
        'find-dups'
      end

      def parse(args)
      end

      def run
        values = {}
        Record.each do |rec|
          %w{person organization email uri phone geocoding}.each do |key|
            if (value = rec[key])
              values[key] ||= {}
              values[key][value] ||= []
              values[key][value] << rec.path
            end
          end
        end
        values.each do |key, set|
          set.each do |value, paths|
            if paths.length > 1
              puts "#{key}:#{value} is in: #{paths.join(' ')}"
            end
          end
        end
      end

    end
  end
end