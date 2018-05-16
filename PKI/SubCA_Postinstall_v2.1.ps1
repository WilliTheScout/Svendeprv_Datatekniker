# --- POST-INSTALLATION --- #
Start-Service -Name Certsrv

#Define CRL Period Unint and CRL Period
Certutil -setreg CA\CRLPeriodUnits 1
Certutil -setreg CA\CRLPeriod “Weeks”
Certutil -setreg CA\CRLDeltaPeriodUnits 1
Certutil -setreg CA\CRLDeltaPeriod “Days”

#Define CEL Overlap Period Units and CRL Overlap Period
Certutil -setreg CA\CRLOverlapUnits 1
Certutil -setreg CA\CRLOverlapPeriod “Weeks”
Certutil -setreg CA\CRLDeltaOverlapUnits 1
Certutil -setreg CA\CRLDeltaOverlapPeriod “Weeks”

#Define the CA Validity Period
Certutil -setreg CA\ValidityPeriodUnits 3 
Certutil -setreg CA\ValidityPeriod “Years”

#Allow CA Auditing
Certutil -setreg CA\AuditFilter 127
Write-Host "Audit: Remeber to change the localc security policy to audit CA events"

#AIA Configuration
Get-CAAuthorityInformationAccess | Remove-CAAuthorityInformationAccess -Force
Add-CAAuthorityInformationAccess http://pki.core-group.dk/CertData/%3%4.crt -AddToCertificateAia -Force
Add-CAAuthorityInformationAccess 'ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11' -AddToCertificateAia –Force
Restart-Service CertSvc

#CDP Configuration
Get-CACrlDistributionPoint | Remove-CACrlDistributionPoint -Force
Add-CACRLDistributionPoint C:\Windows\System32\CertSrv\CertEnroll\%3%8%9.crl -PublishToServer -PublishDeltaToServer -Force
Add-CACRLDistributionPoint http://pki.core-group.dk/CertData/%3%8%9.crl -AddToFreshestCrl -AddToCertificateCdp -Force
Add-CACRLDistributionPoint 'ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10' -PublishToServer -AddToCrlCdp -AddToFreshestCrl -AddToCertificateCdp -PublishDeltaToServer -Force
Add-CACRLDistributionPoint 'file://\\CG-WEB01.core-group.dk\CertData\%3%8%9.crl' -PublishToServer -PublishDeltaToServer –Force

#Restart the Certificate Authority Service 
Restart-Service –Name CertSvc

#Wait 20 sec for service to start
Sleep 20

#Publish CRL
Certutil -CRL 

#Publish the SubCA Certificate to http://pki.coregroup.company/CertData
Rename-Item -Path C:\Windows\System32\CertSrv\CertEnroll\CG-SubCA01.core-group.dk_core-groupSubCA01.crt –NewName Core-groupSubCA01.crt
Copy-Item -Path C:\Windows\System32\CertSrv\CertEnroll\core-groupSubCA01.crt –Destination \\CG-WEB01.core-group.dk\C$\inetpub\pki.core-group.dk\CertData

Write-Host "POST-INSTALLATION Complete"
Write-Host "Please Validate intial PKI Health"
Write-Host "To Validate PKI Health run PKIView.msc on the SubCA"
Write-Host "After validating the PKI Health, install the WEB Enrollment Proxy for SubCA" 