# Übersicht Weather Widget

Made for [Übersicht](http://tracesof.net/uebersicht/)

Uses the [freegeoip.net](http://freegeoip.net/ "freegeoip.net") api to obtain your location, and the [Yahoo Weather api](https://developer.yahoo.com/weather// "Yahoo Weather api") to obtain the weather information.

## Options

You can find all options `index.coffee` at the top of the file:

1. Default city and region. You can replace `<city>` with your city, and `<region>` with your region (state). This location is used in case the automatic location lookup fails, or if you switch off auto location (see below). Example:

    ```
    options =
      city  : 'Cupertino'
      region: 'CA'
    ```

2. Temperature units. Use 'f' for Fahrenheit and 'c' for Celsius.

3. Automatic location lookup. Set `staticLocation` to `true` to disable auto location and instead always use the default city and region.

## Appearance

To tweak the appearance, just follow the directions inside `index.coffee`. You can switch between the original minimal icons by Erik Flowers, or use the standard Yahoo icons.

## Credits

Automatic location detection and switch to Yahoo api by @nickroberts
https://github.com/nickroberts

Original icons by Erik Flowers
http://erikflowers.github.io/weather-icons/
