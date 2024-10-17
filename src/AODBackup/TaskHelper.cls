Include Ensemble

/// Extended version of %SYS.Task.BackupCumulativeDatabaseList
/// It copies the created file to a ArchivingOnDemand bucket
Class AODBackup.TaskHelper
{

/// ProcessBackupTaskResults
ClassMethod ProcessBackupTaskResults(sc As %Status, start As %String) As %Status
{
    if $$$ISOK(sc)
    {
        #dim backup As AODBackup.History = ##class(AODBackup.History).GetLatestBackup()

        set ^AAADebug = {
            "datetime": (backup.DateTime),
            "type": (backup.Type),
            "status": (backup.Status),
            "log": (backup.LogFile),
            "backupFile": (backup.BackupFile)
        }.%ToJSON()

        // Send the file to ArchiveOnDemand
        set sc = ##class(AODBackup.BS.UploadService).UploadFile(backup.BackupFile)

        if $$$ISERR(sc)
        {
            $$$TRACE("Upload of backup file " _ backup.BackupFile _ " failed: " _ $SYSTEM.Status.GetErrorText(sc))
            return sc
        }

        if backup.Status '= "Completed"
        {
            set sc = $$$ERROR($$$GeneralError, "Backup finished with Status " _ backup.Status _ ", please check attached logFile.")
        }

        do ..CopyFileToStdout(backup.LogFile)
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
