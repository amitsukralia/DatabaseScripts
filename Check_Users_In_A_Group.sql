EXEC master..xp_logininfo 
@acctname = 'INTERNAL\APP_ODMS_Reporting_Wayside_Authorised_UAT',
@option = 'members'
GO
EXEC master..xp_logininfo 
@acctname = 'INTERNAL\APP_ODMS_Reporting_Wayside_Unauthorised_UAT',
@option = 'members'
GO

EXEC master..xp_logininfo 
@acctname = 'INTERNAL\APP_ODMS_Reporting_Locomotive_UAT',
@option = 'members'
GO


sp_helpuser 'INTERNAL\r879593'

SELECT * FROM fn_builtin_permissions(default);  
GO  


select *, OBJECT_NAME(major_id), OBJECT_SCHEMA_NAME(major_id) from sys.database_permissions where grantee_principal_id in (8,12)

select * from sys.sysusers

