SELECT  DB_NAME(mf.database_id) database_name,
        mf.name logical_name,
        mf.file_id,
        CONVERT (DECIMAL(20, 2), (CONVERT(DECIMAL, size) / 128)) AS [file_size_MB],
        CASE mf.is_percent_growth
          WHEN 1 THEN 'Yes'
          ELSE 'No'
        END AS [is_percent_growth],
        CASE mf.is_percent_growth
          WHEN 1 THEN CONVERT(VARCHAR, mf.growth) + '%'
          WHEN 0 THEN CONVERT(VARCHAR, mf.growth / 128) + ' MB'
        END AS [growth_in_increment_of],
        CASE mf.is_percent_growth
          WHEN 1 THEN CONVERT(DECIMAL(20, 2), (((CONVERT(DECIMAL, size) * growth) / 100) * 8) / 1024)
          WHEN 0 THEN CONVERT(DECIMAL(20, 2), (CONVERT(DECIMAL, growth) / 128))
        END AS [next_auto_growth_size_MB],
        physical_name
FROM    sys.master_files mf
WHERE   database_id = 2
        AND type_desc = 'rows'