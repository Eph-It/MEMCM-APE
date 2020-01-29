Function ConvertTo-APEPSObject {
    Param(
        $Deployment
    )
    $Hash = @{
        "StartTime" = ''
        "DeploymentName" = ''
        "DeploymentType" = ''
        "DeploymentId" = ''
        "SoftwareType" = ''
        "SoftwareName" = ''
        "SoftwareId" = ''
        "CollectionName" = ''
        "CollectionType" = ''
        "CollectionId" = ''
        "Creator" = ''
        "CMObjectType" = ''
        "CMAction" = ''
        "RequiredTime" = ''
        "ExpirationTime" = ''
        "Schedule" = ''
        "UseUTC" = ''
        "WMIStartTime" = ''
        "WMIExpirationTime" = ''
        "WMIRequiredTime" = ''
        "WMISchedule" = ''
    }
    $ReturnObject = New-Object PSObject -Property $Hash
    if($null -ne $deployment.OfferId) {
        
        $ReturnObject.CollectionId = $Deployment.CollectionID
        $ReturnObject.DeploymentId = $deployment.OfferId
        $ReturnObject.DeploymentName = $deployment.OfferName
        $ReturnObject.DeploymentType = 'Advertisement'
        $ReturnObject.ExpirationTime = $deployment.ExpirationTime
        $ReturnObject.StartTime = $deployment.PresentTime
        $ReturnObject.SoftwareId = $deployment.PkgID
        $ReturnObject.SoftwareName = $deployment.PkgProgram
        $ReturnObject.SoftwareType = 'Package'
        $ReturnObject.WMISchedule = $Deployment.MandatorySched
    }
    elseif ($null -ne $deployment.AssignmentID) {
        $ReturnObject.CollectionName = $deployment.CollectionName
        $ReturnObject.CollectionId = $Deployment.CollectionID
        $ReturnObject.DeploymentId = $deployment.AssignmentID
        $ReturnObject.DeploymentName = $deployment.AssignmentName
        $ReturnObject.DeploymentType = 'Assignment'
        $ReturnObject.ExpirationTime = $deployment.ExpirationTime
        $ReturnObject.RequiredTime = $deployment.EnforcementDeadline
        $ReturnObject.StartTime = $deployment.StartTime
        $ReturnObject.SoftwareId = $deployment.AppModelID
        $ReturnObject.SoftwareName = $deployment.ApplicationName
        $ReturnObject.SoftwareType = 'Application'
        $ReturnObject.UseUTC = $deployment.UseGMTTimes
    }
    return $ReturnObject
}