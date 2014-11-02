options =
  city  : "Cupertino"      # default city in case location detection fails
  region: "CA"             # default region in case location detection fails
  units : 'f'              # c for celcius. f for Fahrenheit

appearance:
  iconSet     : 'original' # "original" for the original icons, or "yahoo" for the yahoo icons
  showLocation: true       # set to true to show your current location in the widget

refreshFrequency: 600000   # Update every 10 minutes

style: """
  top: 10px
  left: 10px
  color: #fff
  font-family: Helvetica Neue

  .error
    font-size: 12px
    .message
      color: red
      font-size: 8px
      margin-top: 5px

  @font-face
    font-family Weather
    src url(weather.widget/icons.svg) format('svg')

  .cf:before, .cf:after
    content: " "
    display: table

  .cf:after
    clear: both;

  img
    max-width: 100%

  .icon
    display: inline-block
    font-family: Weather
    font-size: 110px
    line-height: 110px
    margin-top: 10px
    margin-right: 20px
    vertical-align: middle

  .today
    .icon
      display: inline-block

      &.yahoo
        margin-top: 0px
        margin-bottom: -70px
        margin-right: -70px
    .region
      font-weight: 400
      font-size: 32px
      margin-top: 15px
      &.show
        margin-top: 0
    .date
      font-weight: 200
      font-size: 12px
    .temp
      display: inline-block
      font-weight: 200
      font-size: 32px
    .text
      display: inline-block
    .summary
      float: left
      margin-top: 20px

  .forecast
    margin-top 10px
    padding-top 20px
    border-top 1px solid #fff
    font-size: 0
    width: 360px

    .icon
      font-size: 30px
      line-height: 40px
      margin-top: 5px
      margin-right: 0px

    .entry
      display: inline-block
      font-size: 10px
      text-align: center
      width: 20%

      label
        display: inline-block
        width: 40%

      img
        margin-bottom: -15%
        margin-left: 18%
        margin-top: 5%

      .high
        color: #fff
      .low
        color: #ccc
"""

# The command that runs to get the locatin and weather info
command: "#{process.argv[0]} weather.widget/get-weather.js #{options.city} #{options.region} #{options.units}"

render: (o)-> """
  <div class='weather-widget'>
    <div class='today cf'>
      <div class='icon'></div>
      <div class='summary'>
        <div class='region'></div>
        <div class='date'></div>
        <div>
          <div class='temp'></div>
          <div class='text'></div>
        </div>
      </div>
    </div>
    <div class='forecast'></div>
  </div>
"""

update: (output, domEl) ->
  # Parse the JSON data
  data  = JSON.parse(output)

  # Cache the element
  $domEl = $(domEl)

  if data.error
    $domEl.find('.weather-widget').html '<div class="error"><div>' +
      'There was an error obtaining the weather.<br>' +
      'Are you connected to the internet?</div>' +
      '<div class="message">err: ' + data.error + '</div>'
      '</div>'
  else
    # Set some local variables to make things a bit easier
    channel  = data.query.results.weather.rss.channel
    location = channel.location
    weather  = channel.item
    date     = new Date weather.condition.date

    # Render the top icon and summary section
    if @appearance.showLocation
      $domEl.find('.region')
        .text("#{location.city}, #{location.region}")
        .addClass 'show'

    $domEl.find('.date').text @dayMapping[date.getDay()]
    $domEl.find('.temp').html """
      <span class='hi'>#{Math.round(weather.condition.temp)}°</span>
    """
    $domEl.find('.text').text weather.condition.text

    # Render the forecast section
    forecastEl = $domEl.find('.forecast').html('')
    for day in weather.forecast[0..4]
      forecastEl.append @renderForecast(day, @appearance.iconSet)

    if @appearance.iconSet is 'yahoo'
      # Determine if it is day or night, so we can show the correct icon
      dayOrNight = @getDayOrNight channel.astronomy
      $domEl.find('.icon')[0].innerHTML = @getYahooIcon(weather.condition.code, dayOrNight)
      $domEl.find('.icon').addClass('yahoo')
    else
      $domEl.find('.icon')[0].innerHTML = @getIcon(weather.condition.code)

renderForecast: (data, iconSet) ->
  date = new Date data.date
  if iconSet is 'yahoo'
    icon = @getYahooIcon(data.code, 'd')
  else
    icon = @getIcon(data.code)

  """
    <div class='entry cf'>
      <div class='day'>#{@dayMapping[date.getDay()]}</div>
      <div class='icon'>#{icon}</div>
      <div class='high'><label>High:</label>#{Math.round(data.high)}°</div>
      <div class='low'><label>Low:</label>#{Math.round(data.low)}°</div>
    </div>
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


