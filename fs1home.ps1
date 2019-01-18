# objective - create home folder
#GIT TEST FROM NICK
#grab_credentials
. ".\getcreds.ps1"

function get_folders($root) {
	$arr = @()
	foreach($folder in (Get-ChildItem $root)) {
  	$arr += $folder.name
  }
	return $arr
}


function findfolderstodelete($user_arr, $folders_arr) {
    $arr = @()
    foreach($folder in $folders_arr) {
    	if($user_arr -notcontains $folder) {
      	$arr += $folder
      }
    }
    return $arr
}

function findfoldertocreate($user_arr, $folders_arr) {
    $arr = @()
    foreach($user in $user_arr) {
    	if($folders_arr -notcontains $user) {
      	$arr += $user
      }
    }
    return $arr
}

# -----------------------------------------------------------------
# -----------------------------------------------------------------
# -----------------------------------------------------------------
# -----------------------------------------------------------------

function get_usernames() {
		$user_arr = @()
    $cred = GETCREDENTIALS
    Connect-MsolService -Credential $cred
    #Connect-MsolService
    $Userdata =  Get-MSOLUser | Where-Object { $_.isLicensed -eq "True"} | Select-Object DisplayName, UserPrincipalName, isLicensed 
    foreach ($user in $Userdata) {
        $email = $user.UserPrincipalName
        $emailsplit = @($email -split('@')) 
        $username = $emailsplit[0]
        #Write-Host($username)
        $user_arr += $username
    }
    return $user_arr
}

# -----------------------------------------------------------------
# -----------------------------------------------------------------
# -----------------------------------------------------------------
# -----------------------------------------------------------------
function create_and_secure_folder($path, $user, $root_or_sub) {
    Write-Host ("Current processing: $user")
    New-Item -Itemtype directory -path $path
    $cur_cmd = ""
    if(Test-Path -path $path) {
        Write-Host("Created: $path")
        if($root_or_sub -eq "root") {   $cur_cmd = "icacls $($path) /grant $($user)@bayley.net:(R)" }
        if($root_or_sub -eq "sub") {    $cur_cmd = "icacls `"$path`" /grant $($user)@bayley.net:(CI)(OI)(RC,WDAC,WO,S,AS,RD,WD,AD,REA,WEA,X,DC,RA,WA) /T /C" }
    }
    else {
        "FAILED TO CREATE: $path"
    }
    cmd.exe /C "$($cur_cmd)"
    Write-Host $cur_cmd
}

function create_folders($arr, $root) {
    foreach ($user in $arr) {
        $head = "$root\$user"
        $email_archive_path = "$head\Email Archives"
        $files_path = "$head\Files"
        $scans = "$head\Scans"
        create_and_secure_folder -path $head -user $user -root_or_sub "root"

        create_and_secure_folder -path $email_archive_path -user $user -root_or_sub "sub"
        create_and_secure_folder -path $files_path -user $user -root_or_sub "sub"
        create_and_secure_folder -path $scans -user $user -root_or_sub "sub"
	}
}

# -----------------------------------------------------------------
# -----------------------------------------------------------------
# -----------------------------------------------------------------
# -----------------------------------------------------------------

function main($root) {
    #get user names
    $user_arr = get_usernames
    $folders_arr = get_folders -root $root
    $folders_to_create = findfoldertocreate -user_arr $user_arr -folders_arr $folders_arr
    create_folders -arr $folders_to_create -root $root
}

# $ROOT_HOME_FOLDER = "\\fs1\home"
$ROOT_HOME_FOLDER = "\\fs1\Home"
main -root $ROOT_HOME_FOLDER


