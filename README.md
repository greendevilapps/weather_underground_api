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

- raise_errors: Will `raise` an error when `true` or just return the error message when `false`, when calling the helper method `response_has_error?`.
- raise_api_error: If no key passed in during initialization and this is set to `true` it will `raise` an error.
- format: The format that you wish to do all of the calls by. Only supported option right now is `json`.
- lang: Language to be used. (defaults: 'EN').
- pws: Use personal weather stations for conditions. (defaults: '1')
- bestfct: Use Weather Underground Best Forecast for forecast. (defaults: '1')
    
Supported features
------------------

**AutoComplete API**

    results = @wu.autocomplete(query)
    
    $ results['RESULTS'][0]['name']
    => '<location_name>'
    
For all data attrs see: [autocomplete-api](http://www.wunderground.com/weather/api/d/docs?d=autocomplete-api&apiref=77eba12431a68f79)

**Geolookup**

    @geo = @wu.geolookup(query)
    
    $ $geo['location']['state']
    => 'OH'

For all data attrs see: [data/geolookup](http://www.wunderground.com/weather/api/d/docs?d=data/geolookup&apiref=77eba12431a68f79)

**Conditions**

    @current_conditions = @wu.conditions(query)
    
    $ @current_conditions['weather']
    => 'Overcast'

For all data attrs see: [data/conditions](http://www.wunderground.com/weather/api/d/docs?d=data/conditions&apiref=77eba12431a68f79)

**Forecast**

    @forecast = @wu.forecast(query)
    
    $ @forecast['forecast']['simpleforecast']['forecastday'][0]['pop']
    => 0

For all data attrs see: [data/forecast](http://www.wunderground.com/weather/api/d/docs?d=data/forecast&apiref=77eba12431a68f79)

**Alerts**

    @alerts = @wu.alerts(query)
    
    $ @alerts.length
    => 1
    $ @alerts['alerts'][0]['description']
    => 'Severe Thunderstorm Warning'

For all data attrs see: [data/alerts](http://www.wunderground.com/weather/api/d/docs?d=data/alerts&apiref=77eba12431a68f79)

**Hourly**

    @hourly = @wu.hourly(query)
    
    $ @hourly['hourly_forecast'][0]['temp']['english']
    => 75

For all data attrs see: [data/hourly](http://www.wunderground.com/weather/api/d/docs?d=data/hourly&apiref=77eba12431a68f79)

**Forecast10day**

You can call `extended_forecast` or `forecast10day`.

    @extended_forecast = @wu.extended_forecast(query)
    
    $ @extended_forecast['forecast']['simpleforecast']['forecastday'][0]['high']['fahrenheit']
    => 82

For all data attrs see: [data/forecast10day](http://www.wunderground.com/weather/api/d/docs?d=data/forecast10day&apiref=77eba12431a68f79)

**Radar**

Radar function will only return a string url. This is so you can place it in an image_tag or serve it up to any of your assets.

    $ @wu.radar_url(query)
    => "http://api.wunderground.com/api/API_KEY/radar/q/QUERY.png?width=300&height=300&radius=100&newmaps=1"
    $ @wu.radar_url(query, width: '400', height: '400')
    => "http://api.wunderground.com/api/API_KEY/radar/q/QUERY.png?width=400&height=400&radius=100&newmaps=1"

Required options that you can pass into the `radar_url` function are:

- type: gif, png, or swf (defaults: png)
- radius: 100 is close, 1000 is country (defaults: 100)
- width: Width of image in pixels (defaults: 300)
- height: Height of image in pixels (defaults: 300)
- newmaps: Transparent image (default) or show basemap (defaults: 1)

For all data attrs see: [data/forecast10day](http://www.wunderground.com/weather/api/d/docs?d=layers/radar&apiref=77eba12431a68f79)

Helper functions
----------------

**Checking for errors**

Pass in the object that is returned for the api call.

This will return `nil` if there is no error. If there is an error it will either `raise` and error or return the error message 
(this is configured on initialization).

    @wu.response_has_error?(response)
    => nil


**Radar url data-attrs**

This will create `data-attrs` for radar conditions.

    @wu.radar_data_attrs(query)
    => 'data-radar-height="300" data-radar-newmaps="1" data-radar-query-url="http://api.wunderground.com/api/API_KEY/radar/q/" data-radar-query="QUERY" data-radar-radius="100" data-radar-type="png" data-radar-width="300"'

Contributing
------------

1. Fork it
2. [Donate](http://simpleweatherapp.herokuapp.com/about#donate)
3. [Visit weather underground](http://www.wunderground.com/?apiref=77eba12431a68f79)
