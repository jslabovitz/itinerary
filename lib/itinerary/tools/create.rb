class Itinerary
  class CreateTool < Tool

    def self.name
      'create'
    end

    def run
      tmp = Pathname.new('/tmp/new-entry')
      unless tmp.exist?
        rec = Record.new(
          :path => tmp,
          :person => 'FIXME',
          :organization => 'FIXME',
          :address => 'FIXME',
          :email => 'FIXME',
          :phone => 'FIXME',
          :uri => 'FIXME',
          :description => 'FIXME',
          :ref => 'FIXME',
        )
        rec.save!
        rec.edit(:wait => true)
      end
      rec = Record.load(tmp)
      rec.geocode or begin
        warn "Failed to geocode #{rec.address.inspect} (entry left in #{tmp})"
        exit(1)
      end
      rec.path = rec.make_path(@itinerary.entries_path)
      rec.save!
      warn "Saved to #{rec.path}"
      tmp.unlink
      @itinerary.import_entry(rec.path)
    end

  end
end