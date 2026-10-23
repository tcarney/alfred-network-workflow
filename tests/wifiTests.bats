#!/usr/bin/env bats

. src/helpers.sh
load variables

@test "getWifiState: get wifi state" {
  run getWifiState en0
  [ "$status" -eq 0 ]
  [ "$output" = 1 -o "$output" = 0 ]
}

@test "getWifiName: get name" {
  run getWifiName "$LIST"
  [ "$status" -eq 0 ]
  [ "$output" = "Wi-Fi" ]
}

@test "getWifiInterface: get interface" {
  run getWifiInterface "$LIST"
  [ "$status" -eq 0 ]
  [ "$output" = "en0" ]
}

@test "getWifiMac: get mac address" {
  run getWifiMac "$LIST"
  [ "$status" -eq 0 ]
  [ "$output" = "f8:06:c1:00:a3:cc" ]
}

@test "getConnectionConfig: get connection config" {
  run getConnectionConfig "$NETINFO"
  [ "$output" = "DHCP Configuration" ]
}

@test "getIPv4: get IPv4" {
  run getIPv4 "$NETINFO"
  [ "$output" = "192.168.1.100" ]
}

@test "getIPv6: get non-existing IPv6" {
  run getIPv6 "$NETINFO"
  [ "$output" = "" ]
}

@test "getSSID: get SSID" {
  run getSSID "$INFO"
  [ "$output" = "Test Network" ]
}

@test "getBSSID: get BSSID" {
  run getBSSID "$INFO"
  [ "$output" = "c8:07:19:2c:00:6f" ]
}

@test "getBSSID: redacted BSSID" {
  run getBSSID "  BSSID : <redacted>"
  [ "$output" = "" ]
}

@test "getBSSID: zero pads BSSID" {
  run getBSSID "  BSSID : c8:7:19:2c:0:6f"
  [ "$output" = "c8:07:19:2c:00:6f" ]
}

@test "getSSID: ignore missing SSID" {
  run getSSID "  InterfaceType : WiFi"
  [ "$output" = "" ]
}

@test "getAuth: get auth" {
  run getAuth "$INFO"
  [ "$output" = "WPA2_PSK" ]
}

@test "getGlobalIP: get global IP" {
  run getGlobalIP
  [[ "$output" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
}

@test "getGlobalIP: handle invalid resolver" {
  run getGlobalIP "non-existing"
  [[ "$output" = "" ]]
}

@test "getVPN: get connected VPN" {
  run getVPN "$SCUTIL"
  [ "$output" = "Test-VPN" ]
}

@test "getVPN: get connected VPN with other service type" {
  INPUT='* (Connected)      DD1CCB2D-1578-45F1-9C63-6703A825D832 VPN (io.tailscale.ipn.macsys) "Tailscale"                      [VPN:io.tailscale.ipn.macsys]'
  run getVPN "$INPUT"
  [ "$output" = "Tailscale" ]
}

@test "getVPN: get connected VPN with spaces in name" {
  INPUT='* (Connected)      65F5A799-4C98-4DA1-87D7-9D605D9D666C IPSec (com.vpn.vpn)              "Another VPN"                            [IPSec]'
  run getVPN "$INPUT"
  [ "$output" = "Another VPN" ]
}

@test "getVPN: ignore disconnected VPN" {
  INPUT='* (Disconnected)   65F5A799-4C98-4DA1-87D7-9D605D9D666C IPSec (com.vpn.vpn)              "Another VPN"                            [IPSec]'
  run getVPN "$INPUT"
  [ "$output" = "" ]
}
