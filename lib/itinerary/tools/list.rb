class Itinerary
  class ListTool < Tool

    def self.name
      'list'
    end

    def parse(args)
      @view_class = View::Text
      @params = {}
      while args.first =~ /^-(\w+)$/
        args.shift
        case $1
        when 't'
          @view_class = View::Tab
        when 'h'
          @view_class = View::HTML
        when 'k'
          @view_class = View::KML
        when 'f'
          key, value = args.shift.split('=', 2)
          @params[key] = value
        end
      end
      @params[:entries] = args.join(',') unless args.empty?
    end

    def run
      filters, options = @itinerary.parse_params(@params)
      view = @view_class.new(@itinerary, options)
      print view.render(@itinerary.entries(filters))
    end

  end
end