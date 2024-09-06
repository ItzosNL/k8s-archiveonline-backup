Include %occErrors

/// Extended version of %SYS.Task.BackupCumulativeDatabaseList
/// It copies the created file to a ArchivingOnDemand bucket
Class AODBackup.TaskHelper
{

/// ProcessBackupTaskResults
ClassMethod ProcessBackupTaskResults(task As %SYS.Task.Definition, sc As %Status, start As %String, end As %String) As %Status
{
    if $$$ISOK(sc)
    {
        #dim record As AODBackup.History = ##class(AODBackup.History).GetLatestBackup()

        set ^AAADebug = {
            "start": ($ZDATETIME(start, 3, 1)),
            "end": ($ZDATETIME(end, 3, 1)),
            "datetime": (record.DateTime),
            "type": (record.Type),
            "status": (record.Status),
            "log": (record.LogFile),
            "backupFile": (record.BackupFile)
        }.%ToJSON()

        // Write the Backup Logfile to stdout it will be attached to the email sent by the TaskManager
        // For some reason reading the logfile keeps returning an <ENDOFFILE> error
        // That is possibly caused by the file not yet being closed by the backup Task?
        #; do ..CopyFileToStdout(record.LogFile)

        write "These are the fields of the current Task:",!
        zw task
        write !

        W $TEST

        if record.Status '= "Completed"
        {
            return $$$ERROR($$$GeneralError, "Backup finished with Status " _ record.Status _ ", please check LogFile " _ record.LogFile)
        }
    }

	return sc
}

/// Copy File to stdout
ClassMethod CopyFileToStdout(filepath As %String) As %Status
{
    set fs = ##class(%Stream.FileCharacter).%New()
    set fs.Filename = filepath
    do fs.Rewind()

    while 'fs.AtEnd    
    {
        write fs.ReadLine(, .sc),!
    }

    return $$$OK
}

}
