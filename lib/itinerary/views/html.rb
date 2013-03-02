class Itinerary
  class View
    class HTML < View

      def render(entries)
        @html = Builder::XmlMarkup.new
        @html.h1(@itinerary.name) if @itinerary.name
        super
        @html.target!
      end

      def render_record(rec)
        @html << rec.to_html(:field_keys => @field_keys, :use_dl => true)
      end

    end
  end
end