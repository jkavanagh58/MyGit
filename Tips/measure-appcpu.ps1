# One-liner to compare CPU usage for two applications for commparison
get-process -Name Teams, Slack | Group-Object -Property Name |
Select-Object Name, @{
						Name='CPU'; expression={$_.Group.CPU}
