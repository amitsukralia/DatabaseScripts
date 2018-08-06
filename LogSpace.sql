DBCC SQLPERF(LOGSPACE);  
GO  


SELECT name ,size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS AvailableSpaceInMB  
FROM sys.database_files;  


USE ODMS;  
GO  
-- Truncate the log by changing the database recovery model to SIMPLE.  
ALTER DATABASE [DatabaseName]
SET RECOVERY SIMPLE;  
GO  
-- Shrink the truncated log file to 1 MB.  
DBCC SHRINKFILE ([DatabaseName], 5);  
GO  
-- Reset the database recovery model.  
ALTER DATABASE [DatabaseName]
SET RECOVERY FULL;  
GO 


DBCC UPDATEUSAGE(0);
