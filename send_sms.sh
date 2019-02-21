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
sender="__YOUR_SENDER_NAME___"

# Usage Info
usage() {
  echo '''Usage: send_sms [OPTIONS]
  [OPTIONS]:
  -M MESSAGE      The message you wish to send (Maximum of 140 characters)
  -N NUMBER       The recipients mobile number (Add "+countrycode")
                  You can pass multiple numbers by delimiting using a semicolon ";"'''
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

IFS=";"
read -a recipients <<< "${number}"
unset IFS

for recipient in "${recipients[@]}"; do
  request="<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
  <SMSBoxXMLRequest>
    <username>"$username"</username>
    <password>"$pw"</password>
    <command>WEBSEND</command>
    <parameters>
      <receiver>"$recipient"</receiver>
      <service>"$service"</service>
      <text>"$message"</text>
      <guessOperator/>
    </parameters>
    <metadata>
      <forceSender>"$service"</forceSender>
    </metadata>
  </SMSBoxXMLRequest>"

  response=$($curl -s --header "Content-Type: text/xml" --connect-timeout 5 --request POST --data "$request" $url)
  status=$?

  if [[ $response == *"receiver status=\"ok\""* ]]; then
    echo "SMS SENT TO "$recipient
  elif [[ $status -eq 0 ]]; then
    echo "SMS SEND FAILURE (API Error)"
    echo "-- Response --"
    echo $response
    exit 1
  else
    echo "SMS SEND FAILURE (curl exit code = $status)"
    exit 2
  fi
done
exit 0
