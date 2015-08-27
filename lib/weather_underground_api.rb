require 'weather_underground_api/version'

require 'uri'
require 'json'
require 'net/http'

module WeatherUndergroundApi
    # Main API url
    API_URL = 'http://api.wunderground.com/api/%s'

    # Autocomplete url, for searching places
    AUTOCOMPLETE_URL = 'http://autocomplete.wunderground.com/aq' #?query=%s

    # Add error classes
    class WuError < StandardError; end
    class MissingKey < WuError; end

    # The main class that will initialize everything
    class Base
        # This is called when `new` is called on this class.
        # +api_key+ is required and is expecting a string.
        # +options+ are a set of attrs that can change the defaults.
        #
        # Supported options:
        #   Name               | Type           | Default   | Info
        #   -------------------------------------------------------
        #   +:raise_errors+    | Boolean        | false     | This option is `false` by default. It is used to control whether
        #                                                     or not to throw errors when calling the helper function `response_has_error?`.
        #   +:raise_api_error+ | Boolean        | true      | This option is `true` by default. This will raise an error
        #                                                     when no api_key has been passed into the initialize method.
        #   +:format+          | String         | 'json'    | The type of format that you want to use. The default is `'json'`.
        #                                                     As of right now that is the only format supported. XML may come in the future.
        #   +:lang+            | String         | 'EN'      | Is the language that you want to use. By default it uses english ('EN').
        #                                                     Just pass in the language code found [here](http://www.wunderground.com/weather/api/d/docs?d=language-support).
        #   +:pws+             | String/Boolean | '1'       | If you want to use personal weather stations for conditions pass in '1',
        #                                                     which is the default, or pass in '0' to turn this off.
        #   +:bestfct+         | String/Boolean | '1'       | This will use Weather Underground's "best forecast" feature.
        #                                                     Learn more [here](http://www.wunderground.com/about/data.asp).
        #   +:icon_set+        | String         | 'k'       | The icon set that is provided by Weather Underground. These are sent as .gif's
        #                                                     and typically don't scale well. You might want to use a different icon set or
        #                                                     use and icon font.
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
                :bestfct         => '1',    # 'bestfct:1',
                :icon_set        => 'k'     # Default to last on the list, which is 'k'
            )
            @options[:lang].upcase! unless @options[:lang].blank?
            @options[:pws] = is_true(@options[:pws]) ? '1' : '0'
            @options[:bestfct] = is_true(@options[:bestfct]) ? '1' : '0'

            if @api_key.blank? && @options[:raise_api_error]
                raise(MissingKey, "API Key not found!")
            end
        end

        # Returns a list of locations or hurricanes which match against a partial query.
        #
        # +query+ Is the location query that needs to be ran against. This is required.
        # +options+ Are a set of options for this request.
        #
        # Supported options:
        #   - +:format+ Can override the default format. This may mess up any calls when not
        #               using json. Defaults to `@options[:format]`.
        #   - +:h+ Whether or not to include hurricanes in results. Defaults to '0'.
        #
        # To see more options please see [this](http://www.wunderground.com/weather/api/d/docs?d=autocomplete-api&apiref=77eba12431a68f79).
        def autocomplete(query, options = {})
            options ||= {}
            options.reverse_merge! :format => @options[:format], :h => '0'
            options[:h] = is_true(options[:h]) ? '1' : '0'
            get_json("#{autocomplete_url}?format=#{options.delete(:format)}&h=#{options.delete(:h)}&query=#{parse_query(query)}")
        end

        # Returns the city name, zip code / postal code, latitude-longitude coordinates and nearby personal weather stations.
        #
        # +query+ Is the query location name.
        #
        # For more info see [this](http://www.wunderground.com/weather/api/d/docs?d=data/geolookup&apiref=77eba12431a68f79).
        def geolookup(query)
            get_json("#{api_url}/geolookup/#{url_settings}/q/#{parse_query(query)}.#{@options[:format]}")
        end

        # Returns the current temperature, weather condition, humidity, wind,
        # 'feels like' temperature, barometric pressure, and visibility.
        #
        # +query+ The query to run a location against.
        #
        # See more [here](http://www.wunderground.com/weather/api/d/docs?d=data/conditions&apiref=77eba12431a68f79).
        def conditions(query)
            get_json("#{api_url}/conditions/#{url_settings}/q/#{parse_query(query)}.#{@options[:format]}")
        end

        # Returns the short name description, expiration time and a long text description of a severe alert,
        # if one has been issued for the searched upon location.
        #
        # +query+ The location query.
        #
        # See more about alerts [here](http://www.wunderground.com/weather/api/d/docs?d=data/alerts&apiref=77eba12431a68f79).
        def alerts(query)
            get_json("#{api_url}/alerts/#{url_settings}/q/#{parse_query(query)}.#{@options[:format]}")
        end

        # Returns a summary of the weather for the next 3 days. This includes high and low temperatures,
        # a string text forecast and the conditions.
        #
        # +query+ Location query to find.
        #
        # Find out more [here](http://www.wunderground.com/weather/api/d/docs?d=data/forecast&apiref=77eba12431a68f79).
        def forecast(query)
            get_json("#{api_url}/forecast/q/#{parse_query(query)}.#{@options[:format]}")
        end

        # Returns a summary of the weather for the next 10 days. This includes high and low temperatures,
        # a string text forecast and the conditions.
        #
        # +query+ Location query.
        #
        # See [this](http://www.wunderground.com/weather/api/d/docs?d=data/forecast10day&apiref=77eba12431a68f79) for more.
        def extended_forecast(query)
            get_json("#{api_url}/forecast10day/q/#{parse_query(query)}.#{@options[:format]}")
        end
        # Weather underground uses the call `forecast10day`, so with trying to keep with the same names,
        # this is here to support that.
        alias_method :forecast10day, :extended_forecast

        # Returns the next 36 hours from current time.
        #
        # +query+ Location query
        #
        # For more see [this](http://www.wunderground.com/weather/api/d/docs?d=data/hourly&apiref=77eba12431a68f79).
        def hourly(query)
            get_json("#{api_url}/hourly/q/#{parse_query(query)}.#{@options[:format]}")
        end

        # Returns a static or animated radar image for a given location.
        #
        # +query+ The location query
        # +options+ Options to pass in the url.
        #
        # To change the radar from just being an image to an animation, you need to change
        # the option +query_type+ to 'animatedradar'. When changing this to that type,
        # you must pass in the type as 'gif' or 'swf' format or the request will fail.
        #
        # To see all of the options see [here](http://www.wunderground.com/weather/api/d/docs?d=layers/radar&apiref=77eba12431a68f79).
        def radar_url(query, options = {})
            options ||= {}
            options.stringify_keys!.reverse_merge!(
                'query_type' => 'radar',
                'type'       => 'png',
                'radius'     => '100',
                'width'      => '300',
                'height'     => '300',
                'newmaps'    => '1'
            )
            options['query_type'] = 'radar' if options['query_type'].blank?
            "#{api_url}/#{options.delete('query_type')}/q/#{parse_query(query)}.#{options.delete('type')}?#{to_params(options)}"
        end

        # Returns a static or animated satellite image for a given location.
        #
        # +query+ Location query
        # +options+ Options to be passed in the request.
        #
        # To change the radar from just being an image to an animation, you need to change
        # the option +query_type+ to 'animatedsatellite'. When changing this to that type,
        # you must pass in the type as 'gif' format or the request will fail.
        #
        # See [here](http://www.wunderground.com/weather/api/d/docs?d=layers/satellite&apiref=77eba12431a68f79) for a list of options.
        def satellite_url(query, options = {})
            options ||= {}
            options.stringify_keys!.reverse_merge!(
                'query_type' => 'satellite',
                'type'       => 'png',
                'radius'     => '100',
                'width'      => '300',
                'height'     => '300',
                'basemap'    => '1'
            )
            "#{api_url}/#{options.delete('query_type')}/q/#{parse_query(query)}.#{options.delete('type')}?#{to_params(options)}"
        end

        # --------------
        # Helper methods
        # --------------

        # Returns the api_key
        def api_key
            @api_key
        end

        # Returns the hash of options.
        def options
            @options
        end

        # Will check a response object if it has an error or not. You must pass in the whole response
        # object or this may not pick up on the error.
        #
        # +response+ The full response from Weather Underground.
        #
        # If +@options[:raise_errors]+ is set to true, this will raise an error. If that is set to false,
        # which is the default, it will return the error as a string. By default it will return `nil` if
        # there was no error found.
        def response_has_error?(response)
            if response && response['response'] && response['response']['error']
                error = "#{response['response']['error']['type']}: #{response['response']['error']['description']})"
                @options[:raise_errors] ? raise(WuError, error) : error
            end
        end

        # Returns a url string for the given icon. To set the icon-set that is used, please see
        # +initialize+ for options to be passed in.
        def icon_url(icon)
            icon_set_url % icon
        end

        # :nodoc:
        def radar_data_attrs(query, options = {}, escape = true)
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

        def is_true(str)
            /(1|true|yes)/i =~ str.to_s
        end

        def parse_query(query)
            query.to_s.gsub(/\s+/, '')
        end

        def autocomplete_url
            WeatherUndergroundApi::AUTOCOMPLETE_URL
        end

        def api_url
            WeatherUndergroundApi::API_URL % @api_key
        end

        def url_settings
            settings_for_url = []
            settings_for_url << "lang:#{@options[:lang]}" unless @options[:lang].blank?
            settings_for_url << "pws:#{@options[:pws]}" unless @options[:pws].blank?
            settings_for_url << "bestfct:#{@options[:bestfct]}" unless @options[:bestfct].blank?
            settings_for_url.join('/')
        end

        def get_json(url)
            JSON.parse(Net::HTTP.get_response(URI(url)).body)
        end

        def get_xml(url)
            # todo: Get the xml stuff to work and not just json.
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

        def icon_set_url
            "http://icons.wxug.com/i/c/#{@options[:icon_set]}/%s.gif"
        end
    end
end
