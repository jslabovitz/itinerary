class Itinerary
  class ImportTool < Tool

    def self.name
      'import'
    end

    def parse(args)
      @files = args
    end

    def run
      @files.map { |p| Pathname.new(path) }.each do |path|
        #FIXME: save
        @itinerary.import_entry(path) if path.file?
      end
    end

  end
end