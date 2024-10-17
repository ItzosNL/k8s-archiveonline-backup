/// ArchiveOnlie List Directory Response
Class AODBackup.Msg.ListDirectoryResponse Extends (Ens.Response, %JSON.Adaptor)
{

/// Configured Folder 
Property Folder As %String;

/// Search Results
Property Files As list Of AODBackup.Model.File;

Storage Default
{
<Data name="ListDirectoryResponseDefaultData">
<Subscript>"ListDirectoryResponse"</Subscript>
<Value name="1">
<Value>Folder</Value>
</Value>
<Value name="2">
<Value>Files</Value>
</Value>
</Data>
<DefaultData>ListDirectoryResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
