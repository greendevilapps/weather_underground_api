require 'weather_underground_api/version'

require 'uri'
require 'json'
require 'net/http'

module WeatherUndergroundApi
    API_URL = 'http://api.wunderground.com/api/%s'
    AUTOCOMPLETE_URL = 'http://autocomplete.wunderground.com/aq' #?query=%s

    class WuError < StandardError; end
    class MissingKey < WuError; end

    class Base
        def initialize(api_key, options = {})
            @api_key = api_key

            options ||= {}
            @options = options
            @options.reverse_merge!(        # _Defaults_
                :raise_errors    => false,  # Don't want to throw error's just return them
                :raise_api_error => true,   # Want to throw error when no api key
                :format          => 'json', # 'json'
                :lang            => 'en',   # 'lang:en'
                :pws             => '1',    # 'pws:1'
                :bestfct         => '1'     # 'bestfct:1'
            )
            @options[:lang].upcase! unless @options[:lang].blank?

            if @api_key.blank? && @options[:raise_api_error]
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
                @options[:raise_errors] ? raise(WuError, error) : error
            end
        end

        # http://www.wunderground.com/weather/api/d/docs?d=autocomplete-api
        def autocomplete(query, options = {})
            options ||= {}
            options.reverse_merge! :format => @options[:format].to_s.upcase, :h => '0'
            get_json("#{autocomplete_url}?format=#{options.delete(:format)}&h=#{options.delete(:h)}&query=#{parse_query(query)}")
        end

        # http://www.wunderground.com/weather/api/d/docs?d=data/geolookup
        def geolookup(query)
            get_json("#{api_url}/geolookup/#{url_settings}/q/#{parse_query(query)}.#{@options[:format]}")
        end

        # http://www.wunderground.com/weather/api/d/docs?d=data/conditions
        def conditions(query)
            get_json("#{api_url}/conditions/#{url_settings}/q/#{parse_query(query)}.#{@options[:format]}")
        end

        # http://www.wunderground.com/weather/api/d/docs?d=data/alerts
        def alerts(query)
            #JSON.parse( Net::HTTP.get_response( URI("#{build_url}/alerts/#{settings}/q/#{parse_query(location_query)[1]}.json") ).body )
            get_json("#{api_url}/alerts/#{url_settings}/q/#{parse_query(query)}.#{@options[:format]}")
        end

        # http://www.wunderground.com/weather/api/d/docs?d=data/forecast
        def forecast(query)
            get_json("#{api_url}/forecast/q/#{parse_query(query)}.#{@options[:format]}")
        end

        # http://www.wunderground.com/weather/api/d/docs?d=data/forecast10day
        def extended_forecast(query)
            get_json("#{api_url}/forecast10day/q/#{parse_query(query)}.#{@options[:format]}")
        end

        # http://www.wunderground.com/weather/api/d/docs?d=data/hourly
        def hourly(query)
            get_json("#{api_url}/hourly/q/#{parse_query(query)}.#{@options[:format]}")
        end

        def radar_url(query, options = {})
            options ||= {}
            options.stringify_keys!.reverse_merge!(
                'type'    => 'png',
                'radius'  => '100',
                'width'   => '300',
                'height'  => '300',
                'newmaps' => '1'
            )
            "#{api_url}/radar/q/#{parse_query(query)}.#{options.delete('type')}?#{to_params(options)}"
        end

        def radar_data_attrs(query, options = {}, escape = true)
            # options ||= {}
            # options.stringify_keys!.reverse_merge!(
            #     'type'    => 'png',
            #     'radius'  => '100',
            #     'width'   => '300',
            #     'height'  => '300',
            #     'newmaps' => '1'
            # )
            # "data-radar-query-url='#{api_url}/radar/q/' data-radar-query='#{parse_query(query)}' data-radar-type='#{options.delete('type')}' data-radar-radius='#{options.delete('radius')}' data-radar-width='#{options.delete('width')}' data-radar-height='#{options.delete('height')}' data-radar-newmaps='#{options.delete('newmaps')}'".html_safe
            options ||= {}
            options.stringify_keys!.reverse_merge!(
                'query-url' => "#{api_url}/radar/q/",
                'query'     => parse_query(query),
                'type'      => 'png',
                'radius'    => '100',
                'width'     => '300',
                'height'    => '300',
                'newmaps'   => '1'
            )
            attrs = []
            options.each_pair do |k, v|
                attrs << data_tag_option(k, v, escape)
            end
            " #{attrs.sort! * ' '}".html_safe unless attrs.empty?
        end


        private

        def parse_query(query)
            query.to_s.gsub(/\s+/, '')
        end

        def autocomplete_url
            WeatherUndergroundApi::AUTOCOMPLETE_URL
        end

        def api_url
            WeatherUndergroundApi::API_URL
        end

        def url_settings
            "lang:#{@options[:lang]}/pws:#{@options[:pws]}/bestfct:#{@options[:bestfct]}"
        end

        def get_json(url)
            JSON.parse(Net::HTTP.get_response(URI(url)).body)
        end

        def get_xml(url)
            #todo
        end

        def to_params(hsh = {})
            return '' if hsh.blank?

            hsh.respond_to?(:to_param) ? hsh.to_param : URI.escape(hsh.collect{|k,v| "#{k}=#{v}"}.join('&'))
        end

        def data_tag_option(key, value, escape)
            key   = "data-radar-#{key.to_s.dasherize}"
            unless value.is_a?(String) || value.is_a?(Symbol) || value.is_a?(BigDecimal)
                value = value.to_json
            end
            tag_option(key, value, escape)
        end

        def tag_option(key, value, escape)
            value = value.join(" ") if value.is_a?(Array)
            value = ERB::Util.h(value) if escape
            %(#{key}="#{value}")
        end
    end
end
