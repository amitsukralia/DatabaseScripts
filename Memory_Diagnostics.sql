/*********************************************************************/
--Script: Captures System Memory Usage
--Works On: 2008, 2008 R2, 2012, 2014, 2016
/*********************************************************************/
/*
select
      total_physical_memory_kb/1024 AS total_physical_memory_mb,
      available_physical_memory_kb/1024 AS available_physical_memory_mb,
      total_page_file_kb/1024 AS total_page_file_mb,
      available_page_file_kb/1024 AS available_page_file_mb,
      100 - (100 * CAST(available_physical_memory_kb AS DECIMAL(18,3))/CAST(total_physical_memory_kb AS DECIMAL(18,3))) 
      AS 'Percentage_Used',
      system_memory_state_desc
from  sys.dm_os_sys_memory;



/**************************************************************/
-- Script: SQL Server Process Memory Usage
-- Works On: 2008, 2008 R2, 2012, 2014, 2016
/**************************************************************/
select
      physical_memory_in_use_kb/1048576.0 AS 'physical_memory_in_use (GB)',
      locked_page_allocations_kb/1048576.0 AS 'locked_page_allocations (GB)',
      virtual_address_space_committed_kb/1048576.0 AS 'virtual_address_space_committed (GB)',
      available_commit_limit_kb/1048576.0 AS 'available_commit_limit (GB)',
      page_fault_count as 'page_fault_count'
from  sys.dm_os_process_memory;



/**************************************************************/
--Script: Database Wise Buffer Usage
--Works On: 2008, 2008 R2, 2012, 2014, 2016
/**************************************************************/

DECLARE @total_buffer INT;
SELECT  @total_buffer = cntr_value 
FROM   sys.dm_os_performance_counters
WHERE  RTRIM([object_name]) LIKE '%Buffer Manager' 
       AND counter_name = 'Database Pages';

;WITH DBBuffer AS
(
SELECT  database_id,
        COUNT_BIG(*) AS db_buffer_pages,
        SUM (CAST ([free_space_in_bytes] AS BIGINT)) / (1024 * 1024) AS [MBEmpty]
FROM    sys.dm_os_buffer_descriptors
GROUP BY database_id
)
SELECT
       CASE [database_id] WHEN 32767 THEN 'Resource DB' ELSE DB_NAME([database_id]) END AS 'db_name',
       db_buffer_pages AS 'db_buffer_pages',
       db_buffer_pages / 128 AS 'db_buffer_Used_MB',
       [mbempty] AS 'db_buffer_Free_MB',
       CONVERT(DECIMAL(6,3), db_buffer_pages * 100.0 / @total_buffer) AS 'db_buffer_percent'
FROM   DBBuffer
ORDER BY db_buffer_Used_MB DESC;



/**************************************************************/
--Script: Object Wise Buffer Usage
--Works On: 2008, 2008 R2, 2012, 2014, 2016
/**************************************************************/

;WITH obj_buffer AS
(
SELECT
       [Object] = o.name,
       [Type] = o.type_desc,
       [Index] = COALESCE(i.name, ''),
       [Index_Type] = i.type_desc,
       p.[object_id],
       p.index_id,
       au.allocation_unit_id
FROM
       sys.partitions AS p
       INNER JOIN sys.allocation_units AS au ON p.hobt_id = au.container_id
       INNER JOIN sys.objects AS o ON p.[object_id] = o.[object_id]
       INNER JOIN sys.indexes AS i ON o.[object_id] = i.[object_id] AND p.index_id = i.index_id
WHERE
       au.[type] IN (1,2,3) AND o.is_ms_shipped = 0
)
SELECT
       obj.[Object],
       obj.[Type],
       obj.[Index],
       obj.Index_Type,
       COUNT_BIG(b.page_id) AS 'buffer_pages',
       COUNT_BIG(b.page_id) / 128 AS 'buffer_mb'
FROM
       obj_buffer obj 
       INNER JOIN sys.dm_os_buffer_descriptors AS b ON obj.allocation_unit_id = b.allocation_unit_id
WHERE
       b.database_id = DB_ID()
GROUP BY
       obj.[Object],
       obj.[Type],
       obj.[Index],
       obj.Index_Type
ORDER BY
       buffer_pages DESC;


/**************************************************************/
--Script: Top 25 Costliest Stored Procedures by Logical Reads
--Works On: 2008, 2008 R2, 2012, 2014, 2016
/**************************************************************/

SELECT  TOP(25)
        p.name AS [SP Name],
        qs.total_logical_reads AS [TotalLogicalReads],
        qs.total_logical_reads/qs.execution_count AS [AvgLogicalReads],
        qs.execution_count AS 'execution_count',
        qs.total_elapsed_time AS 'total_elapsed_time',
        qs.total_elapsed_time/qs.execution_count AS 'avg_elapsed_time',
        qs.cached_time AS 'cached_time'
FROM    sys.procedures AS p
        INNER JOIN sys.dm_exec_procedure_stats AS qs 
                   ON p.[object_id] = qs.[object_id]
WHERE
        qs.database_id = DB_ID()
ORDER BY
        qs.total_logical_reads DESC;
*/

/**************************************************************/
--Script: Top Performance Counters - Memory
--Works On: 2008, 2008 R2, 2012, 2014, 2016
/**************************************************************/

-- Get size of SQL Server Page in bytes
DECLARE @pg_size INT, @Instancename varchar(50)
SELECT @pg_size = low from master..spt_values where number = 1 and type = 'E'

-- Extract perfmon counters to a temporary table
IF OBJECT_ID('tempdb..#perfmon_counters') is not null DROP TABLE #perfmon_counters
SELECT * INTO #perfmon_counters FROM sys.dm_os_performance_counters;

-- Get SQL Server instance name as it require for capturing Buffer Cache hit Ratio
SELECT  @Instancename = LEFT([object_name], (CHARINDEX(':',[object_name]))) 
FROM    #perfmon_counters 
WHERE   counter_name = 'Buffer cache hit ratio';


SELECT * FROM (
SELECT  'Total Server Memory (GB)' as Cntr,
        (cntr_value/1048576.0) AS Value 
FROM    #perfmon_counters 
WHERE   counter_name = 'Total Server Memory (KB)'
UNION ALL
SELECT  'Target Server Memory (GB)', 
        (cntr_value/1048576.0) 
FROM    #perfmon_counters 
WHERE   counter_name = 'Target Server Memory (KB)'
UNION ALL
SELECT  'Connection Memory (MB)', 
        (cntr_value/1024.0) 
FROM    #perfmon_counters 
WHERE   counter_name = 'Connection Memory (KB)'
UNION ALL
SELECT  'Lock Memory (MB)', 
        (cntr_value/1024.0) 
FROM    #perfmon_counters 
WHERE   counter_name = 'Lock Memory (KB)'
UNION ALL
SELECT  'SQL Cache Memory (MB)', 
        (cntr_value/1024.0) 
FROM    #perfmon_counters 
WHERE   counter_name = 'SQL Cache Memory (KB)'
UNION ALL
SELECT  'Optimizer Memory (MB)', 
        (cntr_value/1024.0) 
FROM    #perfmon_counters 
WHERE   counter_name = 'Optimizer Memory (KB) '
UNION ALL
SELECT  'Granted Workspace Memory (MB)', 
        (cntr_value/1024.0) 
FROM    #perfmon_counters 
WHERE   counter_name = 'Granted Workspace Memory (KB) '
UNION ALL
SELECT  'Cursor memory usage (MB)', 
        (cntr_value/1024.0) 
FROM    #perfmon_counters 
WHERE   counter_name = 'Cursor memory usage' and instance_name = '_Total'
UNION ALL
SELECT  'Total pages Size (MB)', 
        (cntr_value*@pg_size)/1048576.0 
FROM    #perfmon_counters 
WHERE   object_name= @Instancename+'Buffer Manager' 
        and counter_name = 'Total pages'
UNION ALL
SELECT  'Database pages (MB)', 
        (cntr_value*@pg_size)/1048576.0 
FROM    #perfmon_counters 
WHERE   object_name = @Instancename+'Buffer Manager' and counter_name = 'Database pages'
UNION ALL
SELECT  'Free pages (MB)', 
        (cntr_value*@pg_size)/1048576.0 
FROM    #perfmon_counters 
WHERE   object_name = @Instancename+'Buffer Manager' 
        and counter_name = 'Free pages'
UNION ALL
SELECT  'Reserved pages (MB)', 
        (cntr_value*@pg_size)/1048576.0 
FROM    #perfmon_counters 
WHERE   object_name=@Instancename+'Buffer Manager' 
        and counter_name = 'Reserved pages'
UNION ALL
SELECT  'Stolen pages (MB)', 
        (cntr_value*@pg_size)/1048576.0 
FROM    #perfmon_counters 
WHERE   object_name=@Instancename+'Buffer Manager' 
        and counter_name = 'Stolen pages'
UNION ALL
SELECT  'Cache Pages (MB)', 
        (cntr_value*@pg_size)/1048576.0 
FROM    #perfmon_counters 
WHERE   object_name=@Instancename+'Plan Cache' 
        and counter_name = 'Cache Pages' and instance_name = '_Total'
UNION ALL
SELECT  'Page Life Expectency in seconds',
        cntr_value 
FROM    #perfmon_counters 
WHERE   object_name=@Instancename+'Buffer Manager' 
        and counter_name = 'Page life expectancy'
UNION ALL
SELECT  'Free list stalls/sec',
        cntr_value 
FROM    #perfmon_counters 
WHERE   object_name=@Instancename+'Buffer Manager' 
        and counter_name = 'Free list stalls/sec'
UNION ALL
SELECT  'Checkpoint pages/sec',
        cntr_value 
FROM    #perfmon_counters 
WHERE   object_name=@Instancename+'Buffer Manager' 
        and counter_name = 'Checkpoint pages/sec'
UNION ALL
SELECT  'Lazy writes/sec',
        cntr_value 
FROM    #perfmon_counters 
WHERE   object_name=@Instancename+'Buffer Manager' 
        and counter_name = 'Lazy writes/sec'
UNION ALL
SELECT  'Memory Grants Pending',
        cntr_value 
FROM    #perfmon_counters 
WHERE   object_name=@Instancename+'Memory Manager' 
        and counter_name = 'Memory Grants Pending'
UNION ALL
SELECT  'Memory Grants Outstanding',
        cntr_value 
FROM    #perfmon_counters 
WHERE   object_name=@Instancename+'Memory Manager' 
        and counter_name = 'Memory Grants Outstanding'
UNION ALL
SELECT  'process_physical_memory_low',
        process_physical_memory_low 
FROM    sys.dm_os_process_memory WITH (NOLOCK)
UNION ALL
SELECT  'process_virtual_memory_low',
        process_virtual_memory_low 
FROM    sys.dm_os_process_memory WITH (NOLOCK)
UNION ALL
SELECT  'Max_Server_Memory (MB)' ,
        [value_in_use] 
FROM    sys.configurations 
WHERE   [name] = 'max server memory (MB)'
UNION ALL
SELECT  'Min_Server_Memory (MB)' ,
        [value_in_use] 
FROM    sys.configurations 
WHERE   [name] = 'min server memory (MB)'
UNION ALL
SELECT  'BufferCacheHitRatio',
        (a.cntr_value * 1.0 / b.cntr_value) * 100.0 
FROM    sys.dm_os_performance_counters a
        JOIN (SELECT cntr_value,OBJECT_NAME FROM sys.dm_os_performance_counters
              WHERE counter_name = 'Buffer cache hit ratio base' AND 
                    OBJECT_NAME = @Instancename+'Buffer Manager') b ON 
                    a.OBJECT_NAME = b.OBJECT_NAME WHERE a.counter_name = 'Buffer cache hit ratio' 
                    AND a.OBJECT_NAME = @Instancename+'Buffer Manager'

) AS D;

/*
SELECT (CASE 
           WHEN ( [database_id] = 32767 ) THEN 'Resource Database' 
           ELSE Db_name (database_id) 
         END )  AS 'Database Name', 
       Sum(CASE 
             WHEN ( [is_modified] = 1 ) THEN 0 
             ELSE 1 
           END) AS 'Clean Page Count',
		Sum(CASE 
             WHEN ( [is_modified] = 1 ) THEN 1 
             ELSE 0 
           END) AS 'Dirty Page Count'
FROM   sys.dm_os_buffer_descriptors 
GROUP  BY database_id 
ORDER  BY DB_NAME(database_id);


SELECT
    (CASE WHEN ([database_id] = 32767)
        THEN N'Resource Database'
        ELSE DB_NAME ([database_id]) END) AS [DatabaseName],
    COUNT (*) * 8 / 1024 AS [MBUsed],
    SUM (CAST ([free_space_in_bytes] AS BIGINT)) / (1024 * 1024) AS [MBEmpty]
FROM sys.dm_os_buffer_descriptors
GROUP BY [database_id];
GO





EXEC sp_MSforeachdb
    N'IF EXISTS (SELECT 1 FROM (SELECT DISTINCT DB_NAME ([database_id]) AS [name]
    FROM sys.dm_os_buffer_descriptors) AS names WHERE [name] = ''?'')
BEGIN
USE [?]
SELECT
    ''?'' AS [Database],
    OBJECT_NAME (p.[object_id]) AS [Object],
    p.[index_id],
    i.[name] AS [Index],
    i.[type_desc] AS [Type],
    --au.[type_desc] AS [AUType],
    --DPCount AS [DirtyPageCount],
    --CPCount AS [CleanPageCount],
    --DPCount * 8 / 1024 AS [DirtyPageMB],
    --CPCount * 8 / 1024 AS [CleanPageMB],
    (DPCount + CPCount) * 8 / 1024 AS [TotalMB],
    --DPFreeSpace / 1024 / 1024 AS [DirtyPageFreeSpace],
    --CPFreeSpace / 1024 / 1024 AS [CleanPageFreeSpace],
    ([DPFreeSpace] + [CPFreeSpace]) / 1024 / 1024 AS [FreeSpaceMB],
    CAST (ROUND (100.0 * (([DPFreeSpace] + [CPFreeSpace]) / 1024) / (([DPCount] + [CPCount]) * 8), 1) AS DECIMAL (4, 1)) AS [FreeSpacePC]
FROM
    (SELECT
        allocation_unit_id,
        SUM (CASE WHEN ([is_modified] = 1)
            THEN 1 ELSE 0 END) AS [DPCount],
        SUM (CASE WHEN ([is_modified] = 1)
            THEN 0 ELSE 1 END) AS [CPCount],
        SUM (CASE WHEN ([is_modified] = 1)
            THEN CAST ([free_space_in_bytes] AS BIGINT) ELSE 0 END) AS [DPFreeSpace],
        SUM (CASE WHEN ([is_modified] = 1)
            THEN 0 ELSE CAST ([free_space_in_bytes] AS BIGINT) END) AS [CPFreeSpace]
    FROM sys.dm_os_buffer_descriptors
    WHERE [database_id] = DB_ID (''?'')
    GROUP BY [allocation_unit_id]) AS buffers
INNER JOIN sys.allocation_units AS au
    ON au.[allocation_unit_id] = buffers.[allocation_unit_id]
INNER JOIN sys.partitions AS p
    ON au.[container_id] = p.[partition_id]
INNER JOIN sys.indexes AS i
    ON i.[index_id] = p.[index_id] AND p.[object_id] = i.[object_id]
WHERE p.[object_id] > 100 AND ([DPCount] + [CPCount]) > 12800 -- Taking up more than 100MB
ORDER BY [FreeSpacePC] DESC;
END';


SELECT [cntr_value]
FROM sys.dm_os_performance_counters
WHERE
	[object_name] LIKE '%Buffer Manager%'
	AND [counter_name] = 'Page life expectancy'


select * from sys.dm_os_memory_nodes
*/