Describe 'Domain Controllers' {
	Context 'Replication Link Status' {
		$results = repadmin /showrepl * /csv | ConvertFrom-Csv # Get the results of all replications between all DCs
		$groups = $results | Group-Object -Property 'Source DSA' # Group the results by the source DC
		foreach ($sourcedsa in $groups) {
			# Create a context for each source DC
			Context "Source DSA = $($sourcedsa.Name)" {
				$targets = $sourcedsa.Group # Assign the value of the groupings to another var since .Group doesn't implement IComparable
				$targetdsa = $targets | Group-Object -Property 'Destination DSA' # Now group within this source DC by the destination DC (pulling naming contexts per source and destination together)
				foreach ($target in $targetdsa ) {
					# Create a context for each destination DSA
					Context "Target DSA = $($target.Name)" {
						foreach ($entry in $target.Group) {
							# List out the results and check each naming context for failures
							It "$($entry.'Naming Context') - should have zero replication failures" {
								$entry.'Number of failures' | Should Be 0
							}
						}
					}
				}
			}
		}
	}
}