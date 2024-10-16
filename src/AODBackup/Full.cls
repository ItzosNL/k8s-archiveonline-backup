/// Extended version of %SYS.Task.BackupCumulativeDatabaseList
/// It copies the created file to a ArchivingOnDemand bucket
Class AODBackup.Full Extends %SYS.Task.BackupFullDatabaseList
{

/// Overwrite of OnTask method to add additonal logic
Method OnTask() As %Status
{
    set OldIO = $IO
    set OldMnemonic = ##class(%Library.Device).GetMnemonicRoutine()
    set OldState = ##class(%Library.Device).ReDirectIO()
    set namespace = $NAMESPACE
    new $NAMESPACE
    set start = $HOROLOG
	set sc = ##super() // Does switch permanently to the %SYS namespace and redirects IO to the backup log file!
    set end = $HOROLOG
    set $NAMESPACE = namespace // Switch back!

    // Switching back IO redirection:
    if OldMnemonic '= ""
    {
        use OldIO::("^" _ OldMnemonic)
    }
    else
    {
        use OldIO
    }

    do ##class(%Library.Device).ReDirectIO(OldState)

    return ##class(AODBackup.TaskHelper).ProcessBackupTaskResults(sc, start)
}

}
