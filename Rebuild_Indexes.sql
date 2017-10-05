ALTER INDEX ALL ON ODMS.dbo.HBDHWDBearingWheelDetail_Copy REBUILD;
ALTER INDEX ALL ON ODMS.dbo.HBDHWDBearingWheelDetail REORGANIZE;

create index IDX_NC_CaptureStartDateTime 

drop index dbo.HBDHWDBearingWheelDetail.[IDX_NC_HBDHWD]

create index [IDX_NC_ReportDate] on dbo.HBDHWDBearingWheelDetail(ReportDate, IsActive)
INCLUDE([TrainId],[SourceSystemTrainId], [SiteName],[VehicleOwnerName], [VehicleRunningNumber], [DeviceName])


ALTER INDEX  [IDX_NC_VehicleTravelSection] ON EventRecorder.FIRE REBUILD
GO

ALTER INDEX  [IDX_NC_GPSCoordinate] ON Location.GPSCoordinate REBUILD
GO


ALTER INDEX  [IDX_NC_TripRecordDateTime] ON EventRecorder.FIRE REBUILD
GO

ALTER INDEX  [IDX_NC_Vehicle] ON RollingStock.Vehiclde REBUILD
GO

ALTER INDEX  [PK_Vehicle] ON RollingStock.Vehiclde REBUILD
GO

ALTER INDEX  [IDX_NC_Axle] ON RollingStock.Axle REBUILD
GO

ALTER INDEX  [PK_Axle] ON RollingStock.Axle REBUILD
GO

ALTER INDEX  ALL ON Log.FileImportLog  REBUILD