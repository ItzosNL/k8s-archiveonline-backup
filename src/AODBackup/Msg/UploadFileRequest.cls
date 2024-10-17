/// Get File Request
Class AODBackup.Msg.UploadFileRequest Extends Ens.Request
{

/// OriginalFilename
Property OriginalFilename As %String(MAXLEN = "");

Storage Default
{
<Data name="UploadFileRequestDefaultData">
<Subscript>"UploadFileRequest"</Subscript>
<Value name="1">
<Value>OriginalFilename</Value>
</Value>
</Data>
<DefaultData>UploadFileRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
