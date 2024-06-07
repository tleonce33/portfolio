SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

You may need to set these in order to use master.dbo.xp_fileexist

-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO
-- To update the currently configured value for advanced options.
RECONFIGURE
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1
GO
-- To update the currently configured value for this feature.
RECONFIGURE
GO

*/

IF OBJECT_ID('fn_CheckFileExists','FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_CheckFileExists];
GO
CREATE FUNCTION [dbo].[fn_CheckFileExists] (
     @xFilePath VARCHAR(1000)
    ,@xFileName VARCHAR(1000)
)
RETURNS INT
AS
-- =============================================
-- Author:      Tanya Leonce
-- Create date: <Create Date>
-- Description: Checks if a File Exists based on @FileName and @FilePath
--              Return BIT Value:
--                  0 = False (File Does Not Exist)
--                  1 = True (File Exists)
-- Command: fn_CheckFileExists(@FilePath, @FileName)
-- =============================================
BEGIN

    --=============================================
    -- Declare Variables
    --=============================================
    DECLARE @FileExists INT = 0;
    DECLARE @FilePath   VARCHAR(1000) = @xFilePath;
    DECLARE @FileName   VARCHAR(1000) = @xFileName;
    DECLARE @FullPath   VARCHAR(2000) = '';

    --=================================================
    -- Clean File Name and set File Path + File Name
    --=================================================
    SET @FileName = dbo.fn_CleanFileName(@FileName);
    SET @FullPath = ISNULL(@FilePath,'') + ISNULL(@FileName,'');

    --=================================================
    -- Check if File Exists using xp_fileexist
    --=================================================
    EXEC master.dbo.xp_fileexist @FullPath, @FileExists OUT;

    -- Return @FileExists
    RETURN @FileExists;
END
GO
