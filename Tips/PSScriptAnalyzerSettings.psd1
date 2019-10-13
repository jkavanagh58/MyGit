@{
    # Use Severity when you want to limit the generated diagnostic records to a
    # subset of: Error, Warning and Information.
    # Uncomment the following line if you only want Errors and Warnings but
    # not Information diagnostic records.
    #Severity = @('Error','Warning')

    # Use IncludeRules when you want to run only a subset of the default rule set.
    #IncludeRules = @('PSAvoidDefaultValueSwitchParameter',
    #                 'PSMissingModuleManifestField',
    #                 'PSReservedCmdletChar',
    #                 'PSReservedParams',
    #                 'PSShouldProcess',
    #                 'PSUseApprovedVerbs',
    #                 'PSUseDeclaredVarsMoreThanAssigments')

    # Use ExcludeRules when you want to run most of the default set of rules except
    # for a few rules you wish to "exclude".  Note: if a rule is in both IncludeRules
    # and ExcludeRules, the rule will be excluded.
    #ExcludeRules = @('PSAvoidUsingWriteHost','PSMissingModuleManifestField')

    # You can use the following entry to supply parameters to rules that take parameters.
    # For instance, the PSAvoidUsingCmdletAliases rule takes a whitelist for aliases you
    # want to allow.
    #Rules = @{
    #    Do not flag 'cd' alias.
    #    PSAvoidUsingCmdletAliases = @{Whitelist = @('cd')}

    #    Check if your script uses cmdlets that are compatible on PowerShell Core,
    #    version 6.0.0-alpha, on Linux.
    #    PSUseCompatibleCmdlets = @{Compatibility = @("core-6.0.0-alpha-linux")}
    #}
    #PSAvoidUsingCmdletAliases = @{Whitelist = @('where') }
    IncludeDefaultRules = $true
    # Verify Module is installed and the correct path
    # Path to module depends on how installed - this case assumes -Scope AllUsers
    CustomRulePath      = "C:\\Program Files\\WindowsPowerShell\\Modules\\InjectionHunter\\1.0.0\\InjectionHunter.psd1"

    Rules               = @{

        PSAvoidUsingCmdletAliases  = @{
            Whitelist = @('where')
        }

        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }

        PSUseConsistentIndentation = @{
            Enable          = $false
            Kind            = 'tab'
            IndentationSize = 4
        }

        PSUseConsistentWhitespace  = @{
            Enable         = $false
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator  = $false
            CheckSeparator = $true
        }

        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }

        PSUseCompatibleCommands    = @{
            # Turns the rule on
            Enable         = $true

            # Lists the PowerShell platforms we want to check compatibility with
            TargetProfiles = @(
                'win-8_x64_10.0.14393.0_6.1.3_x64_4.0.30319.42000_core',
                'win-8_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework',
                'win-8_x64_6.2.9200.0_3.0_x64_4.0.30319.42000_framework'
            )
        }

        PSUseCompatibleSyntax      = @{
            # This turns the rule on (setting it to false will turn it off)
            Enable         = $true

            # Simply list the targeted versions of PowerShell here
            TargetVersions = @(
                '2.0',
                '3.0',
                '4.0',
                '5.0',
                '6.0'
            )
        }
    }
}