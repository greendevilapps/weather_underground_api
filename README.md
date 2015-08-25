# WeatherUndergroundApi

This is a simple class object that uses the Weather Underground API.

## Installation

Add this line to your application's Gemfile:

    gem 'weather_underground_api'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install weather_underground_api

## Usage

    @wu = WeatherUndergroundApi::Base.new(API_KEY)
    @current_conditions = @wu.conditions(query_location)
For all data attrs see: http://www.wunderground.com/weather/api/d/docs?d=data/conditions

## Contributing

1. Fork it
2. Donate
