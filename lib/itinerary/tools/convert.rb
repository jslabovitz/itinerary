module Itinerary
  module Tools
    class Convert < Tool

      def self.name
        'convert'
      end

      def parse(args)
        if args.first == '-n'
          args.shift
          @dry_run = true
        end
      end

      def run
        Record.each do |rec1|
          rec2 = rec1.dup
          if rec2.convert
            puts "#{rec2.path} changed in cleaning"
            (rec1.keys + rec2.keys).sort.uniq.each do |key|
              if rec1[key] && !rec2[key]
                puts "\t" + "#{key}:"
                puts "\t\t" + "- #{rec1[key].inspect}"
              elsif !rec1[key] && rec2[key]
                puts "\t" + "#{key}:"
                puts "\t\t" + "+ #{rec2[key].inspect}"
              elsif rec1[key] != rec2[key]
                puts "\t" + "#{key}:"
                puts "\t\t" + "< #{rec1[key].inspect}"
                puts "\t\t" + "> #{rec2[key].inspect}"
              end
            end
            rec2.save! unless @dry_run
          end
        end
      end

    end
  end
end