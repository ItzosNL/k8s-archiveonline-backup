/// Production for MMLOGGING
Class AODBackup.FoundationProduction Extends Ens.Production [ Not ProcedureBlock ]
{

XData ProductionDefinition
{
<Production Name="AODBackup.FoundationProduction" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>1</ActorPoolSize>
  <Item Name="UploadService" Category="" ClassName="AODBackup.BS.UploadService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="ArchivingOnDemand" Category="" ClassName="AODBackup.BO.ArchivingOnDemand" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="BucketName">ehealth-iris-bu</Setting>
    <Setting Target="Host" Name="AwsAccessKey">ZWhlYWx0aC1pcmlzLWJ1</Setting>
    <Setting Target="Host" Name="AwsSecretKey">179925c2c96471c3b7b2e066ec2f887d</Setting>
  </Item>
</Production>
}

}
