SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('fn_CleanFileName','FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_CleanFileName];
GO
CREATE FUNCTION [dbo].[fn_CleanFileName] (
     @xFileName VARCHAR(1000)
)
RETURNS VARCHAR(1000)
AS
-- =============================================
-- Author:      Tanya Leonce
-- Create date: <Create Date>
-- Description: Removes File Path from @FileName value and returns Cleaned File Name
-- Command: fn_CleanFileName (@FileName)
-- =============================================
BEGIN

    --=============================================
    -- Remove File Path if provided in @FileName
    --=============================================
    DECLARE @FileName VARCHAR(1000) = @xFileName;

    -- Get FileName if @FileName Contains back slash '\'
    IF (CHARINDEX('\',REVERSE(@FileName)) > 0)
    BEGIN
        SET @FileName = REVERSE(LEFT(REVERSE(@FileName),CHARINDEX('\',REVERSE(@FileName))-1));
    END;

    -- Get FileName if @FileName Contains forward slash '/'
    IF (CHARINDEX('/',REVERSE(@FileName)) > 0)
    BEGIN
        SET @FileName = REVERSE(LEFT(REVERSE(@FileName),CHARINDEX('/',REVERSE(@FileName))-1));
    END;

    -- Return @FileName
    RETURN @FileName;

END
GO
