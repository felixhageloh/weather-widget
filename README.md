# Übersicht Weather Widget

Made for [Übersicht](http://tracesof.net/uebersicht/)

Uses the [positionstack.com](https://positionstack.com/documentation), [ipstack.com](https://ipstack.com/documentation) to obtain your location, and the [OpenWeather API](https://home.openweathermap.org/users/sign_up) to obtain the weather information.
All APIs require registration to get an API key, so please configure those in the `index.coffe` script.

## Options

You can find all options `index.coffee` at the top of the file:

1. Default city and region. Set `city` and `region` if you switch off `auto` location (see below). Example:

    ```
    options =
      city    : 'Cupertino'
      region  : 'CA'
    ```

2. Temperature `units`. Use `imperial` for Fahrenheit and `metric` for Celsius.

3. Automatic location lookup. Set `useLocation` to `static` to disable auto location and instead always use the default city and region.

4. API keys `posApiKey`, `geoipApiKey` and `weatherApiKey` are required to obtain responses from the PositionStack, IpStack and OpenWeather APIs.

## Appearance

To tweak the appearance, just follow the directions inside `index.coffee`. You can switch between the original minimal icons by Erik Flowers, or use the standard Yahoo icons.

## Credits

Automatic location detection and switch to Yahoo api by @nickroberts
https://github.com/nickroberts

Ported to Dark Sky and ipstack API after Yahoo retired their API
https://github.com/Titousensei

Original icons by Erik Flowers
http://erikflowers.github.io/weather-icons/

