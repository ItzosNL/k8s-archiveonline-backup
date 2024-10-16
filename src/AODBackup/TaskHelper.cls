Include %occErrors

/// Extended version of %SYS.Task.BackupCumulativeDatabaseList
/// It copies the created file to a ArchivingOnDemand bucket
Class AODBackup.TaskHelper
{

/// ProcessBackupTaskResults
ClassMethod ProcessBackupTaskResults(sc As %Status, start As %String) As %Status
{
    if $$$ISOK(sc)
    {
        #dim record As AODBackup.History = ##class(AODBackup.History).GetLatestBackup()

        set ^AAADebug = {
            "datetime": (record.DateTime),
            "type": (record.Type),
            "status": (record.Status),
            "log": (record.LogFile),
            "backupFile": (record.BackupFile)
        }.%ToJSON()

        if record.Status '= "Completed"
        {
            set sc = $$$ERROR($$$GeneralError, "Backup finished with Status " _ record.Status _ ", please check attached logFile.")
        }

        do ..CopyFileToStdout(record.LogFile)
    }

	return sc
}

/// Copy File to stdout
ClassMethod CopyFileToStdout(filepath As %String) As %Status
{
    set $ZTRAP = ""
    try
    {
        Hang 2 // Wait for the file to become readable

        set fs = ##class(%Stream.FileCharacter).%New()
        set fs.Filename = filepath
        do fs.Rewind()

        while 'fs.AtEnd    
        {
            write fs.ReadLine(, .sc),!
        }

        do fs.Rewind()
    }
    catch ex
    {
        set $ZERROR = ""
        // Ignore exception
    }

    write !

    return $$$OK
}

}
