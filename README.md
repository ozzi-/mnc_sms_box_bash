# mnc_sms_box_bash
Send SMS in your bash using MNC SMS Box.
Fill out the configuration in the script
```
url="https://biz__INSTANCE__.smsbox.ch:8443/biz__INSTANCE__/sms/xml"
username="___YOUR_USERNAME___"
pw="___YOUR_PASSWORD___"
service="___YOUR_SERVICE___"
sender="ICINGA"
```

## Usage
```
Usage: send_sms [OPTIONS]
  [OPTIONS]:
  -M MESSAGE      The message you wish to send (Maximum of 140 characters)
  -N NUMBER       The recipients mobile number (Add "+countrycode")
                  You can pass multiple numbers by delimiting using a semicolon ";"

send_sms.sh -M "Test Message" -N "+41791234567;+41789876543"
```
