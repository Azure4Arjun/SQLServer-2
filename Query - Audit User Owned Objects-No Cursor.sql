/*

Query to Audit User Owned Objects

-- List all Databases owned by a user
-- List all Agent Jobs owned by a user
-- List all Packages owned by a user
-- List all Scheams owned by a user
-- List all Objects owned by a user
-- List all endpoints owned by a user
-- List all Event objects owned by a user

-- Edit
        Added logic to test for if SQL version is lower than 2008 for SSIS packages
        Fixed variable issue
        Changed If logic from IF 2008 > stop to only check at SSIS package
        Use sys.databases to clean up working iwth 2005. 2008 2012 instances

-- Edit (EsQueEl-Fella [at] gmail [dot] com)
--      - Replaced the usage of Cursors (16.06.2018)
--      - Small cleanups

*/
IF OBJECT_ID('tempdb..#OwnerTable') IS NOT NULL DROP TABLE #OwnerTable
CREATE TABLE #OwnerTable
(
  [Issue] VARCHAR(100),
  [Database] VARCHAR(200),
  [Object] VARCHAR(200),
  [ObjectType] VARCHAR(200),
  [Owner] VARCHAR(200)
)

/*
-- List all Non SA Database Owners
----------------------------------------------------------------------------- */
INSERT INTO #OwnerTable
 ([Issue], [Database], [Owner])
 SELECT  'Database Owned by a User' AS [Issue],
  [name] AS [Object],
  SUSER_SNAME(owner_sid) AS [Owner]
 FROM [sys].[databases]
 WHERE SUSER_SNAME(owner_sid) <> 'sa';

/*
-- List all Non SA Job Owners
----------------------------------------------------------------------------- */
INSERT INTO #OwnerTable
 ([Issue], [Database], [Object], [Owner])
 SELECT  'Agent Job Owned by a User'AS [Issue],
  'msdb' AS [Database],
  s.[name] AS [Object],
  l.[name] AS [Owner]
 FROM [msdb].[dbo].[sysjobs] AS s
 LEFT JOIN [master].[sys].[syslogins] AS l
 ON s.owner_sid = l.sid
 WHERE l.[name] <> 'sa';

/*
-- List all Non SA Package Owners
----------------------------------------------------------------------------- */
DECLARE @v INT
SET @v = CONVERT(INT, LEFT(CONVERT(VARCHAR(MAX), SERVERPROPERTY('ProductVersion')),
         CONVERT(INT, CHARINDEX('.', CONVERT(VARCHAR(MAX), SERVERPROPERTY('ProductVersion')))) - 1))

IF (@v >= 10)
 BEGIN
  INSERT INTO #OwnerTable
   ([Issue], [Database], [Object], [ObjectType], [Owner])
   SELECT
    'SSIS Packages Owned by a User' AS [Issue],
    'msdb' AS [Database],
    s.[name] AS [Object],
    'Maintenance Plan' AS [ObjectType],
    l.[name] AS [Owner]
   FROM [msdb].[dbo].[sysssispackages] AS s
   LEFT JOIN [master].[sys].[syslogins] AS l
   ON s.ownersid = l.sid
   WHERE l.[name] <> 'sa'
   OR l.[name] IS NULL;
 END
ELSE
 BEGIN
  INSERT INTO #OwnerTable
   ([Issue], [Database], [Object], [ObjectType], [Owner])
   SELECT
    'SSIS Packages Owned by a User' AS [Issue],
    'msdb' AS [Database],
     s.[name] AS [object],
     'Maintenance Plan' AS [ObjectType],
     l.[name] AS [Owner]
   FROM [msdb].[dbo].[sysdtspackages90] AS s
   LEFT JOIN [master].[sys].[sysusers] AS l
   ON s.ownersid = l.sid
   WHERE l.[name] <> 'sa'
   OR l.[name] IS NULL
 END

/*
-- List all Schemas owned by Users
----------------------------------------------------------------------------- */
DECLARE @DB_NameSch VARCHAR(256);
DECLARE @CommandSch NVARCHAR(MAX);
DECLARE @DB_Names TABLE (ID INT IDENTITY (1,1), [Db_Name] NVARCHAR(256));
DECLARE @RowCount INT = 0;
DECLARE @i INT = 1;

INSERT INTO @DB_Names
 SELECT [name]
 FROM [sys].[databases]
 WHERE state_desc = 'ONLINE'
 AND user_access_desc = 'MULTI_USER';

SET @RowCount = (SELECT TOP 1 Id FROM @DB_Names ORDER BY 1 DESC)

WHILE (@i <= @RowCount)
 BEGIN

  SET @DB_NameSch = (SELECT [Db_Name] FROM @DB_Names WHERE ID = @i)
  SET @CommandSch = '
   USE [' + @DB_NameSch + '];
   INSERT INTO #OwnerTable
   SELECT
    ''Schema Owned by a User'' AS [Issue],
    ''' + @DB_NameSch + ''' AS [Database],
    s.[name] AS [Object],
    ''Schema'' AS [ObjectType],
    u.[name] AS [Owner]
   FROM [' + @DB_NameSch + '].[sys].[schemas] AS s
   INNER JOIN [sys].[sysusers] AS u
   ON u.uid = s.principal_id
   WHERE s.[name] <> u.[name]';

  EXEC sp_executesql @CommandSch

  SET @i = @i + 1
 END


/*
-- Objects Owned by User
----------------------------------------------------------------------------- */
SET @RowCount = (SELECT TOP 1 Id FROM @DB_Names ORDER BY 1 DESC);
SET @i = 1

WHILE (@i <= @RowCount)
 BEGIN
  SET @DB_NameSch = (SELECT [Db_Name] FROM @DB_Names WHERE ID = @i)
  SET @CommandSch = '
   USE [' + @DB_NameSch + '];
   WITH objects_cte AS (
    SELECT
     o.[name],
     o.type_desc,
     CASE WHEN o.principal_id IS NULL THEN s.principal_id
      ELSE o.principal_id
     END AS principal_id
    FROM [sys].[objects] AS o
    INNER JOIN [sys].[schemas] AS s
    ON o.schema_id = s.schema_id
    WHERE o.is_ms_shipped = 0
    AND o.[type] IN (''U'', ''FN'', ''FS'',
    ''FT'', ''IF'', ''P'',
    ''PC'', ''TA'', ''TF'',
    ''TR'', ''V'')
   )
   INSERT INTO #OwnerTable
    SELECT ''Object Owned by User'' AS [Issue],
     DB_NAME() AS [Database],
     cte.[name] AS [Object],
     cte.type_desc AS [ObjectType],
     dp.[name] AS [Owner]
    FROM objects_cte AS cte
    INNER JOIN [sys].[database_principals] AS dp
    ON cte.principal_id = dp.principal_id
    WHERE dp.[name] NOT IN (''dbo'', ''cdc'');'

  EXEC sp_executesql @CommandSch

  SET @i = @i + 1
 END

/*
-- Show results and dispose the temp table
----------------------------------------------------------------------------- */
SELECT 1 AS [DataCollectionRound],
 GETDATE() AS [QueryDate],
 SERVERPROPERTY('MachineName') AS [MachineName],
 SERVERPROPERTY('ServerName') AS [ServerName],
 SERVERPROPERTY('InstanceName') AS [Instance],
 *
FROM #OwnerTable;

DROP TABLE #OwnerTable;
