class Itinerary
  class View

    attr_accessor :name
    attr_accessor :show_fields
    attr_accessor :hide_fields

    def initialize(itinerary, params={})
      @itinerary = itinerary
      @show_fields = Record.field_keys
      @hide_fields = []
      @output = StringIO.new
      params.each { |k, v| method("#{k}=").call(v) }
    end

    def render(entries)
      @field_keys = @show_fields - @hide_fields
      entries.each do |rec|
        render_record(rec)
      end
      @output.rewind
      @output.read
    end

  end
end