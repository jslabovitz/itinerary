class Itinerary
  class FindDupsTool < Tool

    def self.name
      'find-dups'
    end

    def parse(args)
    end

    def run
      values = {}
      @itinerary.entries.each do |rec|
        %w{person organization email uri phone}.each do |key|
          if (value = rec[key])
            values[key] ||= {}
            values[key][value] ||= []
            values[key][value] << rec
          end
        end
      end
      values.each do |key, set|
        set.each do |value, recs|
          if recs.length > 1
            puts
            puts "#{key}: #{value}"
            recs.each { |r| puts "\t" + r.path.to_s }
          end
        end
      end
    end

  end
end