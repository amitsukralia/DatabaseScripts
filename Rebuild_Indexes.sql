ALTER INDEX ALL ON [TableName] REBUILD;
ALTER INDEX ALL ON [TableName] REORGANIZE;

drop index [TableName].[IndexName]

create index [IndexName] on TableName(ColumnList)
INCLUDE(ColumnList)

