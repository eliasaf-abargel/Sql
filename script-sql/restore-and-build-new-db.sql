USE [master]
GO
DECLARE @CMD nvarchar(max)
DECLARE @DBNumber int = 5501

WHILE @DBNumber <= 5520
BEGIN
    IF DB_ID('Max2000_' + CONVERT(nvarchar(max), @DBNumber)) IS NULL
    BEGIN
        DECLARE @LogicalNameData nvarchar(128), @LogicalNameLog nvarchar(128)

        -- Fetch logical names from backup file
        CREATE TABLE #FileList (LogicalName nvarchar(128), PhysicalName nvarchar(260), [Type] char(1), FileGroupName nvarchar(128), Size numeric(20, 0), MaxSize numeric(20, 0), FileID bigint, CreateLSN numeric(25, 0), DropLSN numeric(25, 0), UniqueID uniqueidentifier, ReadOnlyLSN numeric(25, 0), ReadWriteLSN numeric(25, 0), BackupSizeInBytes bigint, SourceBlockSize int, FileGroupID int, LogGroupGUID uniqueidentifier, DifferentialBaseLSN numeric(25, 0), DifferentialBaseGUID uniqueidentifier, IsReadOnly bit, IsPresent bit, TDEThumbprint varbinary(32))

        INSERT INTO #FileList
        EXEC('RESTORE FILELISTONLY FROM DISK = N''E:\path\Backup\Max2000_5501.bak''')

        -- Assign logical names
        SELECT @LogicalNameData = LogicalName FROM #FileList WHERE [Type] = 'D'
        SELECT @LogicalNameLog = LogicalName FROM #FileList WHERE [Type] = 'L'

        -- Construct dynamic SQL for RESTORE
        SET @CMD = N'RESTORE DATABASE [Max2000_' + CONVERT(nvarchar(max), @DBNumber) + N'] FROM
        DISK = N''E:\path\Backup\Max2000_5501.bak'' WITH  FILE = 1
        ,  MOVE N''' + @LogicalNameData + N''' TO N''D:\path\MSSQL\DATA\Max2000_' + CONVERT(nvarchar(max), @DBNumber) + N'.mdf''
        ,  MOVE N''' + @LogicalNameLog + N''' TO N''L:\path\MSSQL\Data\Max2000_' + CONVERT(nvarchar(max), @DBNumber) + N'_log.ldf''
        ,  NOUNLOAD,  STATS = 5'

        -- Execute RESTORE command
        RAISERROR(N'%s',0,1,@CMD) WITH NOWAIT;
        EXEC(@CMD)

        -- Cleanup
        DROP TABLE #FileList
    END
    ELSE
        RAISERROR(N'Max2000_%d already exists',0,1,@DBNumber)

    SET @DBNumber = @DBNumber + 1

END
GO