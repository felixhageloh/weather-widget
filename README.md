# Übersicht Weather Widget

Made for [Übersicht](http://tracesof.net/uebersicht/)

![the widget in action]
(https://raw.githubusercontent.com/nickroberts/dynamic-weather-widget/master/screenshot.png)

This uses the [freegeoip.net](http://freegeoip.net/ "freegeoip.net") api to obtain your location, and the [Yahoo Weather api](https://developer.yahoo.com/weather// "Yahoo Weather api") to obtain the weatehr information.

## Setup

By default, this is dynamic, based on your location (via your current ip address).

If you want to make this static, you will need to edit some configurations in the `weather.py` file.

### Static Location

You will need to do 3 things inside of the `weather.py` file:

1. Uncomment out the section for the static location
2. Comment out the dynamic section
3. Replace `<city>` with your city, and `<region>` with your region (state)

### Dynamic Location

You will need to do 2 things inside of the `weather.py` file:

1. Uncomment out the dynamic section
2. Comment out the section for the static location

## Credits

Original widget by the Übersicht team:
https://github.com/felixhageloh/weather-widget
