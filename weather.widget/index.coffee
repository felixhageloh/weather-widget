options =
  city  : "Cupertino"      # default city in case location detection fails
  region: "CA"             # default region in case location detection fails
  units : 'c'              # c for celcius. f for Fahrenheit

appearance =
  iconSet     : 'original' # "original" for the original icons, or "yahoo" for yahoo icons
  color       : '#fff'
  darkerColor : '#ccc'
  showLocation: true       # set to true to show your current location in the widget

refreshFrequency: 600000   # Update every 10 minutes

style: """
  icon-size = 120px

  top : 20px
  left: 10px
  width: 360px

  font-family: Helvetica Neue
  color: #{appearance.color}
  text-align: center

  @font-face
    font-family Weather
    src url(weather.widget/icons.svg) format('svg')

  .current
    line-height: 120px
    position: relative
    display: inline-block
    white-space: nowrap
    text-align: left

  .icon
    display: inline-block
    font-family: Weather
    vertical-align: top
    font-size: 80px
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

    .temp
      font-weight: 200
      font-size: 42px

    .text
      font-size: 16px

  .meta
    font-size: 12px
    margin: 16px 0 12px 0

    .date
      font-weight: 200
      color: #{appearance.darkerColor}
      margin-left: 4px

    .location
      font-weight: 500
      margin-left: 4px

  .yahoo .meta
    left: icon-size * 1.6

  .no-location .location
    display: none

  .forecast
    padding-top 20px
    border-top 1px solid #{appearance.darkerColor}
    font-size: 0
    line-height: 1

    .icon
      font-size: 22px
      line-height: 48px
      max-height: 48px
      max-width: 40px
      vertical-align: middle

      img
        margin-top: 6px
        width: 140%

    .entry
      display: inline-block
      font-size: 10px
      text-align: center
      width: 20%

      p
        line-height: 14px
        padding: 0
        margin: 0
        word-spacing: 2px

      .low
        color: #{appearance.darkerColor}
        font-weight: 200

  .error
    position: absolute
    top: 0
    left: 0
    right: 0
    bottom: 0
    font-size: 20px

    p
      font-size: 14px
"""

command: "#{process.argv[0]} weather.widget/get-weather #{options.city} #{options.region} #{options.units}"

appearance: appearance

render: -> """
  <div class='current #{@appearance.iconSet} #{ 'no-location' unless @appearance.showLocation }'>
    <div class='icon'></div>
    <div class='details'>
      <div class='today'>
        <span class='temp'></span>
        <span class='text'></span>
      </div>
      <div class='meta'>
        <span class='date'></span>
        <span class='location'></span>
      </div>
    </div>
  </div>
  <div class='forecast'></div>
"""

update: (output, domEl) ->
  @$domEl = $(domEl)

  data    = JSON.parse(output)
  channel = data.query?.results?.weather?.rss?.channel
  return @renderError(data) unless channel

  @renderCurrent channel
  @renderForecast channel

  @$domEl.find('.error').remove()
  @$domEl.children().show()

renderCurrent: (channel) ->
  weather  = channel.item
  location = channel.location
  date     = new Date()

  el = @$domEl.find('.current')
  el.find('.temp').text "#{Math.round(weather.condition.temp)}°"
  el.find('.text').text weather.condition.text
  el.find('.date').html @dayMapping[date.getDay()]
  el.find('.location').html location.city+', '+location.region
  el.find('.icon').html @getIcon(
    weather.condition.code,
    @appearance.iconSet,
    @getDayOrNight channel.astronomy
  )

renderForecast: (channel) ->
  forecastEl = @$domEl.find('.forecast')
  forecastEl.html ''
  for day in channel.item.forecast[0..4]
    forecastEl.append @renderForecastItem(day, @appearance.iconSet)

renderForecastItem: (data, iconSet) ->
  date = new Date data.date
  icon = @getIcon(data.code, iconSet, 'd')

  """
    <div class='entry'>
      <div class='day'>#{@dayMapping[date.getDay()]}</div>
      <div class='icon'>#{icon}</div>
      <p>
        <span class='high'>#{Math.round(data.high)}°</span>
        <span class='low'>#{Math.round(data.low)}°</span>
      </p>
    </div>
  """

renderError: (data) ->
  console.error 'weather widget:', data.error
  @$domEl.children().hide()

  @$domEl.append """
    <div class="error">
      Could not retreive weather data for #{data.location}.
      <p>Are you connected to the internet?</p>
    <div>
  """

dayMapping:
  0: 'Sunday'
  1: 'Monday'
  2: 'Tuesday'
  3: 'Wednesday'
  4: 'Thursday'
  5: 'Friday'
  6: 'Saturday'

# Return either 'd' if the sun is still up, or 'n' if it is gone
getDayOrNight: (data) ->
  now     = new Date()
  sunrise = @parseTime data.sunrise
  sunrise = new Date(
    now.getFullYear(),
    now.getMonth(),
    now.getDate(),
    sunrise.hour,
    sunrise.minute
  ).getTime()

  sunset  = @parseTime data.sunset
  sunset  = new Date(
    now.getFullYear(),
    now.getMonth(),
    now.getDate(),
    sunset.hour,
    sunset.minute
  ).getTime()

  now = now.getTime()

  if now > sunrise and now < sunset then 'd' else 'n'

# parses a time string in US format: hh:mm am|pm
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

iconMapping:
  0    : "&#xf021;" # tornado
  1    : "&#xf021;" # tropical storm
  2    : "&#xf021;" # hurricane
  3    : "&#xf019;" # severe thunderstorms
  4    : "&#xf019;" # thunderstorms
  5    : "&#xf019;" # mixed rain and snow
  6    : "&#xf019;" # mixed rain and sleet
  7    : "&#xf019;" # mixed snow and sleet
  8    : "&#xf019;" # freezing drizzle
  9    : "&#xf019;" # drizzle
  10   : "&#xf019;" # freezing rain
  11   : "&#xf019;" # showers
  12   : "&#xf019;" # showers
  13   : "&#xf01b;" # snow flurries
  14   : "&#xf01b;" # light snow showers
  15   : "&#xf01b;" # blowing snow
  16   : "&#xf01b;" # snow
  17   : "&#xf019;" # hail
  18   : "&#xf019;" # sleet
  19   : "&#xf002;" # dust
  20   : "&#xf014;" # foggy
  21   : "&#xf014;" # haze
  22   : "&#xf014;" # smoky
  23   : "&#xf021;" # blustery
  24   : "&#xf021;" # windy
  25   : "&#xf021;" # cold
  26   : "&#xf013;" # cloudy
  27   : "&#xf031;" # mostly cloudy (night)
  28   : "&#xf002;" # mostly cloudy (day)
  29   : "&#xf031;" # partly cloudy (night)
  30   : "&#xf002;" # partly cloudy (day)
  31   : "&#xf02e;" # clear (night)
  32   : "&#xf00d;" # sunny
  33   : "&#xf031;" # fair (night)
  34   : "&#xf00c;" # fair (day)
  35   : "&#xf019;" # mixed rain and hail
  36   : "&#xf00d;" # hot
  37   : "&#xf019;" # isolated thunderstorms
  38   : "&#xf019;" # scattered thunderstorms
  39   : "&#xf019;" # scattered thunderstorms
  40   : "&#xf019;" # scattered showers
  41   : "&#xf01b;" # heavy snow
  42   : "&#xf01b;" # scattered snow showers
  43   : "&#xf01b;" # heavy snow
  44   : "&#xf00c;" # partly cloudy
  45   : "&#xf019;" # thundershowers
  46   : "&#xf00c;" # snow showers
  47   : "&#xf019;" # isolated thundershowers
  3200 : "&#xf00c;" # not available


