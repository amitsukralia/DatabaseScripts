DBCC CHECKDB ('database_name') WITH NO_INFOMSGS, ALL_ERRORMSGS

SELECT databasepropertyex('database_name', 'STATUS')
