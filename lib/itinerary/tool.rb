module Itinerary

  class Tool

    def self.inherited(subclass)
      @@tools ||= []
      @@tools << subclass
    end

    def self.tools
      @@tools
    end

    def self.find_tool(cmd)
      tool_class = @@tools.find { |t| t.name == cmd }
    end

    def initialize(args)
      parse(args)
    end

  end

end