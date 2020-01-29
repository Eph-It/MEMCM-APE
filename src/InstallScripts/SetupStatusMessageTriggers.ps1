$APEFolder = (Get-Item $PSScriptRoot).Parent.FullName
$RunAPEPath = "$APEFolder\RunAPE.cmd"
$RunAPEPathAndParams = "`"$RunAPEPath`" %msgid `"%msgis01`" `"%msgis02`" `"%msgis03`" `"%msgis04`" `"%msgis05`""

$APESettings = ConvertFrom-JSON ( Get-Content -Path "$APEFolder\APESettings.json" -Raw )
$Functions = Get-ChildItem -Path "$APEFolder\Functions" -Filter '*.ps1'
foreach($Function in $Functions) {
    . $Function.FullName
}

$SiteCode = $APESettings.SiteCode # Site code 
$ProviderMachineName = $APESettings.WMIProviderServer # SMS Provider machine name

$initParams = @{}
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

Set-Location "$($SiteCode):\" @initParams


$StatusMessageIds = @(
    30006,
    30007,
    30008,
    30226,
    30227,
    30228,
    30016,
    30152,
    30001,
    30068,
    30004
)

Foreach($id in $StatusMessageIds) {
    $RuleName = "APE - $(Get-APEObjectName -MessageId $id) $(Get-APEActionName -MessageId $Id)"
    if($Rule = Get-CMStatusFilterRule -Name $RuleName) {
        Set-CMStatusFilterRule -Name $RuleName -MessageId $id -RunProgram $true -ProgramPath $RunAPEPathAndParams
    }
    else {
        New-CMStatusFilterRule -Name $RuleName -MessageId $id -RunProgram $true -ProgramPath $RunAPEPathAndParams
    }
}