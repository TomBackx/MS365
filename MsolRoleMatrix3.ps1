

if(-not (Get-MsolDomain -ErrorAction SilentlyContinue)) # check if Msolservice is not loaded
{
    Connect-MsolService #load if not
}

$OutFile = "c:\temp\$(Get-Date -Format yyyyMMddHHMMss)_MsolRoleMatrix3.csv" #outputlocation
$AllRoleUsersIncReservedFirstEntry = Get-MsolRole | %{$role = $_.name; Get-MsolRoleMember -RoleObjectId $_.objectid} | select EmailAddress | Sort-Object EmailAddress -unique #find all users with Office365 admin roles
$First, $AllRoleUsers= $AllRoleUsersIncReservedFirstEntry #Remove 1e reserved system entry
$msolRoles = Get-MsolRole # get all available office365 admin roles
$adminusers = $null #clear variables for clean new run



foreach ($AllRoleUser in $AllRoleUsers){ #create 1e line comma seperated with all Office365admin users email addresses
    $adminusers = $adminusers + "," + $AllRoleUser.EmailAddress | Sort-object EmailAddress
}

write-output $adminusers | Out-File $OutFile -Encoding UTF8 -Append #log output
#Write-Host $adminusers -ForegroundColor Yellow #enable for testing visibilty 

foreach ($msolRole in $msolRoles) {#check for each role if office admin user is member
    #Write-host $msolRole.name -ForegroundColor Yellow #enable for testing visibilty 
    
    $members = Get-MsolRoleMember -RoleObjectId $msolRole.ObjectId | Sort-object EmailAddress #get all admin members in a role
    $adminusers = $msolRole.name #create first entry in line (with name of the role)
    if ($null -ne $members){ #hide empty roles
        foreach ($AllRoleUser in $AllRoleUsers){#check for each role if office admin user is member
            $AllRoleUserEmailAddress = $AllRoleUser.EmailAddress
            if ($members.EmailAddress -like "$AllRoleUserEmailAddress"){#needed cause lack op powershell skills by author
                $adminusers = $adminusers + ",V"
            }
            else{
            $adminusers = $adminusers + ","
            }
        }
        #$adminusers #enable for testing visibilty 
        write-output $adminusers | Out-File $OutFile -Encoding UTF8 -Append #log output
    }   
}