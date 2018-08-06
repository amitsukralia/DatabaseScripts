select 'EXEC sp_dropextendedproperty

@name = ''MS_Description''

,@level0type = ''schema''

,@level0name = ' + object_schema_name(extended_properties.major_id) + '

,@level1type = ''table''

,@level1name = ' + object_name(extended_properties.major_id) + '

,@level2type = ''column''

,@level2name = ' + columns.name

from sys.extended_properties

join sys.columns

on columns.object_id = extended_properties.major_id

and columns.column_id = extended_properties.minor_id


where extended_properties.class_desc = 'OBJECT_OR_COLUMN'

and extended_properties.minor_id > 0

and extended_properties.name = 'MS_Description'
and object_name(major_id) = 'TableName'

