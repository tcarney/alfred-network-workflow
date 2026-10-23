#!/bin/bash

. src/workflowHandler.sh
. src/media.sh

ETHERNET_REGEX="LAN$|Lan$|Ethernet$|AX[0-9A-Z]+$"
WIFI_REGEX="Airport$|Wi-Fi$"

# Trim string
# $1 = Input string
# $! = Trimmed string
trim () {
  str="$1"
  match=" "
  while [ "${str:0:${#match}}" == "$match" ]; do
    str="${str:${#match}:${#str}}"
  done
  while [ "${str:$((${#str}-${#match}))}" == "$match" ]; do
    str="${str:0:$((${#str} - ${#match}))}"
  done
  echo "$str"
}

# Get wifi state as boolean
# $1 = Wi-Fi interface name
# $! = Boolean
getWifiState() {
  if [ "$(networksetup -getairportpower "$1" | grep On)" != "" ]; then
    echo 1
  else
    echo 0
  fi
}

# Get ethernet state as boolean
# $1 = Ethernet interface name
# $! = Boolean
getEthernetState() {
  if [ "$1" != "" ]; then
    echo 1
  else
    echo 0
  fi
}

# Get wifi port name
# $1 = networksetup -listallhardwareports
# $! = String
getWifiName() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "$WIFI_REGEX")
  echo "$DETAILS" | grep -Eo "AirPort|Wi-Fi"
}

# Get ethernet port name
# $1 = networksetup -listallhardwareports
# $! = String
getEthernetName() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "$ETHERNET_REGEX")
  echo "$DETAILS" | awk '/Hardware / {print substr($0, index($0, $3))}'
}

# Get wifi interface name
# $1 = networksetup -listallhardwareports
# $! = String
getWifiInterface() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "$WIFI_REGEX")
  echo "$DETAILS" | grep -m 1 -o -e en[0-9]
}

# Get ethernet interface name
# $1 = networksetup -listallhardwareports
# $! = String
getEthernetInterface() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "$ETHERNET_REGEX")
  echo "$DETAILS" | grep -m 1 -o -e en[0-9]
}

# Get wifi mac address
# $1 = networksetup -listallhardwareports
# $! = String
getWifiMac() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "$WIFI_REGEX")
  echo "$DETAILS" | awk '/Ethernet Address: / {print substr($0, index($0, $3))}'
}

# Get ethernet mac address
# $1 = networksetup -listallhardwareports
# $! = String
getEthernetMac() {
  local LIST=${1-$(networksetup -listallhardwareports)}
  local DETAILS=$(echo "$LIST" | grep -A 2 -E "$ETHERNET_REGEX")
  echo "$DETAILS" | awk '/Ethernet Address: / {print substr($0, index($0, $3))}'
}

# Find name of primary connected network interface
# $! = String
getPrimaryInterfaceName() {
  local INTERFACE=$(getEthernetInterface)
  if [ $(getEthernetState "$INTERFACE") != 0 ]; then
    echo "$(getEthernetName)"
  else
    echo "$(getWifiName)"
  fi
}

# Extract connection configuration
# $1 = networksetup -getinfo
# $! = String
getConnectionConfig() {
  echo "$1" | grep 'Configuration$'
}

# Extract IP4
# $1 = networksetup -getinfo
# $! = String
getIPv4() {
  echo "$1" | grep '^IP\saddress' \
    | awk '/ address/ {print substr($0, index($0, $3))}'
}

# Extract IP6
# $1 = networksetup -getinfo
# $! = String
getIPv6() {
  local IPv6=$(echo "$1" \
    | grep '^IPv6 IP address' \
    | awk '/ address/ {print substr($0, index($0, $4))}')

  if [ "$IPv6" == "none" ]; then
    echo ""
  else
    echo "$IPv6"
  fi
}

# Extract SSID
# $1 = ipconfig getsummary <interface>
# $! = String
getSSID() {
  echo "$1" | awk '/^ *SSID : / {print substr($0, index($0, " : ") + 3)}'
}

# Pad BSSID
# $1 = BSSID string
# $! = String
padBSSID() {
  if [ ${#1} == 17 ]; then
    echo "$1"
  else
    for PART in $(echo "$1" | tr ":" "\n"); do
      if [ "$skipFirst" != "" ]; then
        printf ":"
      fi
      skipFirst=true
      printf "%02s" "$PART"
    done
  fi
}

# Get BSSID
# $1 = ipconfig getsummary <interface>
# $! = String
getBSSID() {
  local BSSID=$(echo "$1" | awk '/^ *BSSID : / {print substr($0, index($0, " : ") + 3)}' | xargs)
  # Handle missing or redacted BSSID
  if [ "$BSSID" == "" ] || [ "$BSSID" == "<redacted>" ]; then
    echo ""
  else
    echo $(padBSSID "$BSSID")
  fi
}

# Extract wifi security type
# $1 = ipconfig getsummary <interface>
# $! = String
getAuth() {
  echo "$1" | awk '/^ *Security : / {print substr($0, index($0, " : ") + 3)}'
}

# Get external IP from an HTTP service
# $1 = IP version (4 or 6)
# $2 = Service URL (optional, defaults to $service or icanhazip)
# $! = String
getExternalIP() {
  local URL=${2:-${service:-"https://icanhazip.com"}}

  local IP=$(curl -"$1" -s -m 5 "$URL" | tr -d '[:space:]')
  if [ "$1" == 4 ] && [[ "$IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "$IP"
  elif [ "$1" == 6 ] && [[ "$IP" =~ ^[0-9a-fA-F:]+$ ]] && [[ "$IP" == *:* ]]; then
    echo "$IP"
  fi
}

# Get connected VPN
# $1 = scutil --nc list
# $! = String
getVPN() {
  echo "$1" | awk -F'"' '/\(Connected\)/ {print $2}'
}

# Get VPN info
# $1 = `scutil --nc list` lines
# $! = Separated string of VPN info
getVPNInfo() {
  if [[ "$1" =~ \*[[:space:]]\(([a-zA-Z ]*)\)[[:space:]].*\"(.*)\".*\[(.*)\] ]]
  then
    STATE=${BASH_REMATCH[1]}
    NAME=${BASH_REMATCH[2]}
    TYPE=${BASH_REMATCH[3]}
  fi

  echo "$STATE"~"$NAME"~"$TYPE"~"$ICON_VPN"
}

# Get DNS info
# $1 = `networksetup -getdnsservers <servicename>`
# $! = String
getDNS() {
  if [[ "$1" != *"any DNS"* ]]; then
    echo $1 | sed 's/ / \/ /g'
  else
    echo ""
  fi
}

# Parse DNS info
# $1 = line of dns config file
# $2 = active dns list
# $! = Separated string of dns config elements
parseDNSLine() {
  IFS=':' read -r -a ARRAY <<< "$1"
  if [[ "${ARRAY[0]}" =~ ^# ]] || [ "${ARRAY[0]}" == "" ] || [ "${ARRAY[1]}" == "" ]; then
    return
  fi

  local ID=$(trim "${ARRAY[0]}")
  local DNS=$(echo "${ARRAY[1]}" | sed 's/ //g' | sed 's/,/ \/ /g')
  local ICON=$ICON_DNS

  if [ "$DNS" == "$2" ]; then
    ID="$ID (used)"
  fi

  echo "$ID"~"$DNS"~"$ICON"
}
