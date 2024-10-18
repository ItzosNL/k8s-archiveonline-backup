/// Compress the file using GZIP
Class AODBackup.BP.GZip Extends Ens.BusinessProcess [ ClassType = persistent ]
{

Parameter SETTINGS = "ArchivingOnDemand:Targets";

Property ArchivingOnDemand As Ens.DataType.ConfigName [ InitialExpression = "ArchivingOnDemand" ];

/// entry point
Method OnRequest(pRequest As AODBackup.Msg.UploadFileRequest, Output pResponse As Ens.Response) As %Status
{
	#dim sc As %Status = $$$OK

	try
	{
		set retValue = $ZF(-100, "", "gzip", pRequest.OriginalFilename)

		if (retValue '= 0) // Shell returned an error
		{
			$$$ThrowOnError($$$ERROR($$$GeneralError, "gzip returned a non-success status value of " _ retValue))
		}

		#dim request As AODBackup.Msg.UploadFileRequest = ##class(AODBackup.Msg.UploadFileRequest).%New()

		set request.OriginalFilename = pRequest.OriginalFilename _ ".gz"

		return ..SendRequestSync(..ArchivingOnDemand, request, .pResponse)
	}
	catch ex
	{
		set sc = ex.AsStatus()

		$$$LOGERROR("Fout tijdens uitvoeren van " _ $CLASSNAME() _ ": " _ $System.Status.GetErrorText(sc))
	}

	return sc
}

Storage Default
{
<Data name="GZipDefaultData">
<Subscript>"GZip"</Subscript>
<Value name="1">
<Value>ArchivingOnDemand</Value>
</Value>
</Data>
<DefaultData>GZipDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
