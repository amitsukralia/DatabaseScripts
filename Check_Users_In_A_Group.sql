EXEC master..xp_logininfo 
@acctname = 'AD Group Name',
@option = 'members'
GO

SELECT * FROM fn_builtin_permissions(default);  
GO  

select *, OBJECT_NAME(major_id), OBJECT_SCHEMA_NAME(major_id) from sys.database_permissions where grantee_principal_id in (8,12)

