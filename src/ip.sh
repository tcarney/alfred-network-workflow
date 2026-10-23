#!/bin/bash

. src/helpers.sh

# Handle action
if [ "$1" != "" ]; then
  echo "$1" | tr -d '\n'
  exit
fi

IPv4=$(getExternalIP 4)
if [ "$IPv4" != "" ]; then
  addResult "" "$IPv4" "$IPv4" "External IPv4 address" "$ICON_IP"
fi

IPv6=$(getExternalIP 6)
if [ "$IPv6" != "" ]; then
  addResult "" "$IPv6" "$IPv6" "External IPv6 address" "$ICON_IP"
fi

if [ "$IPv4" == "" ] && [ "$IPv6" == "" ]; then
  addResult "" "" "No external IP" "Could not reach ${service:-https://icanhazip.com}" "$ICON_IP"
fi

getXMLResults
