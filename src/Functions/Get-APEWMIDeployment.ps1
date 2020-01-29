Function Get-APEWMIDeployment{
    Param(
        [string]$query,
        [int]$Count = 0
    )
    $MaxCount = 15
    $Deployment = Get-WMIObject -Query $Query -Namespace "root\sms\site_$($Script:APESettings.SiteCode)" -ComputerName $Script:APESettings.WMIProviderServer
    if($null -eq $Deployment) {
        $count++
        if($Count -lt $MaxCount) {
            Start-Sleep 1
            Get-APEWMIDeployment -query $query -Count $Count
        }
    }
    else {
        $Deployment.Get()
        $Deployment
    }
}