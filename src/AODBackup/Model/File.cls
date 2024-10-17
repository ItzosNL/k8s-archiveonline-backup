/// File information
Class AODBackup.Model.File Extends (%SerialObject, %XML.Adaptor, %JSON.Adaptor)
{

/// Name
Property Name As %String(%JSONFIELDNAME = "name", MAXLEN = "");

/// Size
Property Size As %Integer(%JSONFIELDNAME = "size");

/// Last Modified (ISO)
Property LastModified As %String(%JSONFIELDNAME = "lastModified");

Storage Default
{
<Data name="FileState">
<Value name="1">
<Value>Name</Value>
</Value>
<Value name="2">
<Value>Size</Value>
</Value>
<Value name="3">
<Value>LastModified</Value>
</Value>
</Data>
<State>FileState</State>
<StreamLocation>^AODBackup.Model.FileS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
