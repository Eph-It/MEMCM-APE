Param(
    $WebhookData
)

$ScapeData = ($WebhookData.RequestBody | ConvertFrom-Json)

$ErrorActionPreference = 'Stop'
$TenantDomain = Get-AutomationVariable -Name 'SharePointDomain'
$ApeCredential = Get-AutomationPSCredential -Name 'APESharePointAccess'
$Scope = "https://graph.microsoft.com/.default"
$Url = "https://login.microsoftonline.com/$($TenantDomain)/oauth2/v2.0/token"
$Body = @{
    client_id = $ApeCredential.UserName
    client_secret = $ApeCredential.GetNetworkCredential().password
    scope = $Scope
    grant_type = 'client_credentials'
}
$AuthorizationRequest = Invoke-RestMethod -Uri $Url -Method 'post' -Body $Body
$Header = @{Authorization = "$($AuthorizationRequest.token_type) $($AuthorizationRequest.access_token)"}

$SharePointSite = Get-AutomationVariable -Name 'ApeSiteId'

$ScapeRequestsListId = Get-AutomationVariable -Name 'ApeRequestListId'
$Body = (@{
    "fields" = @{
        CollectionId = "$($ScapeData.CollectionId)"
        CollectionName = "$($ScapeData.CollectionName)"
        Creator = "$($ScapeData.Creator)"
        DeploymentId = "$($ScapeData.DeploymentId)"
        DeploymentName = "$($ScapeData.DeploymentName)"
        DeploymentType = "$($ScapeData.DeploymentType)"
        SoftwareId = "$($ScapeData.SoftwareId)"
        SoftwareName = "$($ScapeData.SoftwareName)"
        SoftwareType = "$($ScapeData.SoftwareType)"
        Title = "$($ScapeData.DeploymentName)"
        WMIExpirationTime = "$($ScapeData.WMIExpirationTime)"
        WMIRequiredTime = "$($ScapeData.WMIRequiredTime)"
        WMISchedule = "$($ScapeData.WMISchedule)"
        WMIStartTime = "$($ScapeData.WMIStartTime)"
    }
}) | ConvertTo-JSON

$null = Invoke-RestMethod -URI "https://graph.microsoft.com/v1.0/sites/$SharePointSite/lists/$ScapeRequestsListId/items" -Method 'Post' -Headers $Header -ContentType 'application/json' -Body $Body
