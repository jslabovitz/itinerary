class Itinerary
  class ConvertTool < Tool

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
      @itinerary.each do |rec1|
        rec2 = rec1.dup
        if rec2.convert && rec2 != rec1
          puts "#{rec2.path} changed in cleaning"
          rec2.print_diff(rec1)
          rec2.save! unless @dry_run
        end
      end
    end

  end
end