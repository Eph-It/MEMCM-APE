Function Write-APELog {
    Param (
		[Parameter(Mandatory=$true)]
        $Message,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$IncludeObjects,

		[Parameter(Mandatory=$false)]
		$ErrorMessage,
 
		[Parameter(Mandatory=$false)]
		$Component = ' ',
 
        [Parameter(Mandatory=$false)]
        [ValidateSet(1, 2, 3)]
		[int]$Type = 1
	)
    <#
    Type: 1 = Normal, 2 = Warning (yellow), 3 = Error (red)
    #>
    $LogFile = $Script:APELogFilePath
	$Time = Get-Date -Format "HH:mm:ss.ffffff"
	$Date = Get-Date -Format "MM-dd-yyyy"
 
	if ($null -ne $ErrorMessage) {$Type = 3}
    $IncludeObjectsString = ''
    foreach($key in $IncludeObjects.Keys){
        $IncludeObjectsString += "$($Key): $($IncludeObjects[$key])`n"
    }
    if(-not [string]::IsNullOrEmpty($IncludeObjectsString)){
        $IncludeObjectsString = "`n$IncludeObjectsString"
    }

	$LogMessage = "<![LOG[$Message $IncludeObjectsString $ErrorMessage" + "]LOG]!><time=`"$Time`" date=`"$Date`" component=`"$Component`" context=`"`" type=`"$Type`" thread=`"`" file=`"`">"
	Out-File -InputObject $LogMessage -Append -Encoding UTF8 -FilePath $LogFile
}