declare @t varchar(30) = '2016-10-24T05:47:35.31+11:00'
select convert(datetime, convert(datetimeoffset, @t,127)) as [RecordDateTime]
select convert(date, convert(datetimeoffset, @t,127)) as [RecordDate]
select convert(time(7), convert(datetimeoffset, @t,127)) as [RecordTime]
select reverse(substring(reverse(@t),1,charindex('+',reverse(@t), 1))) AS [TimeZone]


select convert(datetime, '2016-10-24 05:47:35.31 +11:00')
select convert(datetimeoffset, getdate())

select convert(datetime, convert(datetimeoffset, '2016-10-24T05:47:35.31+11:00',127))