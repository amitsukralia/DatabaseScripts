
-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1;
GO
-- To update the currently configured value for advanced options.
RECONFIGURE;
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1;
GO
-- To update the currently configured value for this feature.
RECONFIGURE;
GO

EXEC sp_configure 'show advanced options', 0;
GO
-- To update the currently configured value for advanced options.
RECONFIGURE;
GO

/*****************************************/
--NOW EXECUTE THE PART USING xp_cmdshell
/*****************************************/

--Once done rollback

-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1;
GO
-- To update the currently configured value for advanced options.
RECONFIGURE;
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 0;
GO
-- To update the currently configured value for this feature.
RECONFIGURE;
GO

EXEC sp_configure 'show advanced options', 0;
GO
-- To update the currently configured value for advanced options.
RECONFIGURE;
GO

