class Itinerary
  class View
    class Text < View

      def render_record(rec)
        @output.puts "[#{rec.path.relative_path_from(@itinerary.entries_path)}]"
        @output.puts rec.to_text(:field_keys => @field_keys)
        @output.puts '---'
        @output.puts ''
      end

    end
  end
end