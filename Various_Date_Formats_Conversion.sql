
declare @t datetime2(6)  = getdate()

select @t as Original, 
convert(varchar(30), @t, 100) as '100',
convert(varchar(30), @t, 101) as '101',
convert(varchar(30), @t, 102) as '102',
convert(varchar(30), @t, 103) as '103',
convert(varchar(30), @t, 104) as '104',
convert(varchar(30), @t, 105) as '105',
convert(varchar(30), @t, 106) as '106',
convert(varchar(30), @t, 107) as '107',
convert(varchar(30), @t, 108) as '108',
convert(varchar(30), @t, 109) as '109',
convert(varchar(30), @t, 110) as '110',
convert(varchar(30), @t, 111) as '111',
convert(varchar(30), @t, 112) as '112',
convert(varchar(30), @t, 113) as '113',
convert(varchar(30), @t, 114) as '114'
