/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (2000)

      [LoginID]
      ,[Organization]
      ,[Password]
      ,[FullName]
      ,[Description]
      ,[HomeDir]

  FROM [DB_FTP].[dbo].[SUUsers]