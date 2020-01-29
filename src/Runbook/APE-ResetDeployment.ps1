Param(
    $WebHookData
)

$DeploymentData = $WebHookData 

$CMServer = Get-AutomationVariable -Name 'MEMCM-WMIProvider'
$CMNameSpace = Get-AutomationVariable -Name 'MEMCM-Namespace'
#$CMCredential = Get-AutomationCredential -Name 'MEMCM-SCAPECredential'

$WMIArguments = @{
    'ComputerName' = $CMServer
    'Namespace' = $CMNameSpace
    #'Credential' = $CMCredential
}

if($DeploymentData.Type -eq 'Advertisement'){
    $Query = "Select * FROM SMS_Advertisement WHERE AdvertisementID = '$($DeploymentData.DeploymentId)'"
    $WMIAdvertisement = Get-WMIObject -query $Query @WMIArguments
    $null = $WMIAdvertisement.Get()
    if(-not [string]::IsNullOrEmpty($DeploymentData.WMIStartTime)) {
        $WMIAdvertisement.PresentTime = $DeploymentData.WMIStartTime
    }
    if(-not [string]::IsNullOrEmpty($DeploymentData.WMIExpirationTime)) {
        $WMIAdvertisement.ExpirationTime = $DeploymentData.WMIExpirationTime
    }
    if(-not [string]::IsNullOrEmpty($DeploymentData.WMISchedule)) {
        $response = Invoke-WmiMethod -Class 'SMS_ScheduleMethods' -Name 'ReadFromString' -ArgumentList $DeploymentData.WMISchedule @WMIArguments
        $WMIAdvertisement['AssignedSchedule'] = @($response.TokenData)
    }
    $null = $WMIAdvertisement.Put()
}
elseif($DeploymentData.Type -eq 'Advertisement'){
    $Query = "Select * FROM SMS_ApplicationAssignment WHERE AssignmentID = '$($DeploymentData.DeploymentId)'"
    $WMIAssignment = Get-WMIObject -query $Query @WMIArguments
    $null = $WMIAssignment.Get()
    if(-not [string]::IsNullOrEmpty($DeploymentData.WMIStartTime)) {
        $WMIAssignment.StartTime = $DeploymentData.WMIStartTime
    }
    if(-not [string]::IsNullOrEmpty($DeploymentData.WMIExpirationTime)) {
        $WMIAssignment.ExpirationTime = $DeploymentData.WMIExpirationTime
    }
    if(-not [string]::IsNullOrEmpty($DeploymentData.WMIRequiredTime)) {
        $WMIAssignment.EnforcementDeadline = $DeploymentData.WMIRequiredTime
    }
}