/// Manifext class that has a version and further information
Class AODBackup.Manifest
{

/// Package version - Must match with the release tag!
Parameter VERSION As STRING = "0.1.0-001";

Parameter Description As STRING = "This package enables an Iris instance to archive its backups to ArchivingOnDemand";

Parameter ProductionName As STRING = "AODBackup.FoundationProduction";

Parameter OperationName As STRING = "ArchivingOnDemand";

/// Load configuration for this package
/// - Load config properties
/// - Autostart production
ClassMethod LoadConfig(package As %DynamicObject)
{
    if $ISOBJECT(package.config)
    {
        // Create System default setting for item ArchivingOnDemand
        // - BucketName, value is package.config.bucket
        // - Prefix, value is package.config.folder; make sure thet folder ends with a "/"
        // - AwsAccessKey, value is package.config."access-key"
        // - AwsSecretKey, value is the secret referenmced to via package.config."access-secret"

        do ##class(ITZOS.K8S.Utilities.SystemDefaultSettings).CreateOrUpdate(..#ProductionName, ..#OperationName, "BucketName", package.config.bucket)

        if $EXTRACT(package.config.folder, *) '= "/"
        {
            set package.config.folder = package.config.folder _ "/"
        }

        do ##class(ITZOS.K8S.Utilities.SystemDefaultSettings).CreateOrUpdate(..#ProductionName, ..#OperationName, "Prefix", package.config.folder)
        do ##class(ITZOS.K8S.Utilities.SystemDefaultSettings).CreateOrUpdate(..#ProductionName, ..#OperationName, "AwsAccessKey", package.config."access-key")

        set secret = ##class(ITZOS.K8S.Utilities.Secrets).RetrievePassword(package.config."access-secret")
        do ##class(ITZOS.K8S.Utilities.SystemDefaultSettings).CreateOrUpdate(..#ProductionName, ..#OperationName, "AwsSecretKey", secret)
    }

    if package.namespace '= "" // Load the dedicated production
    {
        do ##class(ITZOS.K8S.Utilities.Production).Load(..#ProductionName)
    }
}

}
