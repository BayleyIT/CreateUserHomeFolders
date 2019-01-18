function GETCREDENTIALS() {
    Write-Host("GETTING CREDENTIALS")
    $user= ""
    $pass= ""
    $secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
    $mycreds = New-Object System.Management.Automation.PSCredential ($user, $secpasswd)
    return $mycreds
}