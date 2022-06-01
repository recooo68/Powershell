#Script name: disableUsers
#Author: Recep Sarikaya
#Date: 19-05-2022
#Purpose: To disable users that have an end of date less than today and move the users to a specific OU folder.
#Requirements: Account operator rights

#Active Directory module check
if (-not (Get-Module ActiveDirectory)){
    Import-Module ActiveDirectory -ErrorAction Stop
}

#OU folder where the script looks
$SourceOU= 'OU = OU, DC = Domain, DC = com'

#OU folder where the users are placed
$TargetOU = 'OU = OU, DC = Domain, DC = com'

#Todays date
$Date = (Get-Date)

#Filter for Get-ADUser, User accounts that are enabled, with an end of date, end of date of yesterday
$UserFilter = {Enabled -eq $true -and PasswordNeverExpires -eq $False -and AccountExpirationDate -lt $Date}

#$Users variable used for the foreach loop, Samaccountname is used as unique ID
$Users = Get-ADUser -Filter $UserFilter -SearchBase $SourceOU -Properties Samaccountname


#The location path for the log
$Logpath = "C:\choose a path\file.txt"


#Foreach User that is found in $Users
Foreach ($user in $Users){
                            
    #Move the $user to the $TargetOU (-passthru gives the $user information through the pipe)
    Move-ADObject -identity $user -TargetPath $TargetOU -PassThru |
            
    #Disable the $user          
    Disable-ADAccount

    #Write an output with the date and username
    write-output "$Date user $($user.SamAccountName) "|

    #Save the result to the logfile
    out-file -Filepath $Logpath -append  

}

    
        

        

            
