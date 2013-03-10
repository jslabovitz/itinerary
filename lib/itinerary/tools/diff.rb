class Itinerary
  class DiffTool < Tool

    def self.name
      'diff'
    end

    def parse(args)
      @recs = args.map { |id| @itinerary[id] or raise "No record with id #{id.inspect}" }
      raise "Can only diff two records" if @recs.length != 2
    end

    def run
      @recs[0].print_diff(@recs[1])
    end

  end
end