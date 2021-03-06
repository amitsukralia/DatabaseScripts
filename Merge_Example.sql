﻿  MERGE [TableName1] AS Target 
	USING [TableName2]  AS Source
	ON 
	(Target.Id = Source.Id
	)
	WHEN MATCHED THEN
	UPDATE
	SET
	  Name = Source.Name
	WHEN NOT MATCHED THEN
	INSERT
	(Id,
	Name
	)
	VALUES
	(
	Source.Id,
	Source.Name
	);
