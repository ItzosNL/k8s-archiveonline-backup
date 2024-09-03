Include %occErrors

/// Restore backups from ArchivingOnDemand
Class AODBackup.Restore
{

/// Restore based on https://openexchange.intersystems.com/package/backupChecker
/// TBD: Make work with our local paths
ClassMethod RestoreAll(backupFile) As %Status [ PublicList = (INPDEV, TopDir, RESTYPE, QUIETMODE, ALLOWUPD, JRNOPT) ]
{
    set INPDEV = "/ISC/utiles/Backup/" _ backupFile

    if '##class(%File).Exists(INPDEV)
    {
        do ..LogToConsole("The backup file " _ INPDEV _ " does not exists. Please make sure there is a backup file in the /Backup directory called " _ backupFile)
        return $$$ERROR($$$FileNotFound, "File " _ INPDEV _ " not found!")
    }

    do ..LogToConsole("Starting to restore the Backup... It will take some time, be patient!")

    set TopDir = "/ISC/utiles/Restore/"
    set RESTYPE = "ALL"
    set QUIETMODE = 1,ALLOWUPD = 0,JRNOPT = 4 
    do BEGIN^DBREST

    do ..LogToConsole("Restored completed!")
    do ..LogToConsole("Starting the Integrity report")

    // do the integrity Check
    // do Silent^Integrity("/ISC/utiles/Restore/integrity.log")
    set sc = $$CheckList^Integrity(,,,,10)
    do Display^Integrity(, 2, 1)

    if $system.Status.IsOK(sc)
    {
        do ..LogToConsole("Run successfully and found NO errors! Databases are VALIDATED!")  
    }
    elseif ($system.Status.GetErrorCodes(sc) = $$$ERRORCODE($$$IntegrityCheckErrors))
    {
        do ..LogToConsole("Run successfully, but found ERRORS!!!!. Review the log for details!")     
    }
    else
    {
        do ..LogToConsole(" Error executing the Integrity checker. Error: " _ $system.Status.GetErrorCodes(sc))        
    }

    return $$$OK
}

/// Description
ClassMethod LogToConsole(message)
{
  // Write to the current device
  write !,message

  // Write to the messages.log
  do ##class(%SYS.System).WriteToConsoleLog("**************************************************************************************************")
  do ##class(%SYS.System).WriteToConsoleLog("*** BackupChecker:" _ message _ " ***")
  do ##class(%SYS.System).WriteToConsoleLog("***************************************************************************************************")
}

}
