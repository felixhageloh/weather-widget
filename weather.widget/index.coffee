command: "python weather.widget/weather.py"

# Update every 10 minutes
refreshFrequency: 600000

render: (o) -> """
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
"""

update: (output, domEl) ->
  # Parse the JSON data
  data  = JSON.parse(output)

  # Set some local variables to make things a bit easier
  location = data.query.results.channel.location
  weather = data.query.results.channel.item
  date  = new Date weather.condition.date

  # Determine if it is day or night, so we can show the correct icon
  dayOrNight = @getDayOrNight data.query.results.channel

  # Cache the element
  $domEl = $(domEl)

  # Render the top icon and summary section
  $domEl.find('.region').text location.city + ', ' + location.region
  $domEl.find('.date').text @dayMapping[date.getDay()]
  $domEl.find('.temp').html """
    <span class='hi'>#{Math.round(weather.condition.temp)}°</span>
  """
  $domEl.find('.text').text weather.condition.text
  $domEl.find('.icon')[0].innerHTML = @getIcon(weather.condition.code, dayOrNight)

  # Render the forecast section
  forecastEl = $domEl.find('.forecast').html('')
  for day in weather.forecast[0..4]
    forecastEl.append @renderForecast(day)

renderForecast: (data) ->
  date = new Date data.date

  """
    <div class='entry cf'>
      <div class='day'>#{@dayMapping[date.getDay()]}</div>
      <div class='icon'>#{@getIcon(data.code, 'd')}</div>
      <div class='high'><label>High:</label>#{Math.round(data.high)}°</div>
      <div class='low'><label>Low:</label>#{Math.round(data.low)}°</div>
    </div>
  """

style: """
  top: 0px
  left: 10px
  color: #fff
  font-family: Helvetica Neue

  .cf:before, .cf:after
    content: " "
    display: table

  .cf:after
    clear: both;

  img
    max-width: 100%

  .today
    .icon
      float: left
      margin-bottom: -70px
      margin-right: -70px
      margin-top: 0px
    .region
      font-weight: 400
      font-size: 32px
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
    margin-top 20px
    padding-top 20px
    border-top 1px solid #fff
    font-size: 0
    width: 360px

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

dayMapping:
  0: 'Sunday'
  1: 'Monday'
  2: 'Tuesday'
  3: 'Wednesday'
  4: 'Thursday'
  5: 'Friday'
  6: 'Saturday'

getDayOrNight: (data) ->
  # Get the current time, so we can figure out if it's day or night
  now = new Date()
  today = (now.getMonth() + 1) + "/" + now.getDate() + "/" + now.getFullYear()

  # Determine the sunrise time
  sunrise = data.astronomy.sunrise

  pos = sunrise.indexOf ':', 0

  hours = sunrise.charAt pos-1
  if (pos > 1) then hours = sunrise[0..1]

  len = sunrise.length
  AMPM = sunrise[len-2..len]

  if (AMPM == 'pm') then hours = hours + 12

  sHours = String(hours)

  if (hours < 10) then sHours = '0' + sHours

  minutes = sunrise[pos+1..pos+2]
  sMinutes = String(minutes)
  temp = today + ' ' + sHours + ':' + sMinutes

  # This is the time the sun came up
  start = new Date(temp)

  # Determine the sun set time
  sunset = data.astronomy.sunset

  pos = sunset.indexOf ':',0
  hours = sunset.charAt pos-1

  if (pos > 1) then hours = sunset[0..1]
  len = sunrise.length
  AMPM = sunset[len-2..len]

  if (AMPM == 'pm') then hours = Number(hours) + 12

  sHours = String(hours)

  if (hours < 10) then sHours = '0' + sHours

  minutes = sunset[pos+1..pos+2]
  sMinutes = String(minutes)
  temp = today + ' ' + sHours + ':' + sMinutes

  # This is the time the sun came up
  end = new Date(temp)

  # Return either 'd' if the sun is still up, or 'n' if it is gone
  if now > start and now < end then 'd' else 'n'

getIcon: (code, dayOrNight) ->
  # Returns the image element from Yahoo with the proper image
  imageURL = "http://l.yimg.com/a/i/us/nws/weather/gr/#{code}#{dayOrNight}.png"
  '<img src="' + imageURL + '">'
