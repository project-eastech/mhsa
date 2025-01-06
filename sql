DECLARE @TableName NVARCHAR(MAX) = 'YourTableName'; -- Replace with your table name

SELECT 'CREATE TABLE ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) + ' (' + CHAR(13) +
       STRING_AGG(
           '    ' + QUOTENAME(COLUMN_NAME) + ' ' +
           DATA_TYPE +
           CASE
               WHEN DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar') THEN '(' +
                    CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX'
                         ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS NVARCHAR)
                    END + ')'
               WHEN DATA_TYPE IN ('decimal', 'numeric') THEN '(' +
                    CAST(NUMERIC_PRECISION AS NVARCHAR) + ',' + CAST(NUMERIC_SCALE AS NVARCHAR) + ')'
               ELSE ''
           END +
           CASE WHEN IS_NULLABLE = 'YES' THEN ' NULL' ELSE ' NOT NULL' END, ',' + CHAR(13)
       ) + CHAR(13) + ')' AS DDL
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TableName
GROUP BY TABLE_SCHEMA, TABLE_NAME;
