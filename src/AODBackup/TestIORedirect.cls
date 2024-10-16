Include %occErrors

/// Help testing redirect
Class AODBackup.TestIORedirect Extends %SYS.Task.Definition
{

/// Overwrite of OnTask method to add additonal logic
Method OnTask() As %Status
{
    write "This text should be part of the attachment",!

    return $$$ERROR($$$GeneralError, "RETURNING ERROR FOR TESTING")
}

}
