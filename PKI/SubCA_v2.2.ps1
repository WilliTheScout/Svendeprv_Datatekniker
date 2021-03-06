﻿Write-Host "Requred: Copy the RootCA Certificate from the RootCA to the SubCA"
Write-Host "Requred: Move the RootCA Certificate to this folder C:\Temp" 
$ReadHost = Read-Host "Continue whit installation? (Y/N) N is default"

Switch ($ReadHost)
{
    Default {Write-Host "Stopping installtion"
    Break Script} #Stopping Script
    Y {}          #Continues/Starts the script
}

if (!"Get-ChildItem C:\Temp\Core-groupRootCA01.crt") {
    Write-Host "Error! File C:\Temp\Core-groupRootCA01.crt is missing"
    Break Script
}


# --- PRE-INSTALLATION --- #

#Publish the RootCA Certificate and CRL to AD and HTTP
$RootCA_CRT = Get-ChildItem "C:\Temp\Core-groupRootCA01.crt"
if (!$RootCA_CRL) {"certutil -f -dspublish C:\Temp\Core-groupRootCA01.crt RootCA"}
else {Write-Host "Error! Missing C:\Temp\Core-groupRootCA01.crt stopping script!", Brak script}

$RootCA_CRL = Get-ChildItem "C:\Temp\Core-groupRootCA01.crl"
if (!$RootCA_CRL) {"certutil -f -dspublish C:\Temp\Core-groupRootCA01.crl"}
else {Write-Host "Error! Missing C:\Temp\Core-groupRootCA01.crl stopping script!", Brak script}

#Copy RootCA Certificate and CRL to Webserver 
$WebServer = "\\CG-WEB01.core-group.dk\C$\inetpub\pki.core-group.dk\CertData"
Copy-Item -Path C:\Temp\Coregroup-RootCA01.cr? -Destination $WebServer

#Add the RootCA Certificate to the local certificate store on SubCA
gpupdate /force

#Create the CAPolicy.inf file
$CAPolicy = "C:\Windows\CApolicy.inf"
New-Item -Path $CAPolicy

#Add data to the CAPolicy.file
Add-Content -Path $CAPolicy -Value '[Version]'
Add-Content -Path $CAPolicy -Value 'Signature= "$Windows NT$'
Add-Content -Path $CAPolicy -Value ""
Add-Content -Path $CAPolicy -Value '[PolicyStatementExtension]'
Add-Content -Path $CAPolicy -Value 'Policies = LegalPolicy'
Add-Content -Path $CAPolicy -Value 'Critical = 0'
Add-Content -Path $CAPolicy -Value ""
Add-Content -Path $CAPolicy -Value '[LegalPolicy]'
Add-Content -Path $CAPolicy -Value 'OID=1.3.6.1.4.1.11.21.43'
Add-Content -Path $CAPolicy -Value 'Notice = "Legal policy statement text."'
Add-Content -Path $CAPolicy -Value 'URL = "http://pki.core-group.dk/certdata/cps.asp"'
Add-Content -Path $CAPolicy -Value ""
Add-Content -Path $CAPolicy -Value '[Certsrv_Server]'
Add-Content -Path $CAPolicy -Value 'RenewalKeyLength=4096'
Add-Content -Path $CAPolicy -Value 'RenewalValidityPeriod=Years'
Add-Content -Path $CAPolicy -Value 'RenewalValidityPeriodUnits=12'

Get-Content -Path $CAPolicy

# --- INSTALLATION --- #
#Installs the Active Directory Certificate Authority Feature, whit managment tools
Add-WindowsFeature –Name Adcs-Cert-Authority –IncludeManagementTools

#Configueres the AD CS Feature, as an Enterprice SubCA
Install-AdcsCertificationAuthority -CAType EnterpriseSubordinateCA -CACommonName 'CG-SubCA01' -KeyLength 4096 -HashAlgorithm SHA256 -CryptoProviderName 'RSA#Microsoft Software Key Storage Provider' –DatabaseDirecitory C:\CertData –LogDirectory C:\CertData

Write-Host "INSTALLATION Complete!"
Write-Host ""
Write-Host "To complete the installation, Submit and Issu SubCA Certificate Request on RootCA"
Write-Host "After issuing and installing the certificate, run the scrip SubCA_postinstall.ps1"