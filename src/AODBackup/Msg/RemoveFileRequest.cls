/// Remove File Request
Class AODBackup.Msg.RemoveFileRequest Extends Ens.Request
{

/// Filename 
Property FileName As %String;

Storage Default
{
<Data name="RemoveFileRequestDefaultData">
<Subscript>"RemoveFileRequest"</Subscript>
<Value name="1">
<Value>FileName</Value>
</Value>
</Data>
<DefaultData>RemoveFileRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
