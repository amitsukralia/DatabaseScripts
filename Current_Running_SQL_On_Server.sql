--Find Current SQL Statements that are Running
SELECT   SPID           = er.session_id
        ,STATUS         = ses.STATUS
        ,[Login]        = ses.login_name
        ,Host           = ses.host_name
        ,BlkBy          = er.blocking_session_id
        ,DBName         = DB_Name(er.database_id)
        ,CommandType    = er.command
        ,ObjectName     = OBJECT_NAME(st.objectid)
        ,CPUTime        = er.cpu_time
        ,StartTime      = er.start_time
        ,TimeElapsed    = CAST(GETDATE() - er.start_time AS TIME)
        ,SQLStatement   = st.text
FROM    sys.dm_exec_requests er
    OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
    LEFT JOIN sys.dm_exec_sessions ses
        ON ses.session_id = er.session_id
    LEFT JOIN sys.dm_exec_connections con
        ON con.session_id = ses.session_id
WHERE   st.text IS NOT NULL
		AND er.session_id != @@SPID
	order by 3

		
/*--Get the exact SQL running from the batch

declare
    @spid int
,   @stmt_start int
,   @stmt_end int
,   @sql_handle binary(20)

set @spid = 76 -- Fill this in

select  top 1
    @sql_handle = sql_handle
,   @stmt_start = case stmt_start when 0 then 0 else stmt_start / 2 end
,   @stmt_end = case stmt_end when -1 then -1 else stmt_end / 2 end
from    master.dbo.sysprocesses
where   spid = @spid
order by ecid

SELECT
    SUBSTRING(  text,
            COALESCE(NULLIF(@stmt_start, 0), 1),
            CASE @stmt_end
                WHEN -1
                    THEN DATALENGTH(text)
                ELSE
                    (@stmt_end - @stmt_start)
                END
        )
FROM ::fn_get_sql(@sql_handle)
*/

/*
SELECT name AS index_name,
STATS_DATE(OBJECT_ID, index_id) AS StatsUpdated
FROM sys.indexes
WHERE OBJECT_ID = OBJECT_ID('EventRecorder.FIRE')
GO

--Lists all OPEN transactions
-- Create the temporary table to accept the results.  
CREATE TABLE #OpenTranStatus (  
   ActiveTransaction varchar(25),  
   Details sql_variant   
   );  
-- Execute the command, putting the results in the table.  
INSERT INTO #OpenTranStatus   
   EXEC ('DBCC OPENTRAN WITH TABLERESULTS, NO_INFOMSGS');  
  
-- Display the results.  
SELECT * FROM #OpenTranStatus;  
GO  
DROP TABLE #OpenTranStatus 
GO

SELECT * FROM sys.sysprocesses WHERE open_tran = 1

SELECT TOP 10 d.object_id, d.database_id, OBJECT_NAME(object_id, database_id) 'proc name',   
    d.cached_time, d.last_execution_time, d.total_elapsed_time,  
    d.total_elapsed_time/d.execution_count AS [avg_elapsed_time],  
    d.last_elapsed_time, d.execution_count  
FROM sys.dm_exec_procedure_stats AS d  
ORDER BY [total_worker_time] DESC;  

DBCC FREEPROCCACHE WITH NO_INFOMSGS;    
*/


/*
Execution Plan

SELECT CONVERT(XML, c.query_plan) AS ExecutionPlan
FROM sys.dm_exec_requests a with (nolock)
OUTER APPLY sys.dm_exec_sql_text(a.sql_handle) b
OUTER APPLY sys.dm_exec_text_query_plan (a.plan_handle, a.statement_start_offset, a.statement_end_offset) c
LEFT JOIN sys.dm_exec_query_memory_grants m (nolock)
ON m.session_id = a.session_id
AND m.request_id = a.request_id
JOIN sys.databases d
ON d.database_id = a.database_id
WHERE  a.session_id = 82 --replace @@SPID with the SPID number for which you want to capture query plan
ORDER BY a.Start_Time
*/
