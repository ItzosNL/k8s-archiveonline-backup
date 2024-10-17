# k8s-archiveonline-backup
This repository contains the AODBackup package that enables an Iris instance to archive its backups to ArchivingOnDemand
The package is loaded directly from gihub using the after-install.json configuration with a specification like:

```
      "packages": {
          "AODBackup": {
              "namespace": "AODBackup",
              "owner": "ItzosNL",
              "repo": "k8s-archiveonline-backup",
              "config": {
                "folder": "altrecht-o/"
              }
            }
        }

```

Prerequisites:
Make sure you have loaded the Python boto3 package in Dockerfile

```
   RUN apt-get -y install python3-boto3
```


