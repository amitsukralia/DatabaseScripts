DBCC CHECKDB ('cms_a') WITH NO_INFOMSGS, ALL_ERRORMSGS

SELECT databasepropertyex('cms_a', 'STATUS')