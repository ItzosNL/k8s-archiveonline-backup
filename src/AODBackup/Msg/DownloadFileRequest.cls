/// Get File Request
Class AODBackup.Msg.DownloadFileRequest Extends Ens.Request
{

/// Filename 
Property FileName As %String;

Storage Default
{
<Data name="DownloadFileRequestDefaultData">
<Subscript>"DownloadFileRequest"</Subscript>
<Value name="1">
<Value>FileName</Value>
</Value>
</Data>
<DefaultData>DownloadFileRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
