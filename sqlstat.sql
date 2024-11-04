SELECT 
    'IF OBJECT_ID(''' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ''',''U'') IS NOT NULL DROP EXTERNAL TABLE ' + 
    QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + '; CREATE EXTERNAL TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ' (' + 
        CAST(STRING_AGG(' ' + QUOTENAME(c.name) + ' ' + ty.name + 
            CASE 
                WHEN ty.name IN ('varchar', 'char', 'nvarchar', 'nchar') THEN 
                    '(' + CAST(c.max_length / CASE WHEN ty.name IN ('nvarchar', 'nchar') THEN 2 ELSE 1 END AS NVARCHAR(10)) + ')'
                WHEN ty.name IN ('datetime2', 'datetimeoffset', 'time') AND c.scale > 0 THEN 
                    '(' + CAST(c.scale AS NVARCHAR(10)) + ')'
                WHEN ty.name IN ('decimal', 'numeric') THEN 
                    '(' + CAST(c.precision AS NVARCHAR(10)) + ', ' + CAST(c.scale AS NVARCHAR(10)) + ')'
                ELSE ''
            END + 
            CASE 
                WHEN c.is_nullable = 0 THEN ' NOT NULL'
                ELSE ' NULL'
            END, ', ') WITHIN GROUP (ORDER BY c.column_id) AS VARCHAR(MAX)) + 
    ')' + 
    ' WITH (' + 
    'LOCATION = ''' + et.location + ''', ' + 
    'DATA_SOURCE = ' + QUOTENAME(REPLACE(REPLACE(eds.name, 'hksynd', 'hksynp'), 'uat', 'prd')) + ', ' + 
    'FILE_FORMAT = ' + QUOTENAME(eff.name) + ', REJECT_TYPE = VALUE, REJECT_VALUE = 0);'
FROM sys.tables AS t
JOIN sys.schemas AS s ON t.schema_id = s.schema_id
JOIN sys.columns AS c ON t.object_id = c.object_id
JOIN sys.external_tables AS et ON t.object_id = et.object_id
JOIN sys.types AS ty ON c.user_type_id = ty.user_type_id
JOIN sys.external_data_sources AS eds ON et.data_source_id = eds.data_source_id
JOIN sys.external_file_formats AS eff ON et.file_format_id = eff.file_format_id
WHERE t.is_external = 1
AND t.name LIKE 'ext_idl_%'
AND s.name = 'dbo'
GROUP BY s.name, t.name, et.location, eds.name, eff.name;
