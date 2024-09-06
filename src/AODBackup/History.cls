/// Get the Backup History going back to the last full backup
Class AODBackup.History Extends (%SerialObject, %JSON.Adaptor)
{

/// When was this backup created
/// Formatted using $ZDATETIME(3,1), e.g. 2024-09-06 06:16:39
Property DateTime As %String;

/// TYPE=Cumulative Incremental
/// Type of backup which will be performed.
/// VALUELIST = "/Full/Incremental/Cumulative Incremental"
Property Type As %String;

/// STATUS=Completed
/// Status of the backup (Completed, Warning)
Property Status As %String;

/// LOG=/irissys/data/IRIS/mgr/Backup/CumuIncrDBList_20240905_001.log
/// LogFile that was created, usefull when the Srarus is '= Completed
Property LogFile As %String(MAXLEN = "");

/// DEVICE=/irissys/backups/CumuIncrDBList_20240905_001.cbk
/// Backup File that was created
Property BackupFile As %String(MAXLEN = "");

/// JOURNAL=/irissys/journal1/20240905.001
/// Journal file that was used as the basis for the backup
Property JournalFile As %String(MAXLEN = "");

/// LIST=List
/// which database(s) are in this backup?
/// Value "List" referes to the list that can be retrieved via ##class(AODBackup.DBList).Get()
Property List As %String(MAXLEN = "");

/// WIJINFO=4318488,/irissys/journal1/20240905.001,30,30,4277932,65794,4318004,30
/// Write Image Journal Information
Property WIJInformation As %String(MAXLEN = "");

/// Get the Latest Full backup
/// A part of that information can also be fetched via ##class(Backup.General).GetLastFullBackupInfo()
/// However, that returns an incomplete set of information, hence we have re-implemented it based on the more detailed information available from the registry
ClassMethod GetLatestFullBackup() As AODBackup.History
{
    #dim record As AODBackup.History = ..GetLatestBackup(.qhandle)

    while $ISOBJECT(record) && (record.Type '= "Full")
    {
        set record = ..GetPreviousBackup(.qhandle)
    }

    return record
}

/// Show all backups based on ^SYS("BUHISTORY")
/// This in order to:
/// - Include the backup file name
/// - Include a proper date time
ClassMethod ShowAll()
{
    #dim record As AODBackup.History = ..GetLatestBackup(.qhandle)

    while record '= ""
    {
        w "Backup at ",record.DateTime,": ",record.Type,",",record.BackupFile,",",record.Status,!

        set record = ..GetPreviousBackup(.qhandle)
    }
}

/// Get the Latesst backup, used right after that backup has run to know the name of backup file that was created.
ClassMethod GetLatestBackup(ByRef qhandle As %String) As AODBackup.History
{
	new $Namespace
	set $Namespace = "%SYS"
    set t = $ORDER(^SYS("BUHISTORY",0))

    while t '= ""
    {
        set qhandle = t
        set t = $ORDER(^SYS("BUHISTORY",0,"LOGNOTPURGED",t))
    }

    return ..FetchProperties(qhandle)
}

/// Get Previous Backup basd on the QHandle
ClassMethod GetPreviousBackup(ByRef qhandle As %String) As AODBackup.History
{
	new $Namespace
	set $Namespace = "%SYS"
    set qhandle = $ORDER(^SYS("BUHISTORY",0,"LOGNOTPURGED", qhandle), -1)

    return ..FetchProperties(qhandle)
}

/// Fetch a single Backup History record from the regstry
ClassMethod FetchProperties(qhandle As %String) As AODBackup.History
{
    if (qhandle = "")
    {
        return ""
    }

    set record = ..%New()

    // qhandle has a $H value in which the comma has been replaced wuth a 0-digit.
    // e.g. 67081024900 ==> 67081,24900
    set record.DateTime = $ZDATETIME($EXTRACT(qhandle,1,5) _ "," _ $EXTRACT(qhandle,7,11), 3, 1)

    // DESC=Cumulative and Incremental backup of all databases that are in the backup database list.
    // DEVICE=/irissys/backups/CumuIncrDBList_20240905_001.cbk
    // JOURNAL=/irissys/journal1/20240905.001
    // LIST=List
    // LOG=/irissys/data/IRIS/mgr/Backup/CumuIncrDBList_20240905_001.log
    // STATUS=Completed
    // TYPE=Cumulative Incremental
    // WIJINFO=4318488,/irissys/journal1/20240905.001,30,30,4277932,65794,4318004,30

    set record.Type = ^SYS("BUHISTORY", qhandle, "TYPE")
    set record.Status = ^SYS("BUHISTORY", qhandle, "STATUS")
    set record.LogFile = ^SYS("BUHISTORY", qhandle, "LOG")
    set record.BackupFile = ^SYS("BUHISTORY", qhandle, "DEVICE")
    set record.JournalFile = ^SYS("BUHISTORY", qhandle, "JOURNAL")
    set record.List = ^SYS("BUHISTORY", qhandle, "LIST")
    set record.WIJInformation = ^SYS("BUHISTORY", qhandle, "WIJINFO")

    return record
}

/// Show all backups based on Custom Class query History
/// The output is identical to http://xxx/csp/sys/op/UtilSysBackupLogs.csp?Recent=1
/// Unfortunately, the backup file itself is not listed in the output
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

Storage Default
{
<Data name="HistoryState">
<Value name="1">
<Value>DateTime</Value>
</Value>
<Value name="2">
<Value>Type</Value>
</Value>
<Value name="3">
<Value>Status</Value>
</Value>
<Value name="4">
<Value>BackupFile</Value>
</Value>
<Value name="5">
<Value>JournalFile</Value>
</Value>
<Value name="6">
<Value>List</Value>
</Value>
<Value name="7">
<Value>LogFile</Value>
</Value>
<Value name="8">
<Value>WIJInformation</Value>
</Value>
</Data>
<State>HistoryState</State>
<StreamLocation>^AODBackup.HistoryS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
