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

### Troubleshooting

Sometimes there is an issue with the `urllib2` library requesting the url. If you receive an "HTTP version not supported" error (or any other one), you can use the python requests library:

1. Install the [requests](http://python-requests.org) library: `pip install requests`.
2. Comment out the `import urllib2`, along with the 2 lines where `urllib2.openurl` is used, also commenting out the top 2 exception handlers for `urllib2`.
3. Uncomment the `import requests` line, along with the 2 spots it uses `requests.get`, and also the exception handler.

## Credits

Original widget by the Übersicht team:
https://github.com/felixhageloh/weather-widget
