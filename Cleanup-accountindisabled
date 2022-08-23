#Script name: Cleanup-accountindisabled
#Author: Recep Sarikaya
#Date: 10-06-2022
#Purpose: find all AD users in the disabled OU.
#Requirements: run from Exchange Shell, requires AD module

## modules Necessary: Active Directory, Exchange powershell
## Service account should be able to interact with homedrive location, Should have Account operator rights in AD & Recipient management in Exchange.


##Import the AD and exchange module

#Active Directory module check
if (-not (Get-Module ActiveDirectory)){
    Import-Module ActiveDirectory -ErrorAction Stop
}

#Run “get-pssnapin –registered” and see if the snap-in is already installed.
#Import exchange shell into powershell
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn 

#OU folder where the script looks 
$SourceOU= 'OU = OU, DC = Domain, DC = com'

#The location path for the log
$Logpath = "C:\choose a path\file.txt"

#Date of 14 days ago
$Date = (Get-Date).AddDays(-14)

#Filter for Get-ADUser, User Accounts that are disabled with expiration date of 14 days ago
$UserFilter = {Enabled -eq $false -and AccountExpirationDate -le $Date}

#$Users variable used for the foreach loop, Samaccountname is used as unique ID
$Users = Get-ADUser -Filter $UserFilter -SearchBase $SourceOU -Properties Samaccountname, HomeDirectory,EmailAddress,MemberOf

#Foreach User that is found in $Users
Foreach ($user in $Users){
    
    ############### Delete Home Directory #################
    if($user.HomeDirectory -eq $null){
    
        #write "No homedir folder found" in the logfile
        Write-Output "$(get-date) No homedir folder found for user $($user.SamAccountName)"|

        #Save the result to the logfile 
        out-file -Filepath $Logpath -append

        }else{
        
        #Delete the HomeDirectory Folder recursivly without confirmation, (first the files, then the folder)
        Remove-Item -Path $user.HomeDirectory -Recurse -Force -Confirm:$false 

        #Write "Homedir Folder Removed" in the logfile
        write-output "$(get-date) Homedir Folder Removed for user $($user.SamAccountName)"|

        #Save the result to the logfile 
        out-file -Filepath $Logpath -append
        }

        ##############Delete Membership ###################

        #make a memberof list of the user
        $memberofList = (Get-ADPrincipalGroupMembership $user| select -Expand name) -join ", "

        #Set the Memberof list in profile description of the user
        Set-ADUser $user -Description "Was a member of :- $($memberofList)"

        #Loop through all the memberof groups of the user
        foreach($group in $user.MemberOf){
        
        #Remove member of all groups, except domain users
        #because Domain Users is not actually in the memberOf attribute but the primaryGroupID
        Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false 
                       
        }
        
    
    ############ Disable Emailadress #####################
    if($user.EmailAddress -eq $null){
        
        #Write "No Email adres found" In the logfile
        write-output "$(get-date) No Emailadress found for user $($user.SamAccountName)"|
        #Save the result to the logfile 
        out-file -Filepath $Logpath -append

        }else{
        #Disable the archive
        Disable-Mailbox -identity $user.EmailAddress -Archive -Confirm:$false

        #Disable the mailbox
        Disable-Mailbox -identity $user.EmailAddress -Confirm:$false
        
        #Write "Emailadress disabled" in the logfile
        write-output " $(get-date) Emailadress disabled for user $($user.SamAccountName)"|

        #Save the result to the logfile 
        out-file -Filepath $Logpath -append
        }
   
   ############### Log File #############################

    #Write an output with the date/time and username
    write-output "$(get-date) removed user $($user.SamAccountName) \n"|

    #Save the result to the logfile 
    out-file -Filepath $Logpath -append
    

}

#disconnect the exchange session
Get-PSSession | Remove-PSSession
