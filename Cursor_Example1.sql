CREATE TABLE tempdb..TrainStep(
TrainId INT, SiteName VARCHAR(200), UTCTrainUID VARCHAR(30), UTCTrainNumber VARCHAR(20))

select * into #temp
from
(
select t.TrainId, t.Track, t.CaptureStartDateTime, t.ProviderTrainIdentifier, rs.SourceSystemServiceId as ServiceId, rs.ServiceDate, rs.TrainNumber, mb.DeviceName, mb.SiteName, mb.SiteDescription, mb.ProviderName
from RollingStock.Train t with(nolock)
left join RollingStock.Service rs with(nolock) on t.ServiceId = rs.ServiceId
join vw_MeasurementBatch mb on t.MeasurementBatchId = mb.MeasurementBatchId
where t.IsActive = 1
--and mb.SiteName = 'NC598'
and t.CaptureStartDateTime > '2017-06-18'
--order by trainId desc
)aa

DECLARE @Message VARCHAR(500)
declare @TrainId INT, @SiteName VARCHAR(200), @Track INT, @CaptureStartDateTime DATETIME2(7)


DECLARE db_cursor CURSOR FOR  
	select TrainId, SiteName, Track, CaptureStartDateTime
	FROM #temp
	order by TrainId
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @TrainId, @SiteName, @Track, @CaptureStartDateTime

WHILE @@FETCH_STATUS = 0   
BEGIN   

	SELECT @Message = 'TrainId := ' + CONVERT(VARCHAR(20), @TrainId) + ' Start At:= ' + CONVERT(VARCHAR(20), GETDATE(), 113)

	RAISERROR (@Message, 0, 1) WITH NOWAIT

	INSERT tempdb..TrainStep(TrainId, UTCTrainUID, UTCTrainNumber)
	select @TrainId, UTCTrainUID, UTCTrainNumber FROM [dbo].[fn_TrainUIDFromTrainStep_New](@SiteName, @Track, @CaptureStartDateTime)

FETCH NEXT FROM db_cursor INTO @TrainId, @SiteName, @Track, @CaptureStartDateTime

END   

CLOSE db_cursor   
DEALLOCATE db_cursor

select 
t.*, ts.UTCTrainUID, ts.UTCTrainNumber
from #temp t
join #TrainStep ts on t.TrainId = ts.TrainId
where t.TrainNumber != ts.UTCTrainNumber
and t.TrainId = 368080

select t.*, ts.*, sst.* from 
RollingStock.vw_TrainStep ts 
join SiteStationTrackMap sst on ts.TrackStationId = sst.StationNemonic and ts.TrackId = sst.Track
join #TrainStep t on t.UTCTrainUID = ts.TrainUId collate Latin1_General_CI_AS and t.UTCTrainNumber = ts.TrainId collate Latin1_General_CI_AS
where
	sst.ODMSSiteName = 'NC598' and ts.EventType ='occupied'
	and ts.TrainUId = 'RKY0403785A6E'
  --sst.ODMSSiteName = 'Eaglefield Creek HBD/HWD' --and sst.ODMSTrack= NULL
  --and CreateDate > '2017-06-29 13:00:59.000'
  order by t.TrainId,CreateDate


select * from RollingStock.Train where TrainID = 366034


select TrainStepId   ,CreateDate,EventType,TrackId,TrackStationId,TrainId,TrainUId, NativeSystemName, TrainDirection       , Area,Corridor,EquipmentType,EquipmentGroup,EquipmentID,Location,SystemID,DataSource from ODMS.RollingStock.vw_TrainStep ts
join SiteStationTrackMap sst on ts.TrackStationId = sst.StationNemonic and ts.TrackId = sst.Track
where sst.ODMSSiteName = 'NC598' --and sst.ODMSTrack =1
and CreateDate between '2017-06-28 04:30:00.000' and '2017-06-28 04:50:00.000'
order by CreateDate
