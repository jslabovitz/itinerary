class Itinerary
  class RoutesTool < Tool

    def self.name
      'routes'
    end

    def parse(args)
    end

    def run
      @itinerary.routes.each do |route|
        puts "#{route.name}:"
        puts "\t" + "dates: #{route.dates.first} - #{route.dates.last}"
        puts "\t" + "points:"
        route.points.each do |point|
          puts "\t\t%s, %s" % [point.city, point.state]
        end
        puts "\t" + "visited:"
        @itinerary.select { |r| r.visited? && route.dates.include?(r.visited) }.each do |rec|
          puts "\t\t%s: %s (%s, %s)" % [rec.visited.to_date, rec.name, rec.city, rec.state]
        end
        puts
      end
    end

  end
end