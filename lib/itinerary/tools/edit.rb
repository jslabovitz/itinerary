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
        rec.edit(:wait => true)
        rec = Record.load(rec.path)
        unless rec.geocoded?
          rec.geocode or begin
            raise "Failed to geocode #{rec.address.inspect} (entry left in #{rec.path})"
          end
          rec.save!
        end
        new_path = rec.make_path(@itinerary.entries_path)
        if new_path != rec.path
          old_path = rec.path
          rec.path.rename(new_path)
          rec.path = new_path
          warn "Renamed #{old_path} to #{new_path}"
        end
      end
    end

  end
end