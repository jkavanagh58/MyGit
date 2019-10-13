Function Test-parametercall {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$False, ValueFromPipeline=$True,
                HelpMessage = "Test parameter")]
        [System.String]$notonStop,
        [parameter(Mandatory=$True, ValueFromPipeline=$True,
                HelpMessage = "From Code")]
        [ValidateSet("Start","Extend","Stop")]
        [System.String]$MMStartStop
    )
    dynamicparam
    {
        If ($MMStartStop -ne "Stop") {
            #create a new ParameterAttribute Object
            $mmtimeAttribute = New-Object System.ManmmTimement.Automation.ParameterAttribute
            $mmTimeAttribute.Mandatory = $True
            # This attribute HelpMessage failing to register
            $mmTimeAttribute.HelpMessage = "You must specify the time, in minutes for the maintenance window"
            #create an attributecollection object for the attribute we just created.
            $attributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            #add our custom attribute
            $attributeCollection.Add($mmTimeAttribute)
            #add our paramater specifying the attribute collection
            $mmTimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('mmTime', [Int32], $attributeCollection)
            #expose the name of our parameter
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('mmTime', $mmTimeParam)
            return $paramDictionary
        }
    }
}