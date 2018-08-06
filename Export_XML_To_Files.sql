--Enable the xp_cmdshell before running the code below.
  -- Save XML records to a file:
DECLARE @fileName VARCHAR(500)
 
DECLARE @sqlStr VARCHAR(1000)
DECLARE @sqlCmd VARCHAR(1000)
DECLARE @Id INT

DECLARE processxml CURSOR FOR 
SELECT top 1 Id FROM [TableName] WHERE ReceivedDateTime < '2017-01-01'

  OPEN processxml 
  FETCH NEXT FROM processxml INTO @Id

	WHILE @@FETCH_STATUS = 0
	BEGIN 
 
		SET @fileName = 'C:\Temp\XMLPayLoad\' + CONVERT(VARCHAR(20),@Id) + '.xml'
		SET @sqlStr = 'select XMLPayLoad FROM [TableName] WHERE Id = ' + CONVERT(VARCHAR(20),@Id)
 
		SET @sqlCmd = 'bcp "' + @sqlStr + '" queryout ' + @fileName + ' -w -T'
 
		--SELECT @sqlCmd
		EXEC xp_cmdshell @sqlCmd

		FETCH NEXT FROM processxml INTO @Id
	END
CLOSE processxml
DEALLOCATE processxml 




