require 'faraday'
require 'faraday_middleware'
require 'rack/cache'

require 'itinerary/record'
require 'parse_html'
require 'cache'

class BriarScraper

  CacheDir = Pathname.new(__FILE__).dirname + '../cache'

  def initialize
    @cache = Cache.new(CacheDir)
    @base_uri = URI.parse('http://www.briarpress.org')
    @conn = Faraday.new(:url => @base_uri) do |c|
      # c.use Faraday::Response::Logger
      c.use FaradayMiddleware::ParseHTML
      c.use FaradayMiddleware::Caching, @cache
      c.adapter Faraday.default_adapter
    end
  end

  def scrape_state(state)
    # ;;warn "Scraping state #{state.inspect}"
    scrape_state_with_uri(uri_for_state(state))
  end

  private

  def scrape_state_with_uri(state_uri, options={})
    follow = options.has_key?(:follow) ? options[:follow] : true
    # ;;warn "Scraping state URI #{state_uri.inspect} (follow = #{follow.inspect})"
    resp = @conn.get(state_uri)
    html = resp.body
    recs = html.xpath("//a[@class='card']").map { |a| scrape_listing(@base_uri + a['href']) }
    if follow
      seen = [state_uri]
      html.xpath('//span[@class="pager-list"]/a').each do |a|
        if a.text =~ /^\d+$/
          # ;;warn "Following link #{a.text.inspect} to #{state_uri.inspect}"
          state_uri = @base_uri + a['href']
          unless seen.include?(state_uri)
            recs += scrape_state_with_uri(state_uri, :follow => false)
            seen << state_uri
          end
        end
      end
    end
    recs
  end

  def uri_for_state(state)
    "/yellowpages/browse?c=222&s=#{state}"
  end

  def scrape_listing(listing_uri)
    # ;;warn "Scraping listing URI #{listing_uri.inspect}"
    resp = @conn.get(listing_uri)
    html = resp.body
    detail = html.at_xpath('//div[@class="detail"]')
    person = detail.at_xpath("div[@class='card']/div[@class='prop sans']").text.strip.squeeze(' ')
    organization = detail.at_xpath('//h1').children.map { |e| (n = e.text.strip).empty? ? nil : n }.compact.join(': ').squeeze(' ')
    if (description = detail.at_xpath("//p[@class='intro']"))
      description = description.text.strip.squeeze(' ')
    end
    uri = nil
    address = nil
    detail.xpath("//ul[@id='address']/li").each do |li|
      if (a = li.at_xpath("a[@target='_blank']"))
        uri = URI.parse(a['href'].gsub(/\s+/, ''))
      elsif li.text =~ /^\s*(Tel|Fax)\b/
        # ignore
      else
        address = li.children.select { |e| e.name != 'br' && e.text != ', ' && !e.text.empty? }.map { |e| (a = e.text.strip).empty? ? nil : a }.compact.join(', ').squeeze(' ')
      end
    end
    rec = Record.new(
      :person => person,
      :organization => organization,
      :address => address,
      :uri => uri,
      :description => description,
      :group => 'Briar')
    rec.clean!
    rec.geocode
    # ;;warn "Scraped #{rec.make_path} from #{listing_uri.inspect}"
    rec
  end

end
