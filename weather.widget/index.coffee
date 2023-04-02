options =
  city          : 'Cupertino'                         # static city location
  region        : 'CA'                                # static region location
  units         : 'metric'                            # metric for celcius. imperial for Fahrenheit
  useLocation   : 'auto'                              # set to 'static' to disable automatic location lookup
  lang          : 'en'                                # set language code for the current day summary
  posApiKey     : 'REPLACE_WITH_YOUR_API_KEY'         # for static positions, https://positionstack.com/
  geoipApiKey   : 'REPLACE_WITH_YOUR_API_KEY'         # for dynamic positions, https://ipstack.com/
  weatherApiKey : 'REPLACE_WITH_YOUR_API_KEY'         # https://home.openweathermap.org/api_keys

appearance =
  color         : '#000'                              # configure your colors here
  darkerColor   : 'rgba(#000, 0.8)'
  baseFontSize  : 42                                  # the base font size, the size of the temperature
  showLocation  : true                                # set to true to show your current location in the widget
  showDay       : true                                # set to true to show the current day of the week
  showWeatherText: true                               # set to true to show the text label for the weather
  showForecast  : true                                # set to true to show the 5 day forecast

refreshFrequency: 600000                              # Update every 10 minutes

style: """
  top  : 10px
  right : 150px
  width: #{appearance.baseFontSize * 8.57}px

  font-family: Helvetica Neue
  color      : #{appearance.color}
  text-align : center
  pointer-events: none

  .current .temperature
    font-size  : #{appearance.baseFontSize}px
    font-weight: 200

  .current .text
    font-size: #{appearance.baseFontSize * .38}px

  .current .day
    font-size  : #{appearance.baseFontSize * .25}px
    font-weight: 200
    color: #{appearance.darkerColor}

  .current .location
    font-size  : #{appearance.baseFontSize * .25}px
    font-weight: 500
    margin-left: 4px

  .forecast .day
    font-size: #{appearance.baseFontSize * .24}px

  .forecast .temperatures
    font-size: 10px
    font-size  : #{appearance.baseFontSize * .24}px

  .forecast .temperatures .high
    margin-right: 2px

  .forecast .temperatures .low
    color: #{appearance.darkerColor}
    font-weight: 200

  @font-face
    font-family Weather
    src url(weather.widget/icons.svg) format('svg')

  icon-size = #{appearance.baseFontSize * 2.86}px

  .current
    line-height: #{appearance.baseFontSize * 2.86}px
    position: relative
    display: inline-block
    white-space: nowrap
    text-align: left

  .icon
    display: inline-block
    font-family: Weather
    vertical-align: top
    font-size: #{appearance.baseFontSize * 1.9}px
    max-height: icon-size
    vertical-align: middle
    text-align: center
    width: icon-size * 1.2
    max-width: icon-size * 1.2

    img
      width: 100%

  .details
    display: inline-block
    vertical-align: bottom
    line-height: 1
    text-align: left

  .meta
    margin: 16px 0 12px 0

    .day
      margin-left: 4px

  .no-location .location
    visibility: hidden

  .no-day .day
    display: none

  .no-weather-text .text
    display: none

  .forecast
    padding-top 20px
    border-top 1px solid #{appearance.darkerColor}
    font-size: 0
    line-height: 1

    .icon
      font-size: #{appearance.baseFontSize * .52}px
      line-height: #{appearance.baseFontSize * 1.24}px
      max-height: #{appearance.baseFontSize * 1.24}px
      max-width: #{appearance.baseFontSize * .95}px
      vertical-align: middle

      img
        margin-top: 6px
        width: 140%

    .entry
      display: inline-block
      text-align: center
      width: 20%

    .temperatures
      padding: 0
      margin: 0

  .error
    position: absolute
    top: 0
    left: 0
    right: 0
    bottom: 0
    font-size: 20px

    p
      font-size: #{appearance.baseFontSize * .33}px
"""

command: "#{process.argv[0]} weather.widget/get-weather \
                            \"#{options.city}\" \
                            \"#{options.region}\" \
                            #{options.units} \
                            #{options.useLocation}
                            #{options.lang}
                            #{options.posApiKey}
                            #{options.geoipApiKey}
                            #{options.weatherApiKey}"

appearance: appearance

render: -> """
  <div class='current #{@appearance.iconSet}
              #{ 'no-location' unless @appearance.showLocation }
              #{ 'no-day' unless @appearance.showDay }
              #{ 'no-weather-text' unless @appearance.showWeatherText }
  ' style='color: #{appearance.color}'>
    <div class='icon'></div>
    <div class='details'>
      <div class='today'>
        <span class='temperature'></span>
        <span class='text'></span>
      </div>
      <div class='meta'>
        <span class='day'></span>
        <span class='location'></span>
      </div>
    </div>
  </div>
  <div class="forecast" #{ 'style="display:none; border-top: 0"' unless @appearance.showForecast } style='color: #{appearance.color}'></div>
"""

update: (output, domEl) ->
  @$domEl = $(domEl)

  try
    channel = JSON.parse(output)
  catch e
    return @renderError(null, e.message)

  if channel
    delete localStorage.cachedOutput
    localStorage.setItem("cachedOutput", output)
  else
    channel = JSON.parse(localStorage.getItem("cachedOutput"))
    return @renderError(channel, output) unless channel

  if channel.cod # OpenWeather returns error code like 429
    return @renderError(channel, channel.message)

  if !channel.current
    return @renderError(channel, "No current weather data")

  @renderCurrent channel
  @renderForecast channel if @appearance.showForecast

  @$domEl.find('.error').remove()
  @$domEl.children().show()

renderCurrent: (channel) ->
  weather  = channel.current
  date     = new Date()

  el = @$domEl.find('.current')
  el.find('.temperature').text "#{Math.round(weather.temp)}°"
  el.find('.text').text weather.weather[0].main if @appearance.showWeatherText
  el.find('.day').html @dayMapping[date.getDay()] if @appearance.showDay
  @$domEl.find('.location').html channel.location if @appearance.showLocation
  el.find('.icon').html @getIcon(weather.weather[0].icon)

renderForecast: (channel) ->
  forecastEl = @$domEl.find('.forecast')
  forecastEl.html ''
  for day in channel.daily[0..4]
    forecastEl.append @renderForecastItem(day, @appearance.iconSet)

renderForecastItem: (data, iconSet) ->
  date = new Date(data.dt * 1000)
  icon = @getIcon(data.weather[0].icon)

  """
    <div class='entry'>
      <div class='day'>#{@dayMapping[date.getDay()]}</div>
      <div class='icon'>#{icon}</div>
      <p class='temperatures'>
        <span class='high'>#{Math.round(data.temp.max)}°</span>
        <span class='low'>#{Math.round(data.temp.min)}°</span>
      </p>
    </div>
  """

renderError: (data, message) ->
  console.error 'weather widget:', data.error if data?.error
  @$domEl.children().hide()

  message ?= """
     Could not retreive weather data for #{data.location}.
     <p>#{data.error}</p>
  """

  @$domEl.append "<div class=\"error\">#{message}<div>"

# parses a time in unix time
parseTime: (usTimeString) ->
  parts = usTimeString.match(/(\d+):(\d+) (\w+)/)

  hour   = Number(parts[1])
  minute = Number(parts[2])
  am_pm  = parts[3].toLowerCase()

  hour += 12 if am_pm == 'pm'

  hour: hour, minute: minute

getIcon: (code) ->
  return @iconMapping['unknown'] unless code
  @iconMapping[code]

dayMapping:
  0: 'Sunday'
  1: 'Monday'
  2: 'Tuesday'
  3: 'Wednesday'
  4: 'Thursday'
  5: 'Friday'
  6: 'Saturday'

iconMapping:
  # clear sky
  "01d": "&#xf00d;",
  "01n": "&#xf02e;",

  # few clouds
  "02d": "&#xf002;",
  "02n": "&#xf086;",

  # scattered clouds
  "03d": "&#xf041;",
  "03n": "&#xf041;",

  #broken clouds
  "04d": "&#xf013;",
  "04n": "&#xf013;",

  # shower rain
  "09d": "&#xf019;",
  "09n": "&#xf019;",

  # rain
  "10d": "&#xf008;",
  "10n": "&#xf028;",

  # thunderstorm
  "11d": "&#xf010;",
  "11n": "&#xf02d;",

  # snow
  "13d": "&#xf01b;",
  "13n": "&#xf01b;",

  # mist
  "50d": "&#xf014;",
  "50n": "&#xf014;",

  # not available
  "" : "&#xf00c;"
