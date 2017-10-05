declare @TableName varchar(50)= 'ServiceDetail'

        SELECT 
		'ALTER TABLE ' + table_schema + '.' + table_name+
		' ALTER COLUMN ' + COLUMN_NAME + ' '+ DATA_TYPE + '(' + CONVERT(VARCHAR(20), CHARACTER_MAXIMUM_LENGTH) + ')' + ' COLLATE SQL_Latin1_General_CP1_CI_AS ' +
		case when IS_NULLABLE = 'YES' THEN 'NULL' ELSE 'NOT NULL' END
            IS_NULLABLE from information_schema.columns
            WHERE 
			table_name not like 'vw_%' and
			(Data_Type LIKE '%char%' 
            OR Data_Type LIKE '%text%') 
			AND COLLATION_NAME != 'SQL_Latin1_General_CP1_CI_AS'
            ORDER BY table_schema,  table_name


        DECLARE MyColumnCursor Cursor
        FOR 
        SELECT COLUMN_NAME,DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,
            IS_NULLABLE from information_schema.columns
            WHERE table_name = @TableName AND  (Data_Type LIKE '%char%' 
            OR Data_Type LIKE '%text%') --AND COLLATION_NAME &lt;> @CollationName
            ORDER BY ordinal_position 
        Open MyColumnCursor

        FETCH NEXT FROM MyColumnCursor INTO @ColumnName, @DataType, 
              @CharacterMaxLen, @IsNullable
        WHILE @@FETCH_STATUS = 0
            BEGIN
            SET @SQLText = 'ALTER TABLE ' + @TableName + ' ALTER COLUMN [' + @ColumnName + '] ' + 
              @DataType + '(' + CASE WHEN @CharacterMaxLen = -1 THEN 'MAX' ELSE @CharacterMaxLen END + 
              ') COLLATE ' + @CollationName + ' ' + 
              CASE WHEN @IsNullable = 'NO' THEN 'NOT NULL' ELSE 'NULL' END
            PRINT @SQLText 

        FETCH NEXT FROM MyColumnCursor INTO @ColumnName, @DataType, 
              @CharacterMaxLen, @IsNullable
        END
        CLOSE MyColumnCursor
        DEALLOCATE MyColumnCursor

