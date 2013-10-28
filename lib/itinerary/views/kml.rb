class Itinerary
  class View
    class KML < View

      def render(entries)
        @kml = Builder::XmlMarkup.new
        @kml.instruct!(:xml, :version => '1.0', :encoding => 'UTF-8')
        @kml.kml(:xmlns => 'http://www.opengis.net/kml/2.2') do
          @kml.Document do
            @kml.name(@name)
            super
            render_routes
          end
        end
        @kml.target!
      end

      def render_routes
        @itinerary.routes.each do |route|
          render_route(route)
        end
      end

      # draw points for entries

      def render_record(rec)
        @kml.Placemark(:id => rec.path) do
          @kml.name(rec.name)
          @kml.description do
            @kml.cdata!(rec.to_html(:use_dl => false, :field_keys => @field_keys))
          end
          @kml.Point do
            #FIXME: fuzz if required
            @kml.coordinates([rec.longitude, rec.latitude, 0].join(','))
          end
        end
      end

      # draw lines for legs of route

      def render_route(route)
        @kml.Placemark(:id => route.name) do
          @kml.LineString do
            @kml.extrude(1)
            @kml.tessellate(1)
            @kml.coordinates do
              @kml << route.points.map { |p| [p.longitude, p.latitude].join(',') }.join("\n")
            end
          end
        end
      end

    end
  end
end