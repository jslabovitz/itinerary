module Itinerary
  module Tools
    class Import < Tool

      def self.name
        'import'
      end

      def parse(args)
        @fields = {}
        if args.first == '-f'
          args.shift
          while args.first =~ %r{^(\w+):(.*)$}
            @fields[$1.to_sym] = $2
            args.shift
          end
        end
        @files = args
      end

      def run
        @files.each do |path|
          path = Pathname.new(path)
          next unless path.file?
          recs = Record.import(path, :fields => @fields)
          # ;;pp recs
          #FIXME: save
        end
      end

    end
  end
end