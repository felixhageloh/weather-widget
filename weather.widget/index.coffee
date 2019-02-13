options =
  city          : "Troy"       # default city in case location detection fails
  region        : "NY"              # default region in case location detection fails
  units         : 'us'              # si for celcius. us for Fahrenheit
  useLocation   : 'auto'            # set to 'static' to disable automatic location lookup
  lang          : 'en'              # set language code for the current day summary

appearance =
  iconSet       : 'original'        # "original" for the original icons, or "yahoo" for yahoo icons
  color         : '#fff'            # configure your colors here
  darkerColor   : 'rgba(#fff, 0.8)'
  baseFontSize  : 42                # the base font size, the size of the temperature
  showLocation  : true              # set to true to show your current location in the widget
  showDay       : true              # set to true to show the current day of the week
  showWeatherText: true             # set to true to show the text label for the weather
  showForecast  : true              # set to true to show the 5 day forecast

refreshFrequency: 600000            # Update every 10 minutes

style: """
  top  : 10px
  right : 150px
  width: #{appearance.baseFontSize * 8.57}px

  font-family: Helvetica Neue
  color      : #{appearance.color}
  text-align : center

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

  .yahoo .icon
    width: icon-size * 1.6
    max-width: icon-size * 1.6

  .details
    display: inline-block
    vertical-align: bottom
    line-height: 1
    text-align: left

  .meta
    margin: 16px 0 12px 0

    .day
      margin-left: 4px

  .yahoo .meta
    left: icon-size * 1.6

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
                            #{options.lang}"

appearance: appearance

render: -> """
  <div class='current #{@appearance.iconSet}
              #{ 'no-location' unless @appearance.showLocation }
              #{ 'no-day' unless @appearance.showDay }
              #{ 'no-weather-text' unless @appearance.showWeatherText }
  '>
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
  <div class="forecast" #{ 'style="display:none; border-top: 0"' unless @appearance.showForecast }></div>
"""

update: (output, domEl) ->
  @$domEl = $(domEl)

  channel = JSON.parse(output)
  if channel
    delete localStorage.cachedOutput
    localStorage.setItem("cachedOutput", output)
  else
    channel = JSON.parse(localStorage.getItem("cachedOutput"))
    return @renderError(channel, output) unless channel

  if channel.code  # Dark Sky returns error code like 400
    return @renderError(data, channel.item?.title)

  @renderCurrent channel
  @renderForecast channel if @appearance.showForecast

  @$domEl.find('.error').remove()
  @$domEl.children().show()

renderCurrent: (channel) ->
  weather  = channel.currently
  date     = new Date()

  el = @$domEl.find('.current')
  el.find('.temperature').text "#{Math.round(weather.temperature)}°"
  el.find('.text').text weather.summary if @appearance.showWeatherText
  el.find('.day').html @dayMapping[date.getDay()] if @appearance.showDay
  @$domEl.find('.location').html channel.location if @appearance.showLocation
  el.find('.icon').html @getIcon(
    weather.icon,
    @appearance.iconSet,
    @getDayOrNight channel.daily.data[0]
  )

renderForecast: (channel) ->
  forecastEl = @$domEl.find('.forecast')
  forecastEl.html ''
  for day in channel.daily.data[0..4]
    forecastEl.append @renderForecastItem(day, @appearance.iconSet)

renderForecastItem: (data, iconSet) ->
  date = new Date(data.time*1000)
  icon = @getIcon(data.icon, iconSet, 'd')

  """
    <div class='entry'>
      <div class='day'>#{@dayMapping[date.getDay()]}</div>
      <div class='icon'>#{icon}</div>
      <p class='temperatures'>
        <span class='high'>#{Math.round(data.temperatureHigh)}°</span>
        <span class='low'>#{Math.round(data.temperatureLow)}°</span>
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

# Return either 'd' if the sun is still up, or 'n' if it is gone
getDayOrNight: (data) ->
  sunrise = new Date(data.sunriseTime*1000).getTime()
  sunset  = new Date(data.sunsetTime*1000).getTime()
  now     = new Date().getTime()

  if now > sunrise and now < sunset then 'd' else 'n'

# parses a time in unix time
parseTime: (usTimeString) ->
  parts = usTimeString.match(/(\d+):(\d+) (\w+)/)

  hour   = Number(parts[1])
  minute = Number(parts[2])
  am_pm  = parts[3].toLowerCase()

  hour += 12 if am_pm == 'pm'

  hour: hour, minute: minute

getIcon: (code, iconSet, dayOrNight) ->
  if iconSet is 'yahoo'
    @getYahooIcon(code, dayOrNight)
  else
    @getOriginalIcon(code)

getOriginalIcon: (code) ->
  return @iconMapping['unknown'] unless code
  @iconMapping[code]

getYahooIcon: (code, dayOrNight) ->
  # Returns the image element from Yahoo with the proper image
  imageURL = "http://l.yimg.com/a/i/us/nws/weather/gr/#{code}#{dayOrNight}.png"
  '<img src="' + imageURL + '">'

dayMapping:
  0: 'Sunday'
  1: 'Monday'
  2: 'Tuesday'
  3: 'Wednesday'
  4: 'Thursday'
  5: 'Friday'
  6: 'Saturday'

iconMapping:
  "rain": "&#xf019;"
  "snow": "&#xf01b;"
  "sleet": "&#xf019;"
  "fog": "&#xf014;"
  "wind": "&#xf021;"
  "cloudy": "&#xf013;"
  "partly-cloudy-night": "&#xf031;"
  "partly-cloudy-day": "&#xf002;"
  "clear-night": "&#xf02e;"
  "clear-day": "&#xf00d;"
  "" : "&#xf00c;" # not available
