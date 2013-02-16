require 'nokogiri'
require 'faraday_middleware/response_middleware'

module FaradayMiddleware

  class ParseHTML < ResponseMiddleware
    define_parser do |body|
      Nokogiri::HTML(body)
    end
  end

end
