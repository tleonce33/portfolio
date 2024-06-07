SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('sp_LEDES98B_Import','P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_LEDES98B_Import];
GO
CREATE PROCEDURE [dbo].[sp_LEDES98B_Import]
     @xFilePath VARCHAR(1000) = ''
    ,@xFileName VARCHAR(1000) = ''
AS
SET NOCOUNT ON;
-- =============================================
-- Author:      Tanya Leonce
-- Create date: <Create Date>
-- Description: Parse LEDES 98B Fixed Width/Fixed Length File, apply transformations, and load into database
-- =============================================
BEGIN

    --==================================================
    -- Declare Variables
    --==================================================
    DECLARE    @FilePath VARCHAR(1000) = @xFilePath,
               @FileName VARCHAR(1000) = dbo.fn_CleanFileName(@xFileName),
               @FullPath VARCHAR(1000) = '',
               @sCMD     VARCHAR(8000) = '';

    SET @FullPath = @FilePath + @FileName;

    --==================================================
    -- Create Table for Error Reporting
    --==================================================
    IF object_id('U_LEDES98B_Errors','U') IS NOT NULL
        DROP TABLE dbo.U_LEDES98B_Errors;
    CREATE TABLE dbo.U_LEDES98B_Errors (
         tblAction VARCHAR(50) NULL
        ,tblError VARCHAR(MAX) NULL
    );

    --==================================================
    -- File Validation - Check if File Exists
    --==================================================
    IF (dbo.fn_CheckFileExists(@FilePath, @FileName) = 0)
    BEGIN
        -- Report Error: No Files Exists
        INSERT INTO dbo.U_LEDES98B_Errors (tblAction, tblError)
        SELECT tblAction = 'REJECTED'
            ,tblError = CASE WHEN @FileName = '' THEN 'Import filename is blank. Import Cancelled.'
                             ELSE 'Import FileName: "' + @FileName + '" Does Not Exist In Import Folder ("' + @FilePath + '").  Import Cancelled.'
                        END;

        -- Stop Processing
        RETURN;
    END;

    --==================================================
    -- Load file into a _Raw table for Staging
    --==================================================
    BEGIN TRY
        --===========================================
        -- Create _Raw Table via BULK INSERT
        --===========================================
        IF OBJECT_ID('U_LEDES98B_Raw','U') IS NOT NULL
            DROP TABLE dbo.U_LEDES98B_Raw;
        CREATE TABLE dbo.U_LEDES98B_Raw (
             Field1 VARCHAR(100)
            ,Field2 VARCHAR(100)
            ,Field3 VARCHAR(100)
            ,Field4 VARCHAR(100)
            ,Field5 VARCHAR(100)
            ,Field6 VARCHAR(100)
            ,Field7 VARCHAR(100)
            ,Field8 VARCHAR(100)
            ,Field9 VARCHAR(100)
            ,Field10 VARCHAR(100)
            ,Field11 VARCHAR(100)
            ,Field12 VARCHAR(100)
            ,Field13 VARCHAR(100)
            ,Field14 VARCHAR(100)
            ,Field15 VARCHAR(100)
            ,Field16 VARCHAR(100)
            ,Field17 VARCHAR(100)
            ,Field18 VARCHAR(100)
            ,Field19 VARCHAR(100)
            ,Field20 VARCHAR(100)
            ,Field21 VARCHAR(100)
            ,Field22 VARCHAR(100)
            ,Field23 VARCHAR(100)
            ,Field24 VARCHAR(100)
        );

        --BULK INSERT INTO RAW DATA TABLE
        -- NOTE: Set FIRSTROW = 2, If Header Exists In Import File (Header Row is Skipped)
        SELECT @sCMD = 'BULK INSERT '+ RTRIM(DB_NAME()) + '.dbo.U_LEDES98B_Raw' +
                       ' FROM ''' + @FullPath + '''' +
                       ' WITH (FIRSTROW = 2, FIELDTERMINATOR = ''|'',ROWTERMINATOR = ''[]\n'')';
        EXEC  (@sCMD);

        --==================================
        -- ARCHIVE FILES AFTER PROCESSING
        --==================================
        DECLARE @ArchiveCmd VARCHAR(8000), @NewFileName VARCHAR(200);

        -- Add Date/Time Stamp to FileName (YYYYMMDDHHMMSS)
        SET @NewFileName = @FileName + '.' + CONVERT(CHAR(8),GETDATE(),112) + REPLACE(CONVERT(VARCHAR(10),GETDATE(),108),':',SPACE(0));

        -- Copy Existing File to New File Name with Date/Time Stamp
        SET @ArchiveCmd = 'COPY ""' + @FilePath + @FileName + '"" ""' + @FilePath + @NewFileName + '""';
        PRINT 'Archive File Command: ' + ISNULL(@ArchiveCmd,'');
        EXEC master.dbo.xp_cmdshell @ArchiveCmd, NO_OUTPUT;
    END TRY
    BEGIN CATCH
       -- Report SQL Error in Error Report File
       INSERT INTO dbo.U_LEDES98B_Errors (tblAction, tblError)
       SELECT tblAction = 'REJECTED'
            ,tblError = 'Error Importing File for Staging: ' + ISNULL(ERROR_MESSAGE(),'');

       -- Stop Processing
       RETURN;
    END CATCH;

    --===============================================================
    -- Load _Raw Data into _Import Table for Cleaning/Transforming
    --===============================================================
    BEGIN TRY
        IF OBJECT_ID('U_LEDES98B_Import','U') IS NOT NULL
            DROP TABLE dbo.U_LEDES98B_Import;
        SELECT
             fld_INVOICE_DATE  = CONVERT(DATE,LTRIM(RTRIM(Field1)))
            ,fld_INVOICE_NUMBER  = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field2)))
            ,fld_CLIENT_ID  = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field3)))
            ,fld_LAW_FIRM_MATTER_ID  = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field4)))
            ,fld_INVOICE_TOTAL  = CONVERT(DECIMAL(12,4),LTRIM(RTRIM(Field5)))
            ,fld_BILLING_START_DATE  = CONVERT(DATE,LTRIM(RTRIM(Field6)))
            ,fld_BILLING_END_DATE  = CONVERT(DATE,LTRIM(RTRIM(Field7)))
            ,fld_INVOICE_DESCRIPTION  = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field8)))
            ,fld_LINE_ITEM_NUMBER  = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field9)))
            ,fld_EXP_FEE_INV_ADJ_TYPE = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field10)))
            ,fld_LINE_ITEM_NUMBER_OF_UNITS = CONVERT(DECIMAL(10,4),LTRIM(RTRIM(Field11)))
            ,fld_LINE_ITEM_ADJUSTMENT_AMOUNT = CONVERT(DECIMAL(10,4),LTRIM(RTRIM(Field12)))
            ,fld_LINE_ITEM_TOTAL = CONVERT(DECIMAL(10,4),LTRIM(RTRIM(Field13)))
            ,fld_LINE_ITEM_DATE = CONVERT(DATE,LTRIM(RTRIM(Field14)))
            ,fld_LINE_ITEM_TASK_CODE = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field15)))
            ,fld_LINE_ITEM_EXPENSE_CODE = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field16)))
            ,fld_LINE_ITEM_ACTIVITY_CODE = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field17)))
            ,fld_TIMEKEEPER_ID = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field18)))
            ,fld_LINE_ITEM_DESCRIPTION = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field19)))
            ,fld_LAW_FIRM_ID = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field20)))
            ,fld_LINE_ITEM_UNIT_COST = CONVERT(DECIMAL(10,4),LTRIM(RTRIM(Field21)))
            ,fld_TIMEKEEPER_NAME = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field22)))
            ,fld_TIMEKEEPER_CLASSIFICATION = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field23)))
            ,fld_CLIENT_MATTER_ID = CONVERT(VARCHAR(100),LTRIM(RTRIM(Field24)))
            ,fld_KeyID = CONVERT(INT,NULL)
        INTO dbo.U_LEDES98B_Import
        FROM dbo.U_LEDES98B_Raw;
    END TRY
    BEGIN CATCH
       -- Report SQL Error in Error Report File
       INSERT INTO dbo.U_LEDES98B_Errors (tblAction, tblError)
       SELECT tblAction = 'REJECTED'
            ,tblError = 'Error Preparing File for Importing: ' + ISNULL(ERROR_MESSAGE(),'');

       -- Stop Processing
       RETURN;
    END CATCH;

    --================================================
    -- Load / Import data into Table in Database
    --================================================
    --==================================================
    -- Import data into [dbo].[trans_header] Table
    --==================================================
    BEGIN TRY
        WITH CTE_Invoice
        AS (
            SELECT DISTINCT fld_CLIENT_ID
                ,fld_LAW_FIRM_MATTER_ID
                ,fld_INVOICE_NUMBER
                ,fld_INVOICE_DESCRIPTION
                ,fld_INVOICE_DATE
                ,fld_INVOICE_TOTAL
                ,fld_LAW_FIRM_ID
            FROM dbo.U_LEDES98B_Import
        )

        MERGE dbo.[trans_header] TargetTable
        USING CTE_Invoice SourceTable
            ON CONCAT(SourceTable.fld_CLIENT_ID,SourceTable.fld_LAW_FIRM_MATTER_ID) = TargetTable.[reference_id]
        -- If Records Match Between Source/Target Tables based on JOIN criteria, then UPDATE Target Table
        WHEN MATCHED THEN
            UPDATE
                SET TargetTable.[reference_id] = CONCAT(SourceTable.fld_CLIENT_ID,SourceTable.fld_LAW_FIRM_MATTER_ID)
                   ,TargetTable.[case_id] = CONVERT(INT,SourceTable.fld_LAW_FIRM_MATTER_ID)
                   ,TargetTable.[client_id] = CONVERT(INT,SourceTable.fld_CLIENT_ID)
                   ,TargetTable.[trans_header_name] = CONCAT('Invoice# ',CONVERT(VARCHAR(100),SourceTable.fld_INVOICE_NUMBER))
                   ,TargetTable.[description]= SourceTable.fld_INVOICE_DESCRIPTION
                   ,TargetTable.[date] = CONVERT(VARCHAR(25),SourceTable.fld_INVOICE_DATE)
                   ,TargetTable.[amount] = CONVERT(CHAR(15),SourceTable.fld_INVOICE_TOTAL)        
                   ,TargetTable.[is_billable] = 1
                   ,TargetTable.[external_id] = CONVERT(INT,REPLACE(SourceTable.fld_LAW_FIRM_ID,'-',''))
        -- If Records Match Between Source/Target Tables based on JOIN criteria, then INSERT into Target Table
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ([reference_id],[case_id],[client_id],[trans_header_name],[description],[date],[amount],[is_billable],[external_id])
            VALUES (CONCAT(SourceTable.fld_CLIENT_ID,SourceTable.fld_LAW_FIRM_MATTER_ID) --[reference_id]
                ,CONVERT(INT,SourceTable.fld_LAW_FIRM_MATTER_ID) --[case_id]
                ,CONVERT(INT,SourceTable.fld_CLIENT_ID) --[client_id]
                ,CONCAT('Invoice# ',CONVERT(VARCHAR(100),SourceTable.fld_INVOICE_NUMBER)) --[trans_header_name]
                ,SourceTable.fld_INVOICE_DESCRIPTION --[description]
                ,SourceTable.fld_INVOICE_DATE --[date]
                ,SourceTable.fld_INVOICE_TOTAL --[amount]
                ,1 --[is_billable]
                ,CONVERT(INT,REPLACE(SourceTable.fld_LAW_FIRM_ID,'-','')) --[external_id]
            );
    END TRY
    BEGIN CATCH
       -- Report SQL Error in Error Report File
       INSERT INTO dbo.U_LEDES98B_Errors (tblAction, tblError)
       SELECT tblAction = 'REJECTED'
            ,tblError = 'Error Importing Records into [dbo].[trans_header] table: ' + ISNULL(ERROR_MESSAGE(),'');

       -- Stop Processing
       RETURN;
    END CATCH;

    --===============================================================
    -- Update Import.fld_KeyID = [trans_header].[trans_header_id]
    --===============================================================
    UPDATE dbo.U_LEDES98B_Import
    SET fld_KeyID = (SELECT [trans_header_id] FROM [dbo].[trans_header] WHERE [trans_header].[reference_id] = CONCAT(U_LEDES98B_Import.fld_CLIENT_ID,U_LEDES98B_Import.fld_LAW_FIRM_MATTER_ID));

    --==================================================
    -- Import data into [dbo].[trans_detail] Table
    --==================================================
    BEGIN TRY
        MERGE dbo.[trans_detail] TargetTable
        USING dbo.U_LEDES98B_Import SourceTable
            ON CONCAT(SourceTable.fld_CLIENT_ID,SourceTable.fld_LAW_FIRM_MATTER_ID) = TargetTable.[reference_id]
            AND CONVERT(INT,fld_LINE_ITEM_NUMBER) = TargetTable.[trans_line_no]
        -- If Records Match Between Source/Target Tables based on JOIN criteria, then UPDATE Target Table
        WHEN MATCHED THEN
            UPDATE
                SET TargetTable.[trans_header_id] = SourceTable.fld_KeyID
                   ,TargetTable.[trans_line_no] = CONVERT(INT,fld_LINE_ITEM_NUMBER)
                   ,TargetTable.[reference_id] = CONCAT(SourceTable.fld_CLIENT_ID,SourceTable.fld_LAW_FIRM_MATTER_ID)
                   ,TargetTable.[trans_detail_name] = SourceTable.fld_INVOICE_DESCRIPTION
                   ,TargetTable.[description]= SourceTable.fld_LINE_ITEM_DESCRIPTION
                   ,TargetTable.[date] = SourceTable.fld_INVOICE_DATE
                   ,TargetTable.[hours] = SourceTable.fld_LINE_ITEM_NUMBER_OF_UNITS
                   ,TargetTable.[rate] = SourceTable.fld_LINE_ITEM_UNIT_COST
                   ,TargetTable.[amount] = SourceTable.fld_LINE_ITEM_TOTAL
                   ,TargetTable.[trans_type_id] = 4 --[trans_type_id] where 4 = Invoice
                   ,TargetTable.[is_billable] = 1
                   ,TargetTable.[external_id] = CONVERT(INT,REPLACE(SourceTable.fld_LAW_FIRM_ID,'-',''))
        -- If Records Match Between Source/Target Tables based on JOIN criteria, then INSERT into Target Table
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ([trans_header_id],[trans_line_no],[reference_id],[trans_detail_name],[description],[date],[hours],[rate],[amount],[trans_type_id],[is_billable],[external_id])
            VALUES (SourceTable.fld_KeyID --[trans_header_id]
                ,CONVERT(INT,fld_LINE_ITEM_NUMBER) --[trans_line_no]
                ,CONCAT(SourceTable.fld_CLIENT_ID,SourceTable.fld_LAW_FIRM_MATTER_ID) --[reference_id]
                ,SourceTable.fld_INVOICE_DESCRIPTION --[trans_detail_name]
                ,SourceTable.fld_LINE_ITEM_DESCRIPTION --[description]
                ,SourceTable.fld_INVOICE_DATE --[date]
                ,SourceTable.fld_LINE_ITEM_NUMBER_OF_UNITS --[hours]
                ,SourceTable.fld_LINE_ITEM_UNIT_COST --[rate]
                ,SourceTable.fld_LINE_ITEM_TOTAL --[amount]
                ,4 --[trans_type_id] where 4 = Invoice
                ,1 --[is_billable]
                ,CONVERT(INT,REPLACE(SourceTable.fld_LAW_FIRM_ID,'-','')) --[external_id]
            );
    END TRY
    BEGIN CATCH
       -- Report SQL Error in Error Report File
       INSERT INTO dbo.U_LEDES98B_Errors (tblAction, tblError)
       SELECT tblAction = 'REJECTED'
            ,tblError = 'Error Importing Records into [dbo].[trans_detail] table: ' + ISNULL(ERROR_MESSAGE(),'');

       -- Stop Processing
       RETURN;
    END CATCH;

    --==================================================
    -- Import data into [dbo].[invoice] Table
    --==================================================
    BEGIN TRY
        WITH CTE_Invoice
        AS (
            SELECT DISTINCT fld_CLIENT_ID
                ,fld_LAW_FIRM_MATTER_ID
                ,fld_INVOICE_NUMBER
                ,fld_INVOICE_DESCRIPTION
                ,fld_INVOICE_DATE
                ,fld_INVOICE_TOTAL
                ,fld_LAW_FIRM_ID
                ,fld_KeyID
            FROM dbo.U_LEDES98B_Import
        )

        MERGE dbo.invoice TargetTable
        USING CTE_Invoice SourceTable
            ON SourceTable.fld_LAW_FIRM_MATTER_ID = TargetTable.[case_id]
            AND SourceTable.fld_CLIENT_ID = TargetTable.[client_id]
        -- If Records Match Between Source/Target Tables based on JOIN criteria, then UPDATE Target Table
        WHEN MATCHED THEN
            UPDATE
                SET TargetTable.[case_id] = CONVERT(INT,SourceTable.fld_LAW_FIRM_MATTER_ID)
                   ,TargetTable.[client_id] = CONVERT(INT,SourceTable.fld_CLIENT_ID)
                   ,TargetTable.[trans_header_id] = SourceTable.fld_KeyID
                   ,TargetTable.[invoice_number] = SourceTable.fld_INVOICE_NUMBER
                   ,TargetTable.[date] = SourceTable.fld_INVOICE_DATE
                   ,TargetTable.[amount] = SourceTable.fld_INVOICE_TOTAL
                   ,TargetTable.[comments] = SourceTable.fld_INVOICE_DESCRIPTION
                   ,TargetTable.[invoice_type_id] = 1 --1 = Client
                   ,TargetTable.[status_type_id] = 4 --4 = Invoiced
                   ,TargetTable.[trans_type_id] = 4 --4 = Invoice
                   ,TargetTable.[external_id] = CONVERT(INT,REPLACE(SourceTable.fld_LAW_FIRM_ID,'-',''))
        -- If Records Match Between Source/Target Tables based on JOIN criteria, then INSERT into Target Table
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ([case_id],[client_id],[trans_header_id],[invoice_number],[date],[amount],[comments],[invoice_type_id],[status_type_id],[trans_type_id],[external_id])
            VALUES (CONVERT(INT,SourceTable.fld_LAW_FIRM_MATTER_ID) --[case_id]
                ,CONVERT(INT,SourceTable.fld_CLIENT_ID) --[client_id]
                ,SourceTable.fld_KeyID --[trans_header_id]
                ,SourceTable.fld_INVOICE_NUMBER --[invoice_number]
                ,SourceTable.fld_INVOICE_DATE --[date]
                ,SourceTable.fld_INVOICE_TOTAL --[amount]
                ,SourceTable.fld_INVOICE_DESCRIPTION --[comments]
                ,1 --[invoice_type_id] where 1 = Client
                ,4 --[status_type_id] where 4 = Invoiced
                ,4 --[trans_type_id] where 4 = Invoice
                ,CONVERT(INT,REPLACE(SourceTable.fld_LAW_FIRM_ID,'-','')) --[external_id]
            );
    END TRY
    BEGIN CATCH
       -- Report SQL Error in Error Report File
       INSERT INTO dbo.U_LEDES98B_Errors (tblAction, tblError)
       SELECT tblAction = 'REJECTED'
            ,tblError = 'Error Importing Records into [dbo].[invoice] table: ' + ISNULL(ERROR_MESSAGE(),'');

       -- Stop Processing
       RETURN;
    END CATCH;

END
GO
