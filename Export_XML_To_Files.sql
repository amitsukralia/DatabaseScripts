/*
;WITH XMLNAMESPACES (DEFAULT 'https://integration.aurizon.com.au/schema/wayside_measurement_wild/v1.0.0')
select top 100
WaysideXMLDataQueueId	
FROM ODMS_Staging.Processing.WaysideXMLDataQueue q
WHERE [Source] = 'WaysideMeasurement.AxleBoxWheelBearingTemperature.Canonical'
and q.xmlpayload.value('(/WaysideMeasurementWheelImpactLoad/Body[1]/System[1]/Source[1]/text())[1]','varchar(255)')  = 'ARGUS'
and ProcessedDateTime < '2016-06-25'
ORDER BY WaysideXMLDataQueueId desc
*/
--Enable the xp_cmdshell before running the code below.
  -- Save XML records to a file:
DECLARE @fileName VARCHAR(500)
 
DECLARE @sqlStr VARCHAR(1000)
DECLARE @sqlCmd VARCHAR(1000)
DECLARE @WaysideXMLDataQueueId INT

DECLARE processxml CURSOR FOR 
SELECT top 1 WaysideXMLDataQueueId FROM ODMS_Staging.Processing.WaysideXMLDataQueue WHERE ReceivedDateTime < '2017-01-01'

  OPEN processxml 
  FETCH NEXT FROM processxml INTO @WaysideXMLDataQueueId

	WHILE @@FETCH_STATUS = 0
	BEGIN 
 
		SET @fileName = 'E:\Amit\Workspace\ODMS\XMLPayLoad\' + CONVERT(VARCHAR(20),@WaysideXMLDataQueueId) + '.xml'
		SET @sqlStr = 'select XMLPayLoad FROM ODMS_Staging.Processing.WaysideXMLDataQueue WHERE WaysideXMLDataQueueId = ' + CONVERT(VARCHAR(20),@WaysideXMLDataQueueId)
 
		SET @sqlCmd = 'bcp "' + @sqlStr + '" queryout ' + @fileName + ' -w -T'
 
		--SELECT @sqlCmd
		EXEC xp_cmdshell @sqlCmd

		FETCH NEXT FROM processxml INTO @WaysideXMLDataQueueId
	END
CLOSE processxml
DEALLOCATE processxml 




