class Itinerary
  class View
    class Text < View

      def render_record(rec)
        @output.puts "[#{rec.path}]"
        @output.puts rec.to_text(:field_keys => @field_keys)
      end

    end
  end
end