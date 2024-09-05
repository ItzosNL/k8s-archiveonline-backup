/// Get the Backup History going back to the last full backup
Class AODBackup.History Extends %RegisteredObject
{

/// Description
ClassMethod GetLastFullBackupInfo()
{
    Write "Full backup: ", $LISTTOSTRING(##class(Backup.General).GetLastFullBackupInfo()),!
}

/// Show all backups based on ^SYS("BUHISTORY")
/// This in order to:
/// - Include the backup file name
/// - Include a proper date time
ClassMethod ShowAll()
{
    // Find last T
    set t = $ORDER(^SYS("BUHISTORY",0))

    while t '= ""
    {
        set lastt = t
        set t = $ORDER(^SYS("BUHISTORY",0,"LOGNOTPURGED",t))
    }

    set t = lastt // from last t iterate backwards
    while t '= ""
    {
        // 67081024900
        // 12345,7891011
        set datetime = $ZDATETIME($EXTRACT(t,1,5) _ "," _ $EXTRACT(t,7,11), 3, 5)

        // Complete=1 ==> 1: Completed, 2: Warning
        // DESC=Cumulative and Incremental backup of all databases that are in the backup database list.
        // DEVICE=/irissys/backups/CumuIncrDBList_20240905_001.cbk
        // JOURNAL=/irissys/journal1/20240905.001
        // LIST=List
        // LOG=/irissys/data/IRIS/mgr/Backup/CumuIncrDBList_20240905_001.log
        // STATUS=Completed
        // TYPE=Cumulative Incremental
        // WIJINFO=4318488,/irissys/journal1/20240905.001,30,30,4277932,65794,4318004,30

        #; set array = ##class(%ArrayOfDataTypes).%New()
        #; set key = $ORDER(^SYS("BUHISTORY", t, ""))
        #; while key '= ""
        #; {
        #;     do array.SetAt(^SYS("BUHISTORY", t, key), key)
        #;     set key = $ORDER(^SYS("BUHISTORY", t, key))
        #; }

        w "Backup at ",datetime,": ",^SYS("BUHISTORY", t, "TYPE"),",",^SYS("BUHISTORY", t, "DEVICE"),",",^SYS("BUHISTORY", t, "STATUS"),!

        set t = $ORDER(^SYS("BUHISTORY",0,"LOGNOTPURGED",t), -1)
    }
}

/// Show all backups based on Custom Class query History
/// The output is identical to http://xxx/csp/sys/op/UtilSysBackupLogs.csp?Recent=1
/// Unfortinatelym the backup file itself is not listed in the output
ClassMethod ShowAllOld()
{
    set sc = ##class(Backup.Task).HistoryExecute(.qhandle)

    if $$$ISERR(sc)
    {
        write "Error ",$SYSTEM.Status.GetErrorText(sc),!
        return
    }


    while 1
    {
        set sc = ##class(Backup.Task).HistoryFetch(.qhandle, .row, .atEnd)

        if $$$ISERR(sc)
        {
            write "Error ",$SYSTEM.Status.GetErrorText(sc),!
            return
        }

        if (atEnd)
        {
            return
        }

        Write $LTS(row),!
    }
}

}
