/// Move backup files to- and from Archiving on Demand S3 Buckets
Class AODBackup.BucketTransfer
{

/// Move the backup file that was just created to ArchivingOnDemand
ClassMethod UploadBackup() As %Status
{
    set sc = $$$OK

    return sc
}

}
