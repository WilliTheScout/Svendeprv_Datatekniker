#-- INSTALL AND CONFIGURE THE DHCP ROLE --#
#Install the Windows DHCP Server Role
Add-WindowsFeature dhcp -IncludeManagementTools

#Create DHCP scurity groups
netsh dhcp add securitygroups

#Restart the DHCP service
Restart-Service dhcpserver

#Authorizing the DHCP server in Active Directory 
$IP = Get-NetIPAddress -InterfaceAlias 'Ethernet0' -AddressFamily IPv4 | select IPAddress #Gets IP address fom NIC
Add-DhcpServerInDC  $env:COMPUTERNAME $IP.IPAddress


#-- ADD DHCP SCOPES --#
#- 10.10.0.0 /24 --- Create DCHP Scope for 10.10.0.0 /24 CLIENT - VLAN 10
Add-DhcpServerv4Scope `
-Name 'CLIENT-10' `
-StartRange 10.10.0.20 `
-EndRange 10.10.0.254 `
-SubnetMask 255.255.255.0 `
-LeaseDuration 00:08:00:00  `
-Description 'DHCP scope for Clients - VLAN 10' `
-ComputerName CG-DC01

#Add the DNS Domin, DNS Server, and Default gateway to the DHCP Scope
Set-DhcpServerv4OptionValue `
-DnsDomain Core-Group.dk `
-DnsServer 10.20.0.11,10.20.0.12 `
-Router 10.10.0.1  `
-ScopeId 10.10.0.0 `
-ComputerName CG-DC01 

#- 10.20.0.0 /24 --- Create DCHP Scope for 10.20.0.0 /24 SERVER - VLAN 20
Add-DhcpServerv4Scope -Name SERVER-20 -StartRange 10.20.0.150 -EndRange 10.20.0.250 -SubnetMask 255.255.255.0 -LeaseDuration 00:08:00:00 -Description 'DHCP scope for temp IP address in Server - VLAN 20' -ComputerName CG-DC01
#Add the DNS Domin, DNS Server, and Default gateway to the DHCP Scope
Set-DhcpServerv4OptionValue -DnsDomain Core-Group.dk -DnsServer 10.20.0.11,10.20.0.12 -Router 10.20.0.1 -ComputerName CG-DC01 -ScopeId 10.20.0.0

#- 10.30.0.0 /24 --- Create DCHP Scope for 10.30.0.0 /24 ADMIN - VLAN 30
Add-DhcpServerv4Scope -Name 'ADMIN-30' -StartRange 10.30.0.20 -EndRange 10.30.0.254 -SubnetMask 255.255.255.0 -LeaseDuration 00:08:00:00  -Description 'DHCP scope for Admin - VLAN 30' -ComputerName CG-DC01
#Add the DNS Domin, DNS Server, and Default gateway to the DHCP Scope
Set-DhcpServerv4OptionValue -DnsDomain Core-Group.dk -DnsServer 10.20.0.11,10.20.0.12 -Router 10.30.0.1 -ComputerName CG-DC01 -ScopeId 10.30.0.0

#- 10.40.0.0 /24 --- Create DCHP Scope for 10.40.0.0 /24 MANAGEMENT - VLAN 40
Add-DhcpServerv4Scope -Name MGMT-40 -StartRange 10.40.0.150 -EndRange 10.40.0.250 -SubnetMask 255.255.255.0 -LeaseDuration 00:08:00:00 -Description 'DHCP scope for Management - VLAN 40' -ComputerName CG-DC01
#Add the DNS Domin, DNS Server, and Default gateway to the DHCP Scope
Set-DhcpServerv4OptionValue -DnsDomain Core-Group.dk -DnsServer 10.20.0.11,10.20.0.12 -Router 10.40.0.1 -ComputerName CG-DC01 -ScopeId 10.40.0.0

#- 172.16.0.0 --- Create DCHP Scope for 172.16.0.0 /24 WIFI - VLAN 60
Add-DhcpServerv4Scope -Name 'WIFI-60' -StartRange 172.16.0.20 -EndRange 172.16.0.254 -SubnetMask 255.255.255.0 -LeaseDuration 00:08:00:00 -Description 'DCHP scope for WiFi - VLAN 60' -ComputerName CG-DC01
#Add the DNS Domin, DNS Server, and Default gateway to the DHCP Scope
Set-DhcpServerv4OptionValue -DnsDomain Core-Group.dk -DnsServer 10.20.0.11,10.20.0.12 -Router 172.16.0.1 -ComputerName CG-DC01 -ScopeId 172.16.0.0