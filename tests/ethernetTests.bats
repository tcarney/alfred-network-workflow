#!/usr/bin/env bats

. src/helpers.sh
load variables

@test "getEthernetState: get ethernet state" {
  run getEthernetState en4
  [ "$status" -eq 0 ]
  [ "$output" = 1 -o "$output" = 0 ]
}

@test "getEthernetName: get name" {
  run getEthernetName "$LIST"
  [ "$status" -eq 0 ]
  [ "$output" = "Thunderbolt Ethernet" ]
}

@test "getEthernetName: get ax name" {
  run getEthernetName "$LIST3"
  [ "$status" -eq 0 ]
  [ "$output" = "AX88179A" ]
}

@test "getEthernetInterface: get interface Thunderbolt" {
  run getEthernetInterface "$LIST"
  [ "$status" -eq 0 ]
  [ "$output" = "en4" ]
}

@test "getEthernetInterface: get interface USB" {
  run getEthernetInterface "$LIST2"
  [ "$status" -eq 0 ]
  [ "$output" = "en7" ]
}

@test "getEthernetMac: get mac address" {
  run getEthernetMac "$LIST"
  [ "$status" -eq 0 ]
  [ "$output" = "40:0c:8d:00:ef:8c" ]
}

@test "getServiceName: get renamed service" {
  run getServiceName en5 "$ORDER"
  [ "$output" = "Home Office Dock" ]
}

@test "getServiceName: get service" {
  run getServiceName en0 "$ORDER"
  [ "$output" = "Wi-Fi" ]
}

@test "getServiceName: get disabled service" {
  run getServiceName en10 "$ORDER"
  [ "$output" = "Old Adapter" ]
}

@test "getServiceName: match whole interface name" {
  run getServiceName en1 "$ORDER"
  [ "$output" = "" ]
}
