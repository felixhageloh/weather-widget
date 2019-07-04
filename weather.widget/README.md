# Übersicht Weather Widget

Made for [Übersicht](http://tracesof.net/uebersicht/)



Uses the [ipstack.com](https://ipstack.com/documentation "ipstack") to obtain your location, and the [Dark Sky API](https://darksky.net/dev/docs "Dark Sky API") to obtain the weather information.
Both APIs require registration to get an API key, so please copy and paste into get-weather script.

## Options

You can find all options `index.coffee` at the top of the file:

1. Default city and region. You can replace `<city>` with your city, and `<region>` with your region (state). This location is used in case the automatic location lookup fails, or if you switch off auto location (see below). Example:

    ```
    options =
      city  : 'Cupertino'
      region: 'CA'
    ```

2. Temperature units. Use 'us' for Fahrenheit and 'si' for Celsius.

3. Automatic location lookup. Set `useLocation` to `static` to disable auto location and instead use specified coordinates with `staticCoords`.

## Appearance

To tweak the appearance, just follow the directions inside `index.coffee`. You can switch between the original minimal icons by Erik Flowers, or use the standard Yahoo icons.

## Credits

Automatic location detection and switch to Yahoo api by @nickroberts
https://github.com/nickroberts

Ported to Dark Sky and ipstack API after Yahoo retired their API
https://github.com/Titousensei

Original icons by Erik Flowers
http://erikflowers.github.io/weather-icons/
