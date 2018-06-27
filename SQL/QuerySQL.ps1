<#
'Query' = "INSERT INTO [dbo].[SecurityGroups] ([Key] ,
[IsAdmin] ,[CanAttachClaims] ,[DisplayName] ,[ApplicationLevelId] ,[ExternalId] ,[Created] ,[Updated] ,[CreatedBy] ,[UpdatedBy] ,[Environment]) VALUES (
    'AdminSiteOperator',1,1,'Admin Site Operator',null,null,getdate(),getdate(),'Data Configuration','Data Configuration',null)",
     'ServerInstance' = 'paueaspresql000.database.windows.net',
     'UserName' = 'padbadministrator',
     'Password' = 'ca7bb531-04c4-4341-b9bb-ce0994cbd2b6'
     'Database' = 'pa_store_Preview'
     }
#>

$host.ui.RawUI.WindowTitle = ($MyInvocation.MyCommand.Name)
"test"