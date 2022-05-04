param(
    [int]$MessageId,
    [string]$InsStr1,
    [string]$InsStr2,
    [string]$InsStr3,
    [string]$InsStr4,
    [string]$InsStr5
)

$Script:APELogFilePath = "$PSScriptRoot\APELog.log"

try{
    $Functions = Get-ChildItem -Path "$PSSCriptRoot\Functions" -Filter '*.ps1'
    foreach($Function in $Functions) {
        . $Function.FullName
    }
}
catch {
    Write-APELog -Message 'Was not able to import functions - exiting' -ErrorMessage $_.Exception.Message
    exit
}

Write-APELog -Message 'Starting APE with parameters ' -IncludeObjects @{
    'MessageId' = $MessageId
    'InsStr1' = $InsStr1
    'InsStr2' = $InsStr2
    'InsStr3' = $InsStr3
    'InsStr4' = $InsStr4
    'InsStr5' = $InsStr5
}

try{
    $Script:APESettings = ConvertFrom-JSON ( Get-Content -Path "$PSScriptRoot\APESettings.json" -Raw )
}
catch{
    Write-APELog -Message 'Was not able to get settings - exiting' -ErrorMessage $_.Exception.Message
    exit
}


if(
    ("$($env:USERDOMAIN)\$($env:USERNAME)" -eq $InsStr1) -or
    ( $APESettings.ExcludedUsers -contains $InsStr1 ) -or
    ( 'NT AUTHORITY\SYSTEM' -eq $InsStr1 ) ) {
    #Have to exclude the current user to avoid a bad loop
    Write-APELog -Message "User found to be $($InsStr1) and they are excluded! Exiting"
    exit
}
try{
    $Deployments = Get-APEDeployment -MessageID $MessageId -InsString2 $InsStr2 -InsString3 $InsStr3 -InsString4 $InsStr4
}
catch {
    Write-APELog -Message 'Could not get deployments associated with parameters - Exiting' -ErrorMessage $_.Exception.Message
}


foreach($deployment in $Deployments){
    $DeploymentInformation = ConvertTo-APEPSObject -Deployment $deployment
    if($null -eq $DeploymentInformation){
        #means no ID found - happens when SQL script returns a blank result (meaning nothing was found)
        continue
    }
    if($DeploymentInformation.StartTime -gt [DateTime]::UTCNow.AddYears(9)){
        Write-APELog -Message "Deployment found to already be delayed > 9 years so nothing to do - moving to next one. Deployment Information:" -IncludeObjects @{
            'DeploymentName' = $DeploymentInformation.DeploymentName
            'DeploymentId' = $DeploymentInformation.DeploymentId
            'StartTime' = $DeploymentInformation.StartTime
            'CollectionId' = $DeploymentInformation.CollectionId
        }
        continue
    }
    $DeploymentInformation.Creator = $InsStr1.Split('\')[1]
    $DeploymentInformation.CMAction = Get-APEActionName -MessageId $MessageId
    $DeploymentInformation.CMObjectType = Get-APEObjectName -MessageId $MessageId
    Write-APELog -Message 'Delaying deployment ' -IncludeObjects @{
        'DeploymentName' = $DeploymentInformation.DeploymentName
        'DeploymentId' = $DeploymentInformation.DeploymentId
        'StartTime' = $DeploymentInformation.StartTime
        'CollectionId' = $DeploymentInformation.CollectionId
    }
    if($null -ne $deployment.OfferId) {
        $DeploymentInformation = Set-APEAdvertisement -Advertisement $DeploymentInformation
    }
    elseif ($null -ne $deployment.AssignmentID) {
        $DeploymentInformation = Set-APEAssignment -Assignment $DeploymentInformation
    }
    else{
        Write-APELog -Message 'Was not able to determine deployment type. Might be a big issue. Nothing was delayed' -Type 3
    }
    try{
        $null = Invoke-RestMethod -Uri $Script:APESettings."StartWebHook" -Method 'Post' -Body ($DeploymentInformation | ConvertTo-JSON) -ContentType 'application/json'
    }
    catch {
        Write-APELog -Message 'Was not able to call webhook' -ErrorMessage $_.Exception.Message
    }
}

Write-APELog -Message 'APE Process complete!'