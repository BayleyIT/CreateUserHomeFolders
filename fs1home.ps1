# objective - create home folder

function get_folders() {
	$arr = @()
	foreach($folder in (Get-ChildItem "\\fs1\d$\Home")) {
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
function secure_folder($path, $user, $top_or_bottom) {
	$command = ""
	if($top_or_bottom -eq "top") {
  	$command = "icacls `"$path`" /grant $($user):(R)(NP)"
  }
	if($top_or_bottom -eq "bottom") {
  	$command = "icacls `"$path`" /grant $($user):(F)"
  }
  cmd.exe /c $command
}
function create_folders($arr) {
	$root_path2 = "C:\users\a_navi\desktop\test"
    foreach ($user in $arr) {
        Write-Host ($user)
        if (Test-Path -path $root_path2) {
          New-Item -Itemtype directory -path "$root_path2\$user"
          secure_folder -path "$root_path2\$user" -user $user -top_or_bottom "top"
          New-Item -Itemtype directory -path "$root_path2\$user\Emails Archives"
          secure_folder -path "$root_path2\$user\Emails Archives" -user $user -top_or_bottom "top"
          New-Item -Itemtype directory -path "$root_path2\$user\Scans"
          secure_folder -path "$root_path2\$user" -user $user -top_or_bottom "top"
          New-Item -Itemtype directory -path "$root_path2\$user\Files"
          secure_folder -path "$root_path2\$user\Files" -user $user -top_or_bottom "top"
    }
	}
}

# -----------------------------------------------------------------
# -----------------------------------------------------------------
# -----------------------------------------------------------------
# -----------------------------------------------------------------

function main($root) {
	#get user names
  Write-Host("Here1")
	$user_arr = get_usernames
  $folders_arr = get_folders
  $folders_to_create = findfoldertocreate -user_arr $user_arr -folders_arr $folders_arr
  create_folders -arr $folders_to_create
}

$ROOT_HOME_FOLDER = "\\fs1\home"
main -root $ROOT_HOME_FOLDER


