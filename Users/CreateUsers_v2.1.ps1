$Users = Import-Csv -Path "C:\Temp\Userlist.csv"            
foreach ($User in $Users)            
{            
    $OU = switch ($User.Afdeling)
     {
        Administration {'OU=Administration,OU=Users,OU=Core-Group,DC=core-group,DC=dk'}
        HR {'OU=HR,OU=Users,OU=Core-Group,DC=core-group,DCdk'}
        IT {'OU=IT,OU=Users,OU=Core-Group,DC=core-group,DC=dk'}
        Ledelse {'OU=Ledelse,OU=Users,OU=Core-Group,DC=core-group,DC=dk'}
        Revision {'OU=Revision,OU=Users,OU=Core-Group,DC=core-group,DC=dk'}
     }
    
    $Displayname = $User.Firstname + " " + $User.Lastname          
    $UserFirstname = $User.Firstname            
    $UserLastname = $User.Lastname       
    $SAM = $User.SAM            
    $UPN = $User.Firstname + "." + $User.Lastname + "@" + "Core-Group.dk"         
    $Password = $User.Password     
          
    New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname" -Description "$Description" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path $OU -ChangePasswordAtLogon $false –PasswordNeverExpires $true -server Core-Group.dk           
}