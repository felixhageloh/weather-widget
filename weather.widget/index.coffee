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
  top : 20px
  left: 10px

  font-family: Helvetica Neue
  color: #{appearance.color}
  line-height: 110px
  text-align: center

  @font-face
    font-family Weather
    src url(weather.widget/icons.svg) format('svg')

  .icon
    display: inline-block
    font-family: Weather
    vertical-align: top
    overflow: hidden
    font-size: 80px
    max-height: 110px
    max-width: 110px

    img
      width: 140%
      margin-top: 16px

  .today
    font-size: 12px
    display: inline-block
    vertical-align: bottom
    line-height: 1
    margin-left: 24px
    text-align: left

    span
      display: inline-block
      margin-right: 4px

    .date
      font-weight: 200
      color: #{appearance.darkerColor}
      margin-left: 4px

    .region
      font-weight: 500

    .temp
      font-weight: 200
      font-size: 42px

    .text
      font-size: 16px

  .forecast
    margin-top 12px
    padding-top 16px
    border-top 1px solid #{appearance.darkerColor}
    font-size: 0
    line-height: 1
    width: 360px

    .icon
      font-size: 24px
      line-height: 44px
      max-height: 44px
      max-width: 40px
      vertical-align: middle

      img
        margin-top: 6px

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
    font-size: 14px
    line-height: 1
    .message
      color: red
      margin-top: 5px
"""

# The command that runs to get the locatin and weather info
command: "#{process.argv[0]} weather.widget/get-weather.js #{options.city} #{options.region} #{options.units}"

appearance: appearance

render: (o)-> """
  <div class='weather-widget'>
    <div class='icon'></div>
    <div class='today'>
      <p>
        <span class='temp'></span>
        <span class='text'></span>
      </p>
      <p>
        <span class='date'></span>
        <span class='region'></span>
      </p>
    </div>
    <div class='forecast'></div>
  </div>
"""

update: (output, domEl) ->
  # Cache the element
  $domEl = $(domEl)

  # Parse the JSON data
  data  = JSON.parse(output)
  return @renderError(data, $domEl) unless data.query?.results?

  # Set some local variables to make things a bit easier
  channel  = data.query.results.weather.rss.channel
  location = channel.location
  weather  = channel.item
  date     = new Date()

  # Render the top icon and summary section
  if @appearance.showLocation
    $domEl.find('.region')
      .text("#{location.city}, #{location.region}")
      .addClass 'show'

  $domEl.find('.date').html @dayMapping[date.getDay()]
  $domEl.find('.temp').html """
    <span class='hi'>#{Math.round(weather.condition.temp)}°</span>
  """
  $domEl.find('.text').text weather.condition.text

  # Render the forecast section
  forecastEl = $domEl.find('.forecast').html('')
  for day in weather.forecast[0..4]
    forecastEl.append @renderForecast(day, @appearance.iconSet)

  if @appearance.iconSet is 'yahoo'
    dayOrNight = @getDayOrNight channel.astronomy
    $domEl.find('.icon').html @getYahooIcon(weather.condition.code, dayOrNight)
  else
    $domEl.find('.icon').html @getIcon(weather.condition.code)

renderForecast: (data, iconSet) ->
  date = new Date data.date
  if iconSet is 'yahoo'
    icon = @getYahooIcon(data.code, 'd')
  else
    icon = @getIcon(data.code)

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

renderError: (data, $domEl) ->
  $domEl.find('.weather-widget').html """
    <div class="error">
      Could not retreive weather data for #{data.location}.
      <p>Are you connected to the internet?</p>
      <div class="message">#{data.error ? ''}</div>
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

getIcon: (code) ->
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


