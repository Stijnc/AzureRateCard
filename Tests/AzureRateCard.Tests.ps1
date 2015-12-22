#Requires -Modules Pester
<#
.SYNOPSIS
    Tests the AzureRateCard module
.EXAMPLE
    Invoke-Pester 
.NOTES
    This script originated from work found here:  https://github.com/kmarquette/PesterInAction
#>

# TODO Maybe the top of the file should have a hashtable of commands and their parameters?

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$parent = Split-Path -parent $here
$module = Split-Path -Leaf $parent

Describe "Module: $module" -Tags Unit {
#region Generic PS module tests
    
    # TODO This section should use Module in the same way as the others
    Context "Module Configuration" {
        
        It "Has a root module file ($module.psm1)" {        
            
            "$parent\$module.psm1" | Should Exist
        }

        It "Is valid Powershell (Has no script errors)" {

            $contents = Get-Content -Path "$parent\$module.psm1" -ErrorAction SilentlyContinue
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should Be 0
        }

        It "Has a manifest file ($module.psd1)" {
            
            "$parent\$module.psd1" | Should Exist
        }

        It "Contains a root module path in the manifest (RootModule = '.\$module.psm1')" {
            
            "$parent\$module.psd1" | Should Exist
            "$parent\$module.psd1" | Should Contain "\.\\$module.psm1"
        }

        It "Is valid Powershell (Has no script errors)" {
            $contents = Get-Content -Path "$parent\$module.psm1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should Be 0
        }
    }

    

    Context 'Module loads and Functions exist' {
        
        $manifest = Test-ModuleManifest -Path "$parent\$module.psd1"
        $ExportedCommands = $manifest.ExportedCommands
        $ModuleName = $manifest.Name
        
        It 'Module should load without error' {
            # TODO the next line is not generic
            $loadedModule.Name | Should Be $ModuleName
        }

        It 'Exported commands should include all functions' {
            $loadedFunctions | Should Be $ExportedCommands.Keys
        }
        
        BeforeEach {
            if (get-module $Module) {remove-module $Module}
            import-Module "$parent\$module.psd1" -ErrorAction SilentlyContinue
            $loadedModule = Get-Module $module -ErrorAction SilentlyContinue    
            $loadedFunctions = $loadedModule.ExportedCommands.Keys
            
        }
        AfterEach {
            
            remove-module $module
            $loadedModule = $null
            $loadedFunctions = $null
        }
    }

    Context 'Help provided for Functions' {
        
        Foreach ($Function in $loadedFunctions) {

            $Help = Get-Help $Function

            It "$Function should have a non-default Synopsis section in help" {                
                $Help.Synopsis | Should Not Match "\r\n$Function*"
                }

            It "$Function should have help examples" {
                $Help.Examples.Example.Count | Should Not Be 0
                }

            # TODO the next line is not generic
            If ($Function -eq 'Remove-WSManTrust') {
                $ParamNames = 'hostname','all'
                It "$Function should have correct parameter names" {
                    (Get-Command $Function).Parameters.Keys | Should Be $ParamNames
                }
            }
        }
        
        BeforeAll {
            if (get-module $Module) {remove-module $Module}
            import-Module "$parent\$module.psd1" -ErrorAction SilentlyContinue
            $loadedModule = Get-Module $module -ErrorAction SilentlyContinue    
            $loadedFunctions = $loadedModule.ExportedCommands.keys
        }
        AfterAll {
            
            remove-module $module
            $loadedFunctions = $null
            $loadedModule = $null
        }
    }
}
#endregion