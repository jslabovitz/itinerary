class Itinerary
  class EditTool < Tool

    def self.name
      'edit'
    end

    def parse(args)
      @recs = args.map { |id| @itinerary[id] or raise "No record with id #{id.inspect}" }
    end

    def run
      @recs.each do |rec|
        old_rec = rec.dup
        rec.edit(:wait => true)
        rec = Record.load(rec.path)
        if rec == old_rec
          warn "Unchanged"
          next
        end
        unless rec.geocoded?
          rec.geocode or raise "Failed to geocode #{rec.address.inspect} (entry left in #{rec.path})"
          rec.make_path(@itinerary.entries_path)
          rec.save!
        end
        old_rec.print_diff(rec)
        rec.make_path(@itinerary.entries_path)
        if rec.path != old_rec.path
          old_rec.path.rename(rec.path)
          warn "Renamed #{old_rec.path} to #{rec.path}"
        end
      end
    end

  end
end