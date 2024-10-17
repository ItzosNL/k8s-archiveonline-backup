/// Manifext class that has a version and further information
Class AODBackup.Manifest
{

/// Package version - Must match with the release tag!
Parameter VERSION As STRING = "0.0.1-002";

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
        // Create System default setting for item ArchivingOnDemand, setting name = Prefix, setting value is package.config.folder 
        // Make sure thet folder ends with a "/"

        if $EXTRACT(package.config.folder, *) '= "/"
        {
            set package.config.folder = package.config.folder _ "/"
        }

        do ##class(ITZOS.K8S.Utilities.SystemDefaultSettings).CreateOrUpdate(..#ProductionName, ..#OperationName, "Prefix", package.config.folder)
    }

    if package.namespace '= "" // Load the dedicated production
    {
        do ##class(ITZOS.K8S.Utilities.Production).Load(..#ProductionName)
    }
}

}
