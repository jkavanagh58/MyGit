# You need the SQL Snapin 
if (!(get-pssnapin SqlServerProviderSnapin100 -ErrorAction SilentlyContinue)){add-pssnapin SqlServerProviderSnapin100}
if (!(get-pssnapin SqlServerCmdletSnapin100 -ErrorAction SilentlyContinue)){add-pssnapin SqlServerCmdletSnapin100}
# Determine current ACS data retention
invoke-sqlcmd "USE OperationsManagerAC; SELECT * FROM dtConfig;" -ServerInstance "mn1sql04\mn1sql04"