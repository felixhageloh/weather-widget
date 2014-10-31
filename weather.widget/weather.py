# Import required libraries
import urllib2
# import requests
import json

# Set these and replace <city>, <region_code> (state) in case we cannot get the location
city = "Cupertino"
region = "CA"

# -----------------------------------
# Dynamic Section
# -----------------------------------

# Try to get the location
try:

    url = "http://freegeoip.net/json/"
    location = json.loads(urllib2.urlopen(url).read())
    # location = json.loads(requests.get(url).text)
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

    print urllib2.urlopen(url % (yql)).read()
    # print requests.get(url % (yql)).text

except urllib2.HTTPError, err:
    print "{ \"query\": \"ERROR\", \"message\": \"" + err.reason + "\" }"
except urllib2.URLError, err:
    print "{ \"query\": \"ERROR\", \"message\": \"" + err.reason + "\" }"
# except requests.exceptions.RequestException, err:
#     print "{ \"query\": \"ERROR\", \"message\": \"" + str(err.message[0]) + " " + str(err.message[1]) + "\" }"
except Exception as err:
    print "{ \"query\": \"ERROR\", \"message\": \"There was an error performing the request.\" }"
