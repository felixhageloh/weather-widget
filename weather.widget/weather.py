# Import required libraries
import urllib2
import json

# Set these and replace <city>, <region_code> (state) in case we cannot get the location
city = "Cupertino"
region_code = "CA"

# -----------------------------------
# Dynamic Section
# -----------------------------------

# Try to get the location
try:

    location = json.loads(urllib2.urlopen("http://freegeoip.net/json/").read())
    city = location['city']
    region = location['region_code']

except:
    pass

# -----------------------------------
# /Dynamic Section
# -----------------------------------

try:

    # Setup the yql
    yql = "select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text='"+city+",%20"+region+"')"
    url = "https://query.yahooapis.com/v1/public/yql?q=%s&format=json"

    # Pretty print json (for developing)
    # print json.dumps(json.loads(urllib2.urlopen(url % (yql)).read()), indent=4, sort_keys=True)

    print urllib2.urlopen(url % (yql)).read()

except urllib2.HTTPError, err:
    print "{ \"query\": \"ERROR\", \"message\": \"" + err.reason + "\" }"
except urllib2.URLError, err:
    print "{ \"query\": \"ERROR\", \"message\": \"" + err.reason + "\" }"
