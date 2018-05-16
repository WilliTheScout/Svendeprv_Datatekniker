#Install the Windows Active Directory Domain Services role
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

#Import the ADDSDepoyment module
Import-Module ADDSDeployment

#Install and configure the Forest
#Note: DomainMode 7 = Windows Server 2016
#Note: ForrestMode 7 = Windows Server 2016
Install-ADDSForest -CreateDnsDelegation:$false `
-DatabasePath “C:\Windows\NTDS” `
-DomainMode "7” `
-DomainName “Core-Group.dk” `
-DomainNetbiosName “Core-Group” `
-ForestMode “7” `
-InstallDns:$true `
-LogPath “C:\Windows\NTDS” `
-NoRebootOnCompletion:$false `
-SysvolPath “C:\Windows\SYSVOL” `
-Force:$true 
