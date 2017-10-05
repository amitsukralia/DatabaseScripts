  MERGE [ODMS].[Location].[GeoLocation] AS Target 
	USING [ODMS].[Location].[GeoLocation1]  AS Source
	ON 
	(Target.SourceSystemGeoLocationId = Source.SourceSystemGeoLocationId
	)
	WHEN MATCHED THEN
	UPDATE
	SET
	  GeoLocationName = Source.GeoLocationName
	WHEN NOT MATCHED THEN
	INSERT
	(SourceSystemGeoLocationId,
	GeoLocationName,
	GeoLocationType
	)
	VALUES
	(
	Source.SourceSystemGeoLocationId,
	Source.GeoLocationName,
	Source.GeoLocationType
	);