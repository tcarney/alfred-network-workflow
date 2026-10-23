#!/bin/bash

LIST="
Hardware Port: Thunderbolt Ethernet
Device: en4
Ethernet Address: 40:0c:8d:00:ef:8c

Hardware Port: Wi-Fi
Device: en0
Ethernet Address: f8:06:c1:00:a3:cc

Hardware Port: Bluetooth PAN
Device: en3
Ethernet Address: b7:06:b1:01:a2:ce

Hardware Port: Thunderbolt 1
Device: en1
Ethernet Address: f2:00:11:48:00:20

Hardware Port: Thunderbolt 2
Device: en2
Ethernet Address: f2:00:12:48:50:22

Hardware Port: Thunderbolt Bridge
Device: bridge0
Ethernet Address: cc:f6:b1:77:f7:02

VLAN Configurations
==================="

LIST2="
Hardware Port: USB 10/100/1000 LAN
Device: en7
Ethernet Address: de:ad:be:ef:fe:ed

Hardware Port: Wi-Fi
Device: en0
Ethernet Address: f8:06:c1:00:a3:cc

VLAN Configurations
==================="

LIST3="
Hardware Port: Wi-Fi
Device: en1
Ethernet Address: f8:06:c1:00:a3:cc

Hardware Port: AX88179A
Device: en3
Ethernet Address: de:ad:be:ef:fe:ed

Hardware Port: Ethernet Adapter (en4)
Device: en4
Ethernet Address: de:ad:be:ef:fe:ee

VLAN Configurations
==================="

NETINFO='DHCP Configuration
IP address: 192.168.1.100
Subnet mask: 255.255.255.0
Router: 192.168.1.1
Client ID:
IPv6: Automatic
IPv6 IP address: none
IPv6 Router: none
Wi-Fi ID: f8:06:c1:00:a3:cc'

INFO='<dictionary> {
  BSSID : c8:7:19:2c:0:6f
  ConnectionID : 2
  InterfaceType : WiFi
  LinkStatusActive : TRUE
  SSID : Test Network
  Security : WPA2_PSK
}'

DNS="8.8.8.8
8.8.4.4
192.168.1.1"

ORDER='An asterisk (*) denotes that a network service is disabled.
(1) Home Office Dock
(Hardware Port: USB 10/100/1000 LAN, Device: en5)

(2) Thunderbolt Bridge
(Hardware Port: Thunderbolt Bridge, Device: bridge0)

(3) Wi-Fi
(Hardware Port: Wi-Fi, Device: en0)

(*) Old Adapter
(Hardware Port: USB LAN, Device: en10)

(4) Tailscale
(Hardware Port: io.tailscale.ipn.macsys, Device: )'
