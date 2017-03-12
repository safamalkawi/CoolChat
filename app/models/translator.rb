require 'nokogiri'
require 'open-uri'

class Translator
  @@base_url = 'http://www.degraeve.com/cgi-bin/babel.cgi?d=%s&url=&w=%s'
  def translate(mode, message)
    page = Nokogiri::HTML(open(@@base_url % [mode, URI.escape(message)]))
    return page.css('p').text
  end
end
