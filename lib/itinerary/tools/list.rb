class Itinerary
  class ListTool < Tool

    def self.name
      'list'
    end

    def parse(args)
      @view_class = View::Text
      while args.first =~ /^-(\w+)$/
        args.shift
        @view_class = case $1
        when 't'
          View::Tab
        when 'h'
          View::HTML
        when 'k'
          View::KML
        end
      end
      params = Hash[
        args.map do |arg|
          key, value = *arg.split('=', 2)
          [key.to_sym, value]
        end
      ]
      @filters, @options = @itinerary.parse_params(params)
    end

    def run
      view = @view_class.new(@itinerary, @options)
      print view.render(@itinerary.entries(@filters))
    end

  end
end