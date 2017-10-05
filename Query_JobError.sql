use ProcessStatus
go

declare @JobId int
declare @jobInstanceId bigint

--select * from Job
select @JobId = JobId from Job where JobName = 'ProcessLocomotiveEventData'

select @jobInstanceId = max(JobInstanceId) from JobInstance with(nolock) where JobId = @JobId and JobStatusID = 3 --failed job

select * from JobLog where JobInstanceId = @jobInstanceId
and ExecutionCode = 3 --error 
order by JobLogId
