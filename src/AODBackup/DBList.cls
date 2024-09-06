/// Get and update the list of databases set up for the Backup Task 
Class AODBackup.DBList
{

/// Get the list of databases set up for backup
/// ^SYS("BACKUPDB","ALTRECHT_DATA") = ""
/// ^SYS("BACKUPDB","USER")	= ""
ClassMethod Get() As %ListOfDataTypes
{
	new $Namespace
	set $Namespace = "%SYS"

    set list = ##class(%ListOfDataTypes).%New()
    set db = ""

    while 1
    {
        set db = $ORDER(^SYS("BACKUPDB", db))

        if (db = "")
        {
            quit
        }

        do list.Insert(db)
    }

    return list
}

/// Set database list from DynamicArray
ClassMethod SetFromDynamicArray(databases As %DynamicArray)
{
	new $Namespace
	set $Namespace = "%SYS"

	do ##class(Backup.General).ClearDatabaseList()

	for index = 0:1:databases.%Size() - 1
	{
		set database = databases.%Get(index)
		set sc = ##class(Backup.General).AddDatabaseToList(database)
	
		if $$$ISERR(sc)
		{
			write "Failed to add database '",database,"' to the backup list: ",$SYSTEM.Status.GetErrorText(sc),!
		}
		else
		{
			write "Database '",database,"' has been added to the backup list",!
		}
	}
}

}
