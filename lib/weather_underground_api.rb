require 'weather_underground_api/version'

require 'uri'
require 'json'
require 'net/http'

module WeatherUndergroundApi
    API_URL = 'http://api.wunderground.com/api/%s'
    AUTOCOMPLETE_URL = 'http://autocomplete.wunderground.com/aq' #?query=%s
    FORMAT = 'json'
    LANG = 'lang:EN'
    PWS = 'pws:1'
    BESTFCT = 'bestfct:1'

    class WuError < StandardError; end
    class MissingKey < WuError; end

    class Base
        def initialize(api_key, options = {})
            @api_key = api_key

            options ||= {}
            @options = options
            @options.reverse_merge!(
                :raise_errors => false,
                :format       => 'json',
                :lang         => 'en',
                :pws          => '1',
                :bestfct      => '1'
            )

            @autocomplete_response = nil

            if @api_key.blank? && @options[:raise_errors]
                raise(MissingKey, "API Key not found!")
            end
        end

        def api_key
            @api_key
        end

        def options
            @options
        end

        def response_has_error?(response)
            if response && response['response'] && response['response']['error']
                error = "#{response['response']['error']['type']}: #{response['response']['error']['description']})"
                if @options[:raise_errors]
                    raise(WuError, error)
                else
                    error
                end
            end
        end

        def autocomplete(query, options = {})
            options ||= {}
            options.reverse_merge! :format => @options[:format].to_s.upcase, :h => '0'
            @autocomplete_response = get("#{autocomplete_url}?format=#{options.delete(:format)}&h=#{options.delete(:h)}&query=#{query.to_s.gsub(/\s+/, '')}")
        end

        def autocomplete_attr(value_to_get)
            attr(@autocomplete_response, value_to_get)
        end


        private

        def autocomplete_url
            WeatherUndergroundApi::AUTOCOMPLETE_URL
        end

        def get(url)
            JSON.parse( Net::HTTP.get_response( URI(url) ).body )
        end

        def attr(object_to_use, attr_to_get)
            return nil if object_to_use.blank?
            attrs = attr_to_get.split('.')
            attrs.reduce(object_to_use) {|m,k| m && m[k] }
        end
    end
end
