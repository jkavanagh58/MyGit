# 10.23.2017 JJK: Using provided code and loading as function
# 11.08.2017 JJK: Need values for production
# 11.08.2017 JJK: Added prod server/instance information
# 11.08.2017 JJK: TODO: Get rid of SQLInjection risk with concat Query variable and use StringBuilder
Function write-automationrec {
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$True,
		ValueFromPipeline=$True,
		ValueFromPipelineByPropertyName=$True)]
	[string]$computername,
	[Parameter(Mandatory=$True,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
	[string]$jobtype,
	[Parameter(Mandatory=$True,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
	[string]$app,
	[Parameter(Mandatory=$True,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
	[string]$joblocation,
	[Parameter(Mandatory=$True,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
	[decimal]$jobDuration,
	[Parameter(Mandatory=$True,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
	[decimal]$jobReturnCode,
	[Parameter(Mandatory=$false,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "Write this entry to the production database")]
	[Switch]$Prod
)
$ReturnText = ''; [int]$ReturnCode = 0
If ($Prod){
	"Writing Production database"
	$runServer = "SQLServer"
	$thissqlInstance = "SQLInstance"
}
Else {
	$runServer = "TestSQLServer"
	$thissqlInstance = "TSTSQLInstance"
}
$ReturnCode = Invoke-Command -ComputerName $runServer -ScriptBlock {
	param( $computername, $jobtype, $app, $joblocation, $jobDuration, $jobReturnCode)
	try {
		$SQLInstance = $thissqlInstance
		#        }
		$Database = 'AutomationLog'; $ServerPatchRecordsTable = 'PatchAutomationLogging'; $ConnectionTimeout = 30; $QueryTimeout = 120
		$ConnectionString = "Server=$SQLInstance; Database=$Database; Integrated Security=SSPI; Connect Timeout = $ConnectionTimeout"
		# Create the Server Patch Record
		$Query  = "declare @jobtypeName varchar(max)  "
		$Query += "set @jobtypeName = '$jobtype' "

		$Query += "if exists (select * from jobType where jobtype like @jobtypeName)  "
		$Query += "begin "
		$Query += "declare @recid int "
		$Query += "select @recid = (select RecordID from jobType where jobtype like @jobtypeName) "
		$Query += "	insert into entryLog (jobTypeNum,execDateTime,specialAttribute,execDuration,RC) values (@recid,getdate(),'$computername',$jobDuration,$jobReturnCode) "
		$Query += "end "
		$Query += "else begin "
		$Query += "	insert into jobType (sourceSystem,jobType,jobLocation,estimateTimeMinutes,estimateCostDollars) values ('$app',@jobtypeName,'$joblocation','10','90.00') "
		$Query += "	select @recid = (select scope_identity()) "
		$Query += "	insert into entryLog (jobTypeNum,execDateTime,specialAttribute,execDuration,RC) values (@recid,getdate(),'$computername',$jobDuration,$jobReturnCode) "
		$Query += "end "

		# Connect to SQL and create the record
		$conn = New-Object System.Data.SqlClient.SQLConnection
		$conn.ConnectionString = $ConnectionString
		$conn.open()
		$cmd = New-Object System.Data.SqlClient.SqlCommand($Query,$conn)
		$cmd.CommandTimeout = $QueryTimeout
		$RowCount1 = $cmd.executenonquery()
		$conn.close()

		# Verify ServerPatchRecord created
		if ($RowCount1 -lt 1) {
			$ReturnText = "The Record for $Query was not created in the $ServerPatchRecordsTable table --"
			$ReturnCode = 1
		} else {
			$ReturnCode = 0
		}
		return $ReturnCode
	}
	catch [System.Exception] {
		$ReturnText = $_.Exception.Message
		$ReturnCode = 1
		return $ReturnCode
	}
} -ArgumentList $computername,$jobtype, $app, $joblocation, $jobDuration, $jobReturnCode -ErrorVariable ERRText

if ($ERRText) {
	$ReturnCode = 77
}
} # End Function
