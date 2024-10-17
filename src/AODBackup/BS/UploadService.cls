/// Upload Service for the backups
Class AODBackup.BS.UploadService Extends Ens.BusinessService
{

/// Service name
Parameter ServiceName = "UploadService";

Parameter SETTINGS = "ArchivingOnDemand:Targets";

Property ArchivingOnDemand As Ens.DataType.ConfigName [ InitialExpression = "ArchivingOnDemand" ];

/// This method is called from 
Method OnProcessInput(pInput As AODBackup.Msg.UploadFileRequest, Output pOutput As Ens.Response) As %Status
{
	set tSC = $$$OK

	try
	{
		set tSC = ..SendRequestSync(..ArchivingOnDemand, pInput, .pOutput)
	}
	catch ex 
	{
		set tSC = ex.AsStatus()
	}

	return tSC
}

/// Upload the specified file
ClassMethod UploadFile(filename As %String) As %Status
{
	set sc = $$$OK
    try
	{
		#dim tService as AODBackup.BS.UploadService

		$$$ThrowOnError(##class(Ens.Director).CreateBusinessService(..#ServiceName, .tService))

		set request = ##class(AODBackup.Msg.UploadFileRequest).%New()
		set request.OriginalFilename = filename

		set sc = tService.ProcessInput(request, .response)
	}
	catch (ex)
	{
	    set sc = ex.AsStatus()
	}

    return sc
}

}
