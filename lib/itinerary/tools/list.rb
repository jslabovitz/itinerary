module Itinerary
  module Tools
    class List < Tool

      def self.name
        'list'
      end

      def parse(args)
        @filters = nil
        @mode = :text
        @center = nil
        @radius = 50

        while args.first =~ /^-(\w+)$/
          args.shift
          case $1
          when 't'
            @mode = :tab
          when 'f'
            filter = {}
            while args.first =~ %r{^(\w+):(.*)$}
              @filters ||= {}
              field = $1.to_sym
              # raise "Unknown field: #{field.inspect}" unless Record::FieldNames.include?(field)
              @filters[field] = $2
              args.shift
            end
          when 'n'
            loc = args.shift.dup
            if loc.sub!(/^(\d+):/, '')
              @radius = $1.to_i
            end
            # if (rec = Record[loc])
            #   raise "#{rec_path} is not geocoded" unless rec.geocoded?
            #   center = rec.coordinates
            # else
              results = Geocoder.search(loc)
              if (result = results.first)
                @center = result.coordinates
              end
            # end
            raise "Can't find record for location #{loc.inspect}" unless @center
          else
            raise "Eh? #{$1.inspect}"
          end
        end
      end

      def run
        if @center
          matches = Record.near(@center, @radius)
          recs = matches.sort.map { |dist, rec| rec }.flatten
        else
          recs = Record.each.to_a
        end

        if @mode == :tab
          puts Record.tab_header
        end

        recs.each do |rec|
          if @filters
            matched = @filters.select { |f, v| rec[f] == v }
            next if matched.empty?
          end
          case @mode
          when :text
            puts "[#{rec.path.relative_path_from(Pathname.pwd)}]"
            puts rec.to_text
          when :tab
            puts rec.to_tab
          end
        end
      end

    end
  end
end