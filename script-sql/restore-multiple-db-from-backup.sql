USE [master]
GO
DECLARE @CMD nvarchar(max)
DECLARE @DBNumber int = 5401

WHILE @DBNumber <= 5500
BEGIN

	IF DB_ID('Max2000_' + CONVERT(nvarchar(max), @DBNumber)) IS NULL
	BEGIN
		SET @CMD = N'RESTORE DATABASE [Max2000_' + CONVERT(nvarchar(max), @DBNumber) + N'] FROM
		DISK = N''K:\path\Backup\Max2000_5400.bak'' WITH  FILE = 1
		,  MOVE N''Max2000_4450'' TO N''H:\path\MSSQL\DATA\Max2000_' + CONVERT(nvarchar(max), @DBNumber) + N'.mdf''
		,  MOVE N''Max2000_4450_log'' TO N''I:\path\MSSQL\Data\Max2000_' + CONVERT(nvarchar(max), @DBNumber) + N'_log.ldf''
		,  NOUNLOAD,  STATS = 5'

		RAISERROR(N'%s',0,1,@CMD) WITH NOWAIT;

		EXEC(@CMD)
	END
	ELSE
		RAISERROR(N'Max2000_%d already exists',0,1,@DBNumber)

	SET @DBNumber = @DBNumber + 1

END
GO