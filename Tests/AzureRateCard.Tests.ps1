#Requires -Modules Pester
<#
.SYNOPSIS
    Tests the AzureRateCard module
.EXAMPLE
    Invoke-Pester 
.NOTES
    This file contains only module specific test.
    For general tests, refer to https://github.com/Stijnc/PowerShellModule.Tests
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$parent = Split-Path -parent $here
$module = Split-Path -Leaf $parent

#region HEADER
if ( -not (Test-Path -Path '.\PowerShellModule.Tests\')) {
    & git @('clone','https://github.com/Stijnc/PowerShellModule.Tests.git')
}
else {
    & git @('-C',(Join-Path -Path (Get-Location) -ChildPath '\PowerShellModule.Tests\'),'pull')
}

#endregion

#region Specific Module tests
Describe "$module Module Integration" {
  
    It 'Contains the ADAL dll' {
        "$parent\Assemblies\Microsoft.IdentityModel.Clients.ActiveDirectory.dll" | Should Exist
    }
}
#endregion