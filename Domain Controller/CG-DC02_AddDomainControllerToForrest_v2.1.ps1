#Install the Windows Active Directory Domain Services role
install-windowsfeature AD-Domain-Services -IncludeManagementTools

#Import the ADDSDepoyment module
Import-Module ADDSDeployment

#Add Domain Controller to the domain
#SafeModeAdministratorPassword = P@ssword!
Install-ADDSDomainController `
 -InstallDns `
 -Credential (Get-Credential Core-Group\administrator) `
 -DomainName Core-Group