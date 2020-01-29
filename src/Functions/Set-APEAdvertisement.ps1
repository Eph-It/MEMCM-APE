Function Set-APEAdvertisement{
    Param(
        $Advertisement
    )
    $Query = "Select * FROM SMS_Advertisement WHERE AdvertisementID = '$($Advertisement.DeploymentId)'"
    $WMIAdvertisement = Get-APEWMIDeployment -query $Query
    if($true -ne $WMIAdvertisement.ExpirationTimeEnabled) {
        $Advertisement.ExpirationTime = $null
    }
    $null = $WMIAdvertisement.Get()
    if($null -ne $WMIAdvertisement) {
        $TenYears = ([DateTime]::UtcNow.AddYears(10)).Year
        $Advertisement.WMIStartTime = $WMIAdvertisement.PresentTime
        $Advertisement.WMIExpirationTime = $WMIAdvertisement.ExpirationTime
        $Advertisement.Schedule = ''
        if($WMIAdvertisement.AdvertFlags){
            if(($Advertisement.AdvertFlags -and '0x00000020') -eq '0x00000020' ) {
                $Advertisement.Schedule += "As soon as possible`n"
            }
            if(($Advertisement.AdvertFlags -and '0x00000200') -eq '0x00000200' ) {
                $Advertisement.Schedule += "Log on`n"
            }
            if(($Advertisement.AdvertFlags -and '0x00000400') -eq '0x00000400' ) {
                $Advertisement.Schedule += "Log off`n"
            }
        }
        if($null -ne $WMIAdvertisement.AssignedSchedule) {
            $ScheduleArray = $WMIAdvertisement.AssignedSchedule
            for ($i = 0; $i -lt $ScheduleArray.Count; $i++) {
                $startTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($ScheduleArray[$i].StartTime)
                $useGMT = ''
                if($ScheduleArray[$i].IsGMT -eq $true){ $useGMT = ' GMT' }
                $strStartTime = "$($startTime.ToShortDateString()) $($startTime.ToShortTimeString())$($useGMT)`n"
                switch($ScheduleArray[$i].__CLASS){
                    "SMS_ST_NonRecurring"{
                        $Advertisement.Schedule += "Occurs on $($strStartTime)"
                    }
                    "SMS_ST_RecurInterval"{
                        $Advertisement.Schedule += "Occurs every "
                        if($ScheduleArray[$i].DaySpan -gt 0) {
                            $Advertisement.Schedule += $ScheduleArray[$i].DaySpan + " days"
                        }
                        elseif($ScheduleArray[$i].HourSpan -gt 0) {
                            $Advertisement.Schedule += $ScheduleArray[$i].HourSpan + " hours"
                        }
                        elseif($ScheduleArray[$i].MinuteSpan -gt 0) {
                            $Advertisement.Schedule += $ScheduleArray[$i].MinuteSpan + " days"
                        }
                        $Advertisement.Schedule += " effective $($strStartTime)"
                    }
                    "SMS_ST_RecurMonthlyByDate"{
                        $Advertisement.Schedule += "Occurs "
                        if($ScheduleArray[$i].MonthDay -eq 0){
                            $Advertisement.Schedule += "the last day of every $($ScheduleArray[$i].ForNumberOfMonths) months effective $($strStartTime)"
                        }
                        else {
                            $Advertisement.Schedule += "day $($ScheduleArray[$i].MonthDay) of every $($ScheduleArray[$i].ForNumberOfMonths) months effective $($strStartTime)"
                        }
                    }
                    "SMS_ST_RecurWeekly" {
                        $dayOfWeek = [System.DayOfWeek]($ScheduleArray[$i].Day - 1)
                        $weeks = $ScheduleArray[$i].ForNumberOfWeeks
                        $Advertisement.Schedule += "Occurs every $weeks weeks on $dayOfWeek effective $strStartTime"
                    }
                    Default {
                        $Advertisement.Schedule += "Effective $strStartTime"
                    }
                }
                if($null -ne $ScheduleArray[$i].StartTime) {
                    $st = $ScheduleArray[$i].StartTime
                    $st = "$($TenYears)$($st.Substring(4, $st.Length - 4))"
                    $ScheduleArray[$i].StartTime = $st
                }
            }
            $WMIAdvertisement.AssignedSchedule = @($ScheduleArray)
            if(-not [string]::IsNullOrEmpty($Advertisement.WMIStartTime)){
                $WMIAdvertisement.PresentTime = "$($TenYears)$($Advertisement.WMIStartTime.Substring(4, $Advertisement.WMIStartTime.Length - 4))"
            }
            if(-not [string]::IsNullOrEmpty($Advertisement.WMIExpirationTime)){
                $WMIAdvertisement.ExpirationTime = "$($TenYears)$($Advertisement.WMIExpirationTime.Substring(4, $Advertisement.WMIExpirationTime.Length - 4))"
            }
        }
        if($true -ne $Script:APESettings.ReadOnly) {
            $null = $WMIAdvertisement.Put()
        }
    }
    return $Advertisement
}