module Itinerary
  module Tools
    class Merge < Tool

      #FIXME: this should be 'clean'

      def self.name
        'merge'
      end

      def parse(args)
      end

      def run
        Record.each do |rec1|
          rec2 = rec1.dup
          rec2.clean!
          if rec2 != rec1
            all_keys = (rec1.keys + rec2.keys).sort.uniq
            puts "#{rec1.path} changed in cleaning"
            all_keys.each do |key|
              if rec1[key] != rec2[key]
                if rec1[key] && !rec2[key]
                  puts "\t" + "- #{key}: #{rec1[key].inspect}"
                elsif !rec1[key] && rec2[key]
                  puts "\t" + "+ #{key}: #{rec2[key].inspect}"
                else
                  puts "\t" + "~ #{key}: #{rec1[key].inspect} => #{rec2[key].inspect}"
                end
              end
            end
          end
        end
      end

    end
  end
end