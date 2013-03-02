class Itinerary
  class View
    class Tab < View

      def render(entries)
        @first = true
        super
      end

      def render_record(rec)
        if @first
          @output.puts @field_keys.map { |k| Record.field(k).name }.join("\t")
          @first = false
        end
        @output.puts rec.to_tab(:field_keys => @field_keys)
      end

    end
  end
end