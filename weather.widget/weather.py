# Import required libraries
import urllib2
import json

# Uncomment the next 2 lines and replace <city>, <region_code> (state) for static weather
# city = "<city>"
# region_code = "<region>"

# Comment the next 4 lines for static weather
location = json.loads(urllib2.urlopen("http://freegeoip.net/json/").read())
city = location['city']
region = location['region_code']

# Setup the yql
yql = "select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text='"+city+",%20"+region+"')"

url = "https://query.yahooapis.com/v1/public/yql?q=%s&format=json"

weather = urllib2.urlopen(url % (yql)).read()
weather_data = json.loads(weather)
print json.dumps(weather_data, indent=4, sort_keys=True)
