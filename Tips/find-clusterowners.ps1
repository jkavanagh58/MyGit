FailoverClusters\Get-Cluster -Domain wfm.wegmans.com |
	%{failoverclusters\get-cluster -Name $_.Name -ea 0 |
		failoverclusters\get-clustergroup  |
		select-Object -Property  Cluster, Name, OwnerNode
	}