DECLARE @MeasurementBatchId BIGINT,
@VehicleNumber VARCHAR(20)
DECLARE @Message VARCHAR(500)

DECLARE db_cursor CURSOR FOR  
SELECT VehicleNumber, MeasurementBatchId
FROM #Measurement
order by VehicleNumber, MeasurementBatchId

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @VehicleNumber, @MeasurementBatchId   

WHILE @@FETCH_STATUS = 0   
BEGIN   

SELECT @Message = 'MeasurementBatchId := ' + CONVERT(VARCHAR(20), @MeasurementBatchId) + ' Start At:= ' + CONVERT(VARCHAR(20), GETDATE(), 113)
RAISERROR (@Message, 0, 1) WITH NOWAIT




FETCH NEXT FROM db_cursor INTO @VehicleNumber, @MeasurementBatchId   
END   

CLOSE db_cursor   
DEALLOCATE db_cursor
