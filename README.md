WeatherUndergroundApi
=====================

This is a simple class object that uses the Weather Underground API.

Installation
------------

Add this line to your application's Gemfile:

    gem 'weather_underground_api'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install weather_underground_api

Usage
-----
Create a new class by passing in your api key

    @wu = WeatherUndergroundApi::Base.new(API_KEY)

Supported options:

- raise_errors: Will `raise` an error when `true` or just return the error message when `false`, when calling the helper method `response_has_error?`. (defaults: false).
- raise_api_error: If no key passed in during initialization and this is set to `true` it will `raise` an error.
- format: The format that you wish to do all of the calls by. Only supported option right now is `json`.
- lang: Language to be used. (defaults: 'EN').
- pws: Use personal weather stations for conditions. (defaults: '1')
- bestfct: Use Weather Underground Best Forecast for forecast. (defaults: '1')
- icon_set: The icon set to use. See [weather underground icon sets](http://www.wunderground.com/weather/api/d/docs?d=resources/icon-sets&apiref=77eba12431a68f79) for more details.
    
Supported features
------------------

**AutoComplete API**

Returns a list of locations or hurricanes which match against a partial query.

    results = @wu.autocomplete(query)
    
    $ results['RESULTS'][0]['name']
    => '<location_name>'
    
For all data attrs see: [autocomplete-api](http://www.wunderground.com/weather/api/d/docs?d=autocomplete-api&apiref=77eba12431a68f79)

**Geolookup**

Returns the city name, zip code / postal code, latitude-longitude coordinates and nearby personal weather stations.

    @geo = @wu.geolookup(query)
    
    $ $geo['location']['state']
    => 'OH'

For all data attrs see: [data/geolookup](http://www.wunderground.com/weather/api/d/docs?d=data/geolookup&apiref=77eba12431a68f79)

**Conditions**

Returns the current temperature, weather condition, humidity, wind, 'feels like' temperature, barometric pressure, and visibility.

    @current_conditions = @wu.conditions(query)
    
    $ @current_conditions['weather']
    => 'Overcast'

For all data attrs see: [data/conditions](http://www.wunderground.com/weather/api/d/docs?d=data/conditions&apiref=77eba12431a68f79)

**Forecast**

Returns a summary of the weather for the next 3 days. This includes high and low temperatures, a string text forecast and the conditions.

    @forecast = @wu.forecast(query)
    
    $ @forecast['forecast']['simpleforecast']['forecastday'][0]['pop']
    => 0

For all data attrs see: [data/forecast](http://www.wunderground.com/weather/api/d/docs?d=data/forecast&apiref=77eba12431a68f79)

**Alerts**

Returns the short name description, expiration time and a long text description of a severe alert, 
if one has been issued for the searched upon location.

    @alerts = @wu.alerts(query)
    
    $ @alerts.length
    => 1
    $ @alerts['alerts'][0]['description']
    => 'Severe Thunderstorm Warning'

For all data attrs see: [data/alerts](http://www.wunderground.com/weather/api/d/docs?d=data/alerts&apiref=77eba12431a68f79)

**Hourly**

Returns the next 36 hours from current time.

    @hourly = @wu.hourly(query)
    
    $ @hourly['hourly_forecast'][0]['temp']['english']
    => 75

For all data attrs see: [data/hourly](http://www.wunderground.com/weather/api/d/docs?d=data/hourly&apiref=77eba12431a68f79)

**Forecast10day**

Returns a summary of the weather for the next 10 days. This includes high and low temperatures, a string text forecast and the conditions.

You can call `extended_forecast` or `forecast10day`.

    @extended_forecast = @wu.extended_forecast(query)
    
    $ @extended_forecast['forecast']['simpleforecast']['forecastday'][0]['high']['fahrenheit']
    => 82

For all data attrs see: [data/forecast10day](http://www.wunderground.com/weather/api/d/docs?d=data/forecast10day&apiref=77eba12431a68f79)

**Radar**

Returns a static or animated radar image for a given location.

Radar function will only return a string url. This is so you can place it in an image_tag or serve it up to any of your assets.

    $ @wu.radar_url(query)
    => "http://api.wunderground.com/api/API_KEY/radar/q/QUERY.png?width=300&height=300&radius=100&newmaps=1"
    $ @wu.radar_url(query, width: '400', height: '400')
    => "http://api.wunderground.com/api/API_KEY/radar/q/QUERY.png?width=400&height=400&radius=100&newmaps=1"
    $ @wu.radar_url(query, query_type: 'animatedradar', type: 'gif')
    => "http://api.wunderground.com/api/API_KEY/animatedradar/q/QUERY.gif?width=300&height=300&radius=100&newmaps=1"

Required options that you can pass into the `radar_url` function are:

- :query_type Expects a string. Defaults to 'radar'. Choices are: 'radar' and 'animatedradar'.

_Note:_ If using 'animatedradar', you will need to pass in 'gif' or 'swf' as the :type or the request will fail.

For all data attrs see: [data/radar](http://www.wunderground.com/weather/api/d/docs?d=layers/radar&apiref=77eba12431a68f79)

**Satellite**

Returns a static or animated satellite image for a given location.

Satellite function will only return a string url. This is so you can place it in an image_tag or serve it up to any of your assets.

    $ @wu.satellite_url(query)
    => "http://api.wunderground.com/api/API_KEY/satellite/q/QUERY.png?width=300&height=300&radius=100&basemap=1"
    $ @wu.satellite_url(query, width: '400', height: '400')
    => "http://api.wunderground.com/api/API_KEY/satellite/q/QUERY.png?width=400&height=400&radius=100&basemap=1"
    $ @wu.satellite_url(query, query_type: 'animatedsatellite', type: 'gif')
    => "http://api.wunderground.com/api/API_KEY/animatedsatellite/q/QUERY.gif?width=300&height=300&radius=100&basemap=1"

- :query_type Expects a string. Defaults to 'satellite'. Choices are: 'satellite' and 'animatedsatellite'.

_Note:_ If using 'animatedsatellite', you will need to pass in 'gif' as the :type or the request will fail.

For all data attrs see: [data/satellite](http://www.wunderground.com/weather/api/d/docs?d=layers/satellite&apiref=77eba12431a68f79)

Helper functions
----------------

**Checking api key**

Check the api key

    $ @wu.api_key
    => API_KEY

**Checking options**

Check the options that are currently being used

    $ @wu.options
    => {:raise_errors=>false,:raise_api_error=>true,:format=>"json",:lang=>"EN",:pws=>"1",:bestfct=>"1",:icon_set=>"k"}

**Checking for errors**

Pass in the object that is returned for the api call.

This will return `nil` if there is no error. If there is an error it will either `raise` and error or return the error message 
(this is configured on initialization).

    @wu.response_has_error?(response)
    => nil


**Icon set url**

This will return a url string for the source of weather underground's api icon sets.

    @wu.icon_url('partlycloudy')
    => "http://icons.wxug.com/i/c/k/partlycloudy.gif"

To check out the icon-sets, click [here](http://www.wunderground.com/weather/api/d/docs?d=resources/icon-sets&apiref=77eba12431a68f79).

_Note:_ The icon set that is provided by Weather Underground. These are sent as .gif's and typically don't scale well. 
You might want to use a different icon set or use an icon font.

Contributing
------------

1. Fork it
2. [Donate](http://simpleweatherapp.herokuapp.com/about#donate)
3. [Visit weather underground](http://www.wunderground.com/?apiref=77eba12431a68f79)
