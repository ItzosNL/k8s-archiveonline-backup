/// Rename File Request
Class AODBackup.Msg.RenameFileRequest Extends Ens.Request
{

/// Current Filename 
Property CurrentFileName As %String;

/// New Filename (optional, if you want to rename) 
Property NewFileName As %String;

/// filepath 
Property FilePath As %String;

Storage Default
{
<Data name="RenameFileRequestDefaultData">
<Subscript>"RenameFileRequest"</Subscript>
<Value name="1">
<Value>CurrentFileName</Value>
</Value>
<Value name="2">
<Value>NewFileName</Value>
</Value>
<Value name="3">
<Value>FilePath</Value>
</Value>
</Data>
<DefaultData>RenameFileRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
