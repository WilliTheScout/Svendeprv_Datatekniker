# --- CREATE USERS --- #

#Imports data from .csv file
$Users = Import-Csv -Path "C:\Temp\Userlist.csv" 

#Runs for each user in the .csv file           
foreach ($User in $Users)            
{    
    #Define OU        
    $OU = switch ($User.Afdeling)
     {
        Administration {'OU=Administration,OU=Users,OU=Core-Group,DC=core-group,DC=dk'}
        HR {'OU=HR,OU=Users,OU=Core-Group,DC=core-group,DCdk'}
        IT {'OU=IT,OU=Users,OU=Core-Group,DC=core-group,DC=dk'}
        Ledelse {'OU=Ledelse,OU=Users,OU=Core-Group,DC=core-group,DC=dk'}
        Revision {'OU=Revision,OU=Users,OU=Core-Group,DC=core-group,DC=dk'}
     }
    
    #Assing data to viraibels
    $Displayname = $User.Firstname + " " + $User.Lastname          
    $UserFirstname = $User.Firstname            
    $UserLastname = $User.Lastname       
    $SAM = $User.SAM            
    $UPN = $User.Firstname + "." + $User.Lastname + "@" + "Core-Group.dk"
    $Email = $User.SAM + "@Core-Group.dk"         
    $Password = "Password!" 
    
    #Creates and enables the user      
    New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname" -EmailAddress $Email -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path $OU -ChangePasswordAtLogon $false –PasswordNeverExpires $true -server Core-Group.dk -PassThru | Enable-ADAccount           
}