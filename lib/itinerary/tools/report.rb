class Itinerary
  class Reportool < Tool

    def self.name
      'report'
    end

    def parse(args)
      @params = {}
      while args.first =~ /^-(\w+)$/
        args.shift
        case $1
        when 'f'
          key, value = args.shift.split('=', 2)
          @params[key] = value
        end
      end
      @params[:entries] = args.join(',') unless args.empty?
    end

    def run
      filters, options = @itinerary.parse_params(@params)
      view = View::Text.new(@itinerary, options)
      entries = @itinerary.entries.select(&:notes)
      print view.render(entries)
    end

  end
end