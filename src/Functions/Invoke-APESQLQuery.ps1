Function Invoke-APESQLQuery {
    Param(
        [string]$Query,
        [hashtable]$QueryParams = @{}
    )
    $SQLConnectionString = "Server=$($Script:APESettings.SQLServer);Database=$($Script:APESettings.DatabaseName);Integrated Security=True"
    $SQLConnection = New-Object System.Data.SqlClient.SQLConnection($SQLConnectionString)
    $SqlCommand = new-object system.data.sqlclient.sqlcommand($Query,$SQLConnection)

    if($QueryParams) {
        foreach($key in $QueryParams.Keys){
            [void]$SqlCommand.Parameters.AddWithValue("$Key", $QueryParams."$key")
        }
    }

    $SQLConnection.Open()
    
    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $SqlCommand
    $dataset = New-Object System.Data.DataSet
    [void]$adapter.Fill($dataSet)
    $SQLConnection.Close()
    $dataSet.Tables
}