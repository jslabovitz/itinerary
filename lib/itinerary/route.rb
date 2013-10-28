class Itinerary

  class Route

    attr_accessor :name
    attr_accessor :dates
    attr_accessor :points

    def initialize(params={})
      params.each { |k, v| method("#{k}=").call(v) }
    end

  end

end