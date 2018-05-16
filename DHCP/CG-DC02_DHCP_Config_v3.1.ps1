#-- INSTALL AND CONFIGURE THE DHCP ROLE --#
#Install the Windows DHCP Server Role
Add-WindowsFeature dhcp -IncludeManagementTools

#Create DHCP scurity groups
netsh dhcp add securitygroups

#Restart the DHCP service
Restart-Service dhcpserver

#Authorizing the DHCP server in Active Directory 
$IP = Get-NetIPAddress -InterfaceAlias 'Ethernet0' -AddressFamily IPv4 | select IPAddress
Add-DhcpServerInDC  $env:COMPUTERNAME $IP.IPAddress


#-- CONFIGURE DCHP FAILOVER --#
#Configures DCHP Failover between CG-DC01 and CG-DC02 on the following scopes: 10.10.0.0,10.20.0.0,10.30.0.0,10.40.0.0,172.16.0.0
Add-DhcpServerv4Failover `
-ComputerName CG-DC01 `
-PartnerServer CG-DC02 `
-Name DCHP_Cluster `
-LoadBalancePercent 50 `
-SharedSecret DHCP_Pass `
-ScopeId 10.10.0.0,10.20.0.0,10.30.0.0,10.40.0.0,172.16.0.0

#Gets DCHP Failover stats
Get-DhcpServerv4Failover