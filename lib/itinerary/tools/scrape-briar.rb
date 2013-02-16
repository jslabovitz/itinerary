module Itinerary
  module Tools
    class ScrapeBriar < Tool

      def self.name
        'scrape-briar'
      end

      def parse(args)
        @states = args
      end

      def run
        scraper = BriarScraper.new
        @states.each do |state|
          recs = scraper.scrape_state(state)
          ;;puts "Scraped #{recs.length} recs from state #{state.inspect}"
          recs.each do |rec|
            ;;puts rec.to_text
            rec.save!
          end
        end
      end

    end
  end
end