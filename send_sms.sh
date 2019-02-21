#!/bin/bash

# startup checks
if [ -z "$BASH" ]; then
  echo "Please use BASH."
  exit 3
fi
if [ ! -e "/usr/bin/which" ]; then
  echo "/usr/bin/which is missing."
  exit 3
fi
curl=$(which curl)
if [ $? -ne 0 ]; then
  echo "Please install curl."
  exit 3
fi

url="https://biz__INSTANCE__.smsbox.ch:8443/biz__INSTANCE__/sms/xml"
username="___YOUR_USERNAME___"
pw="___YOUR_PASSWORD___"
service="___YOUR_SERVICE___"
sender="ICINGA"

# Usage Info
usage() {
  echo '''Usage: send_sms [OPTIONS]
  [OPTIONS]:
  -M MESSAGE      The message you wish to send (Maximum of 140 characters)
  -N NUMBER       The recipients mobile number (Add "+countrycode")'''
}

#main
#get options
while getopts "M:N:" opt; do
  case $opt in
    M)
      message=$OPTARG
      ;;
    N)
      number=$OPTARG
      ;;
    *)
      usage
      exit 3
      ;;
  esac
done

request="<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
<SMSBoxXMLRequest>
  <username>"$username"</username>
  <password>"$pw"</password>
  <command>WEBSEND</command>
  <parameters>
    <receiver>"$number"</receiver>
    <service>"$service"</service>
    <text>"$message"</text>
    <guessOperator/>
  </parameters>
  <metadata>
    <forceSender>"$sender"</forceSender>
  </metadata>
</SMSBoxXMLRequest>"

if [ -z "$message" ]; then
  echo "Error: message is required"
  usage
  exit 3
fi
if [ -z "$number" ]; then
  echo "Error: number is required"
  usage
  exit 3
fi

response=$($curl -s --header "Content-Type: text/xml" --connect-timeout 5 --request POST --data "$request" $url)
status=$?
if [[ $response == *"receiver status=\"ok\""* ]]; then
  echo "SMS SENT"
  exit 0
elif [[ $status -eq 0 ]]; then
  echo "SMS SEND FAILURE (API Error)"
  echo "-- Response --"
  echo $response
else
  echo "SMS SEND FAILURE (curl exit code = $status)"
fi
