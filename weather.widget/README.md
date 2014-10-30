# Übersicht Weather Widget

Made for [Übersicht](http://tracesof.net/uebersicht/)

This uses the [freegeoip.net](http://freegeoip.net/ "freegeoip.net") api to obtain your location, and the [Yahoo Weather api](https://developer.yahoo.com/weather// "Yahoo Weather api") to obtain the weatehr information.

## Setup

By default, this is dynamic, based on your location (via your current ip address).

If you want to make this static, you will need to edit some configurations in the `weather.py` file.

1. Replace `<city>` with your city, and `<region>` with your region (state)

*You should always set the `city` and `region` in the `weather.py` file, as sometimes the geolocation doesn't work, or is down*

### Static Location

1. Comment out the dynamic section

### Dynamic Location

1. Uncomment out the dynamic section

## Credits

Original widget by the Übersicht team:
https://github.com/felixhageloh/weather-widget
