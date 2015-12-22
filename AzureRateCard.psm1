$authorityUri = ''
$resourceUri = ''
$defaultAuthRedirectUri

function Get-AzureAuthtoken {
<#
            .SYNOPSIS
            Gets the authentication token required to comunicate with the Azure API's
            .DESCRIPTION
            To authenticate with Azure. It uses OAuth 2.0 with the Azure AD Authentication Library (ADAL)

            If a credential is not supplied a popup will appear for the user to authenticate.

            The dll "Microsoft.IdentityModel.Clients.ActiveDirectory" is included in the module.
            It will not try to download the nuget as this mechanism fails if the module is used in Azure automation.
            
            To use the Get-AzureAuthToken it is advised to set up an Azure AD application. See the 'Notes' section for more info
            .PARAMETER ClientId
            The Client Id of the Azure AD application
            .PARAMETER Credential
            Specifies a PSCredential object or a string username used to authenticate to Azure. If only a username is specified 
            this will prompt for the password. Note that this will not work with federated users.
            .PARAMETER RedirectUri
                The redirect URI associated with the native client application
            .EXAMPLE
                Get-PBIAuthToken -clientId "C0E8435C-614D-49BF-A758-3EF858F8901B"
                Returns the access token for the PowerBI REST API using the client ID. You'll be presented with a pop-up window for 
                user authentication.
            .EXAMPLE
                $Credential = Get-Credential
                Get-PBIAuthToken -ClientId "C0E8435C-614D-49BF-A758-3EF858F8901B" -Credential $Credential
                Returns the access token for the PowerBI REST API using the client ID and a PSCredential object.
            .NOTES
                If you create an Azure AD application use powershell or create a web application as the new ADAL version requires a password or secret.
                The 'old' Azure AD application does not provide such a secret, it only provides a client id.
                Create an Azure AD application:
                Create an Azure AD application using PowerShell
#>
    [cmdletBinding()]
    Param(
       
       [Parameter(Mandatory=$true)]
       [string]$clientId,
       
       [Parameter(Mandatory=$true)]
       [pscredential]$credential,
   
       [Parameter()]
       [string]$authorityUri = $authorityUri,
       
       [Parameter()]
       [string]$resourceUri = $resourceUri,
       
       [Parameter()]
       [string]$defaultAuthRedirectUri = $defaultAuthRedirectUri,
       
       [Parameter(Mandatory=$true)]
       [string]$azureTenantId = $azureTenantId
       
       
   )
       $clientCredential = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential -ArgumentList ($credential.UserName, $credential.Password)
       $authenticationUri = "{0}/{1}" -f $authenticationUri, $azureTenantId
       
       $authenticationContext = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext -ArgumentList ($authorityUri)
       
       $authResult = $authenticationContext.AcquireToken($authContext,$clientId, $adCredential)
       $authResult.AccessToken
}

function Get-AzureRateCard {
<#
            .SYNOPSIS
                Gets the Azure rate cards for a given offer
            .DESCRIPTION
                The function retrieves the rate cards or prices per resource for a given offer.
                Currently the offers available are:
                'Pay-As-You-Go',
                'Azure Dynamics',
                'Support Plans 1',
                'Support Plans 2',
                'Support Plans 3',
                'Free Trail',
                'MSDN Dev/Test Pay-As-You-Go',
                'Visual Studio Professional subscribers',
                'Visual Studio Test Professional subscribers',
                'Monthly Azure credit for MSDN Platform subscribers',
                'Visual Studio Enterprise with MSDN',
                'Action Pack',
                'Visual Studio Enterprise subscribers',
                'Microsoft Azure Sponsered Offer',
                'Promotional Offer',
                'Azure Pass',
                'Azure in Open Licensing',
                '12-Month Commitment Offer',
                'DreamSpark',
                'BizSpark Plus',
                'Visual Studio Enterprise subscribers'
                The full up to date list is available at https://azure.microsoft.com/en-us/support/legal/offer-details/.        
                Use Get-AzureAuthToken to retrieve a valid authentication token.      
            .PARAMETER offer
                The offer to retrieve the rate cards for.
                The full up to date list is available at https://azure.microsoft.com/en-us/support/legal/offer-details/.
                The parameter accepts the friendly name. 
            .PARAMETER Credential
                Specifies a PSCredential object or a string username used to authenticate to Azure.
            .PARAMETER Currency
                The currency in wich the prices are provided.
                It accepts Euro and US Dollars
            .PARAMETER locale
                The language to return the rate cards in.
                Defaults to en-US
            .PARAMETER regionInfo
                The region info
                Defaults to the exotic BE (Belgium)
            .PARAMETER apiVersion
                The api verison to query
                Defaults to 2015-06-01-preview
#>    
    [cmdletBinding(DefaultParameterSetName='Token')]
    Param(
        
        [Parameter(ParameterSetName='Credential',Mandatory=$true)]
        [Parameter(ParameterSetName='Token',Mandatory=$true)]
        [ValidateSet('Pay-As-You-Go','Azure Dynamics','Support Plans 1','Support Plans 2','Support Plans 3',
           'Free Trail','MSDN Dev/Test Pay-As-You-Go','Visual Studio Professional subscribers','Visual Studio Test Professional subscribers',
           'Monthly Azure credit for MSDN Platform subscribers','Visual Studio Enterprise with MSDN','Action Pack','Visual Studio Enterprise subscribers',
           'Microsoft Azure Sponsered Offer','Promotional Offer','Azure Pass','Azure in Open Licensing','12-Month Commitment Offer','DreamSpark',
           'BizSpark Plus','Visual Studio Enterprise subscribers')]
        [string]$offer,
        
        [Parameter(ParameterSetName='Credential',Mandatory=$true)]
        [pscredential]$credential,
        
        [Parameter(ParameterSetName='Token',Mandatory=$true)]
        [string]$token,
    
        [Parameter(ParameterSetName='Credential')]
        [Parameter(ParameterSetName='Token')]
        [ValidateSet('USD','EUR')]
        [string]$currency = 'USD',
        
        [Parameter(ParameterSetName='Credential')]
        [Parameter(ParameterSetName='Token')]
        [string]$locale = 'En-us',
        
        [Parameter(ParameterSetName='Credential')]
        [Parameter(ParameterSetName='Token')]
        [string]$regionInfo = 'BE',
        
        [Parameter(ParameterSetName='Credential')]
        [Parameter(ParameterSetName='Token')]
        [string]$apiversion = '2015-06-01-preview'
    )
    
    if($PSCmdlet.ParameterSetName -eq 'Credential') {
        
        $token = Get-AzureAuthtoken -credential $credential
        $ResHeaders = Get-AzureRequestHeader -authToken $token
    }
        
    $offerDurableId = $null
    
    switch ($offer)
    {
        'Pay-As-You-Go' {$offerDurableId = '0003P';break}
        'Azure Dynamics' {$offerDurableId = '0033P';break}
        'Support Plans 1' {$offerDurableId = '0041P';break}
        'Support Plans 2' {$offerDurableId = '0043P';break}
        'Support Plans 3' {$offerDurableId = '0043P';break}
        'Free Trail' {$offerDurableId = '0044P';break}
        'MSDN Dev/Test Pay-As-You-Go' {$offerDurableId = '0023P';break}
        'Visual Studio Professional subscribers' {$offerDurableId = '0059P';break}
        'Visual Studio Test Professional subscribers' {$offerDurableId = '0060P';break}
        'Monthly Azure credit for MSDN Platform subscribers' {$offerDurableId = '0062P';break}
        'Visual Studio Enterprise with MSDN (benefit)' {$offerDurableId = '0063P';break}
        'Action Pack' {$offerDurableId = '0025P';break}
        'Visual Studio Enterprise subscribers' {$offerDurableId = '0064P';break}
        'Microsoft Azure Sponsered Offer' {$offerDurableId = '0036P';break}
        'Promotional Offer' {$offerDurableId = '0070P-0089P';break}
        'Azure Pass' {$offerDurableId = '0120P-0130P';break}
        'Azure in Open Licensing' {$offerDurableId = '0111p';break}
        '12-Month Commitment Offer' {$offerDurableId = '0026P';break}
        'DreamSpark' {$offerDurableId = '0144P';break}
        'BizSpark Plus' {$offerDurableId = '0149P';break}
        'Visual Studio Enterprise subscribers' {$offerDurableId = '0029P';break}
    }
    $ResHeaders = @{'authorization' = $token}
    
    $ResourceCard = "https://management.azure.com/subscriptions/{5}/providers/Microsoft.Commerce/RateCard?api-version={0}&`$filter=OfferDurableId eq '{1}' and Currency eq '{2}' and Locale eq '{3}' and RegionInfo eq '{4}'" -f $ApiVersion, $OfferDurableId, $Currency, $Locale, $RegionInfo, $SubscriptionId

    $resources = Invoke-RestMethod -Uri $ResourceCard -Headers $ResHeaders -ContentType 'application/json' 
    $data = $Resources.Meters | 
                Select-Object `
                        MeterId `
                        ,MeterName `
                        ,MeterCategory `
                        ,MeterSubCategory `
                        ,Unit `
                        ,MeterTags `
                        ,MeterRegion `
                        ,@{n='MeterRates';e={$_.MeterRates.0}} `
                        ,EffectiveDate `
                        ,IncludedQuantity `
                        ,@{n='Currency'; e={$Currency}}
    $data
}   

Function Get-AzureRequestHeader {
<#
            .SYNOPSIS
                Creates a request header based on the token provided
            .DESCRIPTION
                Creates a request header based on the authentication token provided as parameter.
                It adds the bearer keyword and sets the content-type to 'application/json'
            the result returned:
                'Content-Type'='application/json'
                'Authorization'= "Bearer $authToken"
            .PARAMETER AuthToken
                The authorization token required to communicate with the Azure APIs
                Use 'Get-AzureAuthToken' to get the authorization token string
#>
    [CmdletBinding()]
    param(
        [string]$authToken
    )
	$headers = @{
		'Content-Type'='application/json'
		'Authorization'= "Bearer $authToken"
		}
	
	$headers
}