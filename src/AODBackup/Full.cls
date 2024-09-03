/// Extended version of %SYS.Task.BackupCumulativeDatabaseList
/// It copies the created file to a ArchivingOnDemand bucket
Class AODBackup.Full Extends %SYS.Task.BackupFullDatabaseList
{

/// This method is responsible for executing the task.<br>
/// At the scheduled time, the Task Manager creates an instance of this object,
/// sets any property values using the stored "settings" for the task, and then
/// invokes this method to execute the task.<br>
/// In order to execute a real task, override this method in a subclass.
Method OnTask() As %Status
{
	set sc = ##super()

    if $$$ISOK(sc)
    {
        // Move the created file to the ArchivingOnDemand bucket
        set sc = ##class(AODBackup.BucketTransfer).UploadBackup()
    }

	return sc
}

}
