/// Custom S3 Operation for ArchivingOndemand
Class AODBackup.BO.ArchivingOnDemand Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

/// Name of file to output the document(s) to. May include timestamp specifiers. The %f specifier if present will be 
/// replaced with the name of the document's original source filename (stripped of characters illegal in target filenames).<p>
/// Needs to be %f except for the Archive BO, where it must be "%f_%Q" to create unique filenames
/// See the method Ens.Util.File.CreateTimestamp() for documentation of timestamping options.
Property Filename As %String(MAXLEN = 1000, MINLEN = 1) [ InitialExpression = "%f", Required ];

/// EndpointURL
Property EndpointURL As %String(MAXLEN = 100) [ InitialExpression = "https://hs3-265.shcp03.archivingondemand.nl" ];

/// Bucketname
Property BucketName As %String(MAXLEN = 100) [ InitialExpression = "ehealth-mkls" ];

/// Path Prefix - must must end with /!
Property Prefix As %String(MAXLEN = 100);

/// AWS_ACCESS_KEY_ID
Property AwsAccessKey As %String(MAXLEN = 100);

/// AWS_SECRET_ACCESS_KEY
Property AwsSecretKey As %String(MAXLEN = 100);

Parameter SETTINGS = "Filename:Basic,EndpointURL:S3,BucketName:S3,Prefix:S3,AwsAccessKey:S3,AwsSecretKey:S3";

XData MessageMap
{
<MapItems>
  <MapItem MessageType="Ens.StreamContainer">
    <Method>UploadFileFromStream</Method>
  </MapItem>
  <MapItem MessageType="AODBackup.Msg.UploadFileRequest">
    <Method>UploadFileFromFilesystem</Method>
  </MapItem>
  <MapItem MessageType="AODBackup.Msg.ListDirectoryRequest">
    <Method>ListDirectory</Method>
  </MapItem>
  <MapItem MessageType="AODBackup.Msg.DownloadFileRequest">
    <Method>DownloadFile</Method>
  </MapItem>
  <MapItem MessageType="AODBackup.Msg.RenameFileRequest">
    <Method>RenameFile</Method>
  </MapItem>
  <MapItem MessageType="AODBackup.Msg.RemoveFileRequest">
    <Method>RemoveFile</Method>
  </MapItem>
</MapItems>
}

/// Upload file from request stream to S3
Method UploadFileFromStream(pRequest As Ens.StreamContainer, Output pResponse As Ens.Response) As %Status
{
	set sc = $$$OK

	try
    {
        set tFilename = ##class(Ens.Util.Time).FormatDateTime(..Filename, pRequest.OriginalFilename) 
        do ..UploadFileHelper(tFilename, pRequest.Stream)
	}
	catch (ex)
    {
		set sc = ex.AsStatus()
	}

	return sc
}

/// Upload file from filesystem to S3
Method UploadFileFromFilesystem(pRequest As AODBackup.Msg.UploadFileRequest, Output pResponse As Ens.Response) As %Status
{
	set sc = $$$OK

	try
    {
        set stream = ##class(%Stream.FileCharacter).%New()
        $$$ThrowOnError(stream.LinkToFile(pRequest.OriginalFilename))
        set tFilename = ##class(Ens.Util.Time).FormatDateTime(..Filename, $PIECE(pRequest.OriginalFilename, "/", *)) 
        set sc = ..UploadFileHelper(tFilename, stream)
	}
	catch (ex)
    {
		set sc = ex.AsStatus()
	}

	return sc
}

/// Uploads a file to Amazon S3, using the Python boto3 library.
Method UploadFileHelper(key As %String, stream As %Stream.Object) As %Status [ Language = python ]
{
    import traceback
    import os
    import io
    import json
    import boto3
    from botocore.utils import fix_s3_host

    resource = boto3.resource('s3')
    resource.meta.client.meta.events.unregister('before-sign.s3', fix_s3_host)

    # set up the S3 client
    session = boto3.session.Session()
    client = session.client(
        service_name='s3',
        endpoint_url = self.EndpointURL,
        aws_access_key_id=self.AwsAccessKey,
        aws_secret_access_key=self.AwsSecretKey
    )

    # Get data to send from the Stream object into a BytesIO object.
    data = io.BytesIO(self.streamToBytearray(stream))

    # Rewind, as the put_object method doesn't.
    data.seek(0)

    try:
        # Upload
        rsp = client.put_object(
            ACL='bucket-owner-full-control',
            Bucket=self.BucketName,
            Key= '/'+ self.Prefix + key,
            Body=data
        )

        self.Trace(str(rsp))

    except Exception as err: 
        self.Trace(traceback.format_exc())
        return self.PythonExceptionAsStatus(err)

    return 1
}

/// Create IRIS Exception
Method createIrisException(ex As %SYS.Python) As %Exception.General [ Language = python ]
{
	import iris
	import traceback
	return iris.cls('%Exception.General')._New(type(ex).__name__, ex.args, 9999, ''.join(traceback.format_exception(None, ex, ex.__traceback__)), ''.join(traceback.format_exception(None, ex, ex.__traceback__)))
}

/// Extract status from Python exception
Method PythonExceptionAsStatus(ex As %SYS.Python) As %Status
{
	set exception = ..createIrisException(ex)
	return exception.AsStatus()
}

/// Convert stream to Python bytearray
ClassMethod streamToBytearray(stream As %Stream.Object) As %SYS.Python
{
	set byteArray = ##class(%SYS.Python).Builtins().bytearray()
	do stream.Rewind()
	
	while ('stream.AtEnd)
	{
		do byteArray.extend(##class(%SYS.Python).Bytes(stream.Read(32000)))
	}

	return byteArray
}

/// List S3 Bucket Contents (blobs)
Method ListDirectory(pRequest As AODBackup.Msg.ListDirectoryRequest, Output pResponse As AODBackup.Msg.ListDirectoryResponse) As %Status
{
    set pResponse = ##class(AODBackup.Msg.ListDirectoryResponse).%New()
    #dim result as %DynamicArray = []

    do ..ListObjectsHelper(result)

    #; for i = 1:1:result.%Size()
    #; {
    #;     do pResponse.Files.Insert(result.%Get(i - 1))
    #; }

    return pResponse.%JSONImport({ "Folder": (..Prefix), "Files": (result) })
}

/// Python list objects file names
Method ListObjectsHelper(result As %DynamicArray) [ Language = python ]
{
    import os
    import io
    import json
    import boto3
    import iris
    from botocore.utils import fix_s3_host

    resource = boto3.resource('s3')
    resource.meta.client.meta.events.unregister('before-sign.s3', fix_s3_host)

    # set up the S3 client
    session = boto3.session.Session()
    client = session.client(
        service_name='s3',
        endpoint_url = self.EndpointURL,
        aws_access_key_id=self.AwsAccessKey,
        aws_secret_access_key=self.AwsSecretKey
    )

    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3/client/list_objects_v2.html

    response = client.list_objects_v2(
        Bucket=self.BucketName,
        Prefix=self.Prefix,
        EncodingType='url',
    )


    while response.get('Contents'):
        self.Trace(str(response.get('Contents')))
        for object in response.get('Contents'):
            key = object.get('Key').replace(self.Prefix, '')
            if key == '' or '/' in key:
            	continue
            
            file = iris.cls('%DynamicObject')._New()
            file._Set('name', key.replace('+', ' '))
            file._Set('size', int(object.get('Size')))
            file._Set('lastModified', object.get('LastModified').isoformat())
            result._Push(file)
            
        if not response.get('IsTruncated'):
        	break
		 
        response = client.list_objects_v2(
            Bucket=self.BucketName,
            EncodingType='url',
            Prefix=self.Prefix,
            ContinuationToken=response.get('NextContinuationToken')
        )
}

/// Download the specified file
Method DownloadFile(pRequest As AODBackup.Msg.DownloadFileRequest, Output pResponse As Ens.StreamContainer) As %Status
{
    set pResponse = ##class(Ens.StreamContainer).%New()
	set sc = $$$OK

	try
    {
        set pResponse.Stream = ##class(%Stream.GlobalCharacter).%New()

        do ..DownloadFileHelper(pRequest.FileName, pResponse.Stream)
	}
	catch (ex)
    {
		set sc = ex.AsStatus()
	}

	return sc
}

/// Retrieves a file object from S3 storage.
Method DownloadFileHelper(key As %String, stream As %Stream.Object) [ Language = python ]
{
    import os
    import json
    import boto3
    from botocore.utils import fix_s3_host

    resource = boto3.resource('s3')
    resource.meta.client.meta.events.unregister('before-sign.s3', fix_s3_host)

    # set up the S3 client
    session = boto3.session.Session()
    client = session.client(
        service_name='s3',
        endpoint_url = self.EndpointURL,
        aws_access_key_id=self.AwsAccessKey,
        aws_secret_access_key=self.AwsSecretKey
    )

    # Retrieve the object
    response = client.get_object(
        Bucket=self.BucketName,
        Key=self.Prefix + key
    )

    # The file body is StreamingBody object; get it and remove
    # it from the dictionary
    body = response['Body']
    del response['Body']

    self.Trace(str(response))

    # Read data in chunks, decode to text, and add to stream
    for chunk in body.iter_chunks():
        chunk = chunk.decode("UTF-8")
        stream.Write(chunk)
}

/// Rename file on Server
Method RenameFile(pRequest As AODBackup.Msg.RenameFileRequest, Output pResponse As Ens.Response) As %Status
{
	set sc = $$$OK

	try
    {
        if (pRequest.NewFileName '= "")
        {
            set newFilename = pRequest.NewFileName
        }
        else
        {
            set newFilename = pRequest.CurrentFileName // Leave unchanged, just move to a different folder!
        }

        do ..RenameFileHelper(pRequest.CurrentFileName, pRequest.FilePath _ "/" _ ##class(Ens.Util.Time).FormatDateTime(..Filename, newFilename))
	}
	catch (ex)
    {
		set sc = ex.AsStatus()
	}

	return sc
}

/// Moves an S3 file within a bucket to a different location/name
Method RenameFileHelper(fromKey As %String, toKey As %String) [ Language = python ]
{
    import os
    import json
    import boto3
    from botocore.utils import fix_s3_host

    resource = boto3.resource('s3')
    resource.meta.client.meta.events.unregister('before-sign.s3', fix_s3_host)

    # set up the S3 client
    session = boto3.session.Session()
    s3 = session.resource(
        service_name='s3',
        endpoint_url = self.EndpointURL,
        aws_access_key_id=self.AwsAccessKey,
        aws_secret_access_key=self.AwsSecretKey
    )

    # First copy the file to the new location
    src = { 'Bucket': self.BucketName, 'Key': self.Prefix + fromKey }
    s3.Object(self.BucketName, self.Prefix + toKey).copy_from(CopySource=src)

    # Now remove the original
    rsp = client.delete_object(
        Bucket=self.BucketName,
        Key=self.Prefix + fromKey
    )

    self.Trace(str(rsp))
}

/// Remove file from Server
Method RemoveFile(pRequest As AODBackup.Msg.RemoveFileRequest, Output pResponse As Ens.Response) As %Status
{
	set sc = $$$OK

	try
    {
		do ..RemoveFileHelper(pRequest.FileName)
	}
	catch (ex)
    {
		set sc = ex.AsStatus()
	}

    return sc
}

/// Deletes a file to Amazon S3, using the Python boto3 library.
Method RemoveFileHelper(key As %String) [ Language = python ]
{
    import os
    import io
    import json
    import boto3
    from botocore.utils import fix_s3_host

    resource = boto3.resource('s3')
    resource.meta.client.meta.events.unregister('before-sign.s3', fix_s3_host)

    # set up the S3 client
    session = boto3.session.Session()
    client = session.client(
        service_name='s3',
        endpoint_url = self.EndpointURL,
        aws_access_key_id=self.AwsAccessKey,
        aws_secret_access_key=self.AwsSecretKey
    )

    rsp = client.delete_object(
        Bucket=self.BucketName,
        Key=self.Prefix + key
    )

    # S3 returns a Python dictionary; convert to JSON and return.
    self.Trace(str(rsp))
}

/// Make tracing available in Python method
Method Trace(message As %String)
{
	$$$TRACE(message)
}

}
