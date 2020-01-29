Function Set-APEAssignment {
    Param(
        $Assignment
    )
    $Query = "Select * FROM SMS_ApplicationAssignment WHERE AssignmentID = '$($Assignment.DeploymentId)'"
    $WMIAssignment = Get-APEWMIDeployment -query $Query
    $null = $WMIAssignment.Get()
    if($null -ne $WMIAssignment) {
        $TenYears = ([DateTime]::UtcNow.AddYears(10)).Year
        $Assignment.WMIRequiredTime = $WMIAssignment.EnforcementDeadline
        $Assignment.WMIStartTime = $WMIAssignment.StartTime
        $Assignment.WMIExpirationTime = $WMIAssignment.ExpirationTime
        if(-not [string]::IsNullOrEmpty($Assignment.WMIRequiredTime)){
            $WMIAssignment.EnforcementDeadline = "$($TenYears)$($Assignment.WMIRequiredTime.Substring(4, $Assignment.WMIRequiredTime.Length - 4))"
        }
        if(-not [string]::IsNullOrEmpty($Assignment.WMIStartTime)){
            $WMIAssignment.StartTime = "$($TenYears)$($Assignment.WMIStartTime.Substring(4, $Assignment.WMIStartTime.Length - 4))"
        }
        if(-not [string]::IsNullOrEmpty($Assignment.WMIExpirationTime)){
            $WMIAssignment.ExpirationTime = "$($TenYears)$($Assignment.WMIExpirationTime.Substring(4, $Assignment.WMIExpirationTime.Length - 4))"
        }
        if($true -ne $Script:APESettings.ReadOnly) {
            $null = $WMIAssignment.Put()
        }
        return $Assignment
    }
}