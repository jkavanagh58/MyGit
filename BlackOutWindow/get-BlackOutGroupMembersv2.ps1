#	09.11.2017 JJK:	Use dynamic parameter to select group name at runtime
#	09.11.2017 JJK: TODO: Work with parameter and quotes necessary
[CmdletBinding()]
Param(

)
DynamicParam {
	$ParameterName = 'scomGroups'
	$RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
	$AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
	$ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
	$ParameterAttribute.Mandatory = $true
	$ParameterAttribute.Position = 1
	$AttributeCollection.Add($ParameterAttribute)
	$arrSet = (get-scomgroup -DisplayName "WFM - Windows-Svr-MW - Production - *").DisplayName
	$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

	# Add the ValidateSet to the attributes collection
	$AttributeCollection.Add($ValidateSetAttribute)

	# Create and return the dynamic parameter
	$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
	$RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
	return $RuntimeParameterDictionary
}
Begin{
	[String]$scomGroups = $PSBoundParameters[$ParameterName]
}
Process {
	(get-scomgroup -DisplayName $scomGroups).GetRelatedMonitoringObjects()
}