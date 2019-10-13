Function get-clusterownerlist {
#Requres -Modules FailoverClusters
<#
	.SYNOPSIS
		List domain clusters and lists Cluster Resource and the OwnerNode
	.DESCRIPTION
		List domain clusters and lists Cluster Resource and the OwnerNode
	.EXAMPLE
		I ♥ PS # get-clusterowner
	.NOTES
		===========================================================================
			Created with:	Visual Studio Code
			Created on:		09.26.2017
			Created by:		John Kavanagh
			Organization:	TekSystems
		===========================================================================
		09.26.2017 JJK:	Needs to be run with domain admin credentials.
		09.26.2017 JJK:	Designed to be a function in a server powershell profile.
		09.26.2017 JJK:	TODO: Add variable for searching through ownernode.
#>
	$domainClusters = FailoverClusters\Get-Cluster -Domain wfm.wegmans.com | sort-object -Property Name
		ForEach ($cluster in $domainClusters){
			$clusterInfo = failoverclusters\get-cluster -Name $cluster.Name -ErrorAction SilentlyContinue |
				failoverclusters\get-clustergroup
			$clusterInfo | select-Object -Property  Cluster, Name, OwnerNode
		}
}