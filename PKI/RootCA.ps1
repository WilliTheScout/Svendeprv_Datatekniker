# --- PRE-INSTALLATION --- #
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
Add-WindowsFeature –Name Adcs-Cert-Authority -IncludeManagementTools

#Configueres the AD CS Feature, as a standalone Root CA
Install-AdcsCertificationAuthority -CAType StandaloneRootCA –CACommonName 'CG-RootCA01' -KeyLength 4096 -HashAlgorithm SHA256 -CryptoProviderName 'RSA#Microsoft Software Key Storage Provider' -ValidityPeriod Years -ValidityPeriodUnits 12 -Force


# --- POST-INSTALLATION --- #
#Define Active Directory Configuration Partition DN
Certutil -setreg CA\DSConfigDN “CN=Configuration,DC=ad,DC=core-group,DC=dk”

#Define CRL Period Units and CRL Period
Certutil -setreg CA\CRLPeriodUnits 26 
Certutil -setreg CA\CRLPeriod “Weeks”

#Define CRL Overlap Units and CRL Overlap Period
Certutil -setreg CA\CRLOverlapUnits 1
Certutil -setreg CA\CRLOverlapPeriod “Weeks”

#Define Validity Period Units and Validity Period
Certutil -setreg CA\ValidityPeriodUnits 6
Certutil -setreg CA\ValidityPeriod “Years”

#Allow CA Auditing
Certutil -setreg CA\AuditFilter 127
Write-Host "Audit: Remeber to change the localc security policy to audit CA events"

#AIA configuration:
Get-CAAuthorityInformationAccess | Remove-CAAuthorityInformationAccess -Force
Add-CAAuthorityInformationAccess 'http://pki.core-group.dk/CertData/%3%4.crt' -AddToCertificateAia -Force
Add-CAAuthorityInformationAccess 'ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11' -AddToCertificateAia -Force
Restart-Service –Name CertSvc

#CDP configuration: 
Get-CACrlDistributionPoint | Remove-CACrlDistributionPoint -Force
Add-CACRLDistributionPoint 'C:\Windows\System32\CertSrv\CertEnroll\%3%8%9.crl' -PublishToServer -Force
Add-CACRLDistributionPoint 'http://pki.core-group.dk/CertData/%3%8%9.crl' -AddToCertificateCdp -Force
Add-CACRLDistributionPoint 'ldap:///CN=%7%8,CN=CDP,CN=Public Key Services,CN=Services,%6%10' -AddToCrlCdp -AddToCertificateCdp –Force 
Restart-Service –Name CertSvc

#Restart the Certificate Authority Service 
Restart-Service –Name CertSvc

#Wait 20 sec for service to start
Sleep 20

#Publish CRL
Certutil -CRL

Write-Host "POST-INSTALLATION Complete" 