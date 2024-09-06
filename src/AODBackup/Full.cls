/// Extended version of %SYS.Task.BackupCumulativeDatabaseList
/// It copies the created file to a ArchivingOnDemand bucket
Class AODBackup.Full Extends %SYS.Task.BackupFullDatabaseList
{

/// Overwrite of OnTask method to add additonal logic
Method OnTask() As %Status
{
    set namespace = $NAMESPACE
    new $NAMESPACE
    set start = $HOROLOG
	set sc = ##super() // Does switch permanently to the %SYS namespace
    set end = $HOROLOG
    set $NAMESPACE = namespace // Switch back!

    return ##class(AODBackup.TaskHelper).ProcessBackupTaskResults($this, sc, start, end)
}

}
