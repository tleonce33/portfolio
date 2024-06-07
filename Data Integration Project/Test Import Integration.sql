
-- =====================================================================
-- Test the Integration by calling the SP and viewing the information
-- =====================================================================

--==================================================
-- Declare Variables & Run Import Process
--==================================================
DECLARE    @FilePath VARCHAR(1000) = '{Folder Path}',
           @FileName VARCHAR(1000) = 'Ledes98B-Sample-File-Rev-7-2014.txt';


-- Run the Import Process
[dbo].[sp_LEDES98B_Import] @FilePath, @FileName;

--==========================================================
-- Check tables for errors and validate tables are loaded
--==========================================================

-- Check for Errors
SELECT * FROM [dbo].[U_LEDES98B_Errors];

-- Check for Invoices Table
SELECT * FROM [dbo].[invoice] WHERE [case_id] = 528;
SELECT * FROM [dbo].[invoice] WHERE [case_id] = 1326;

-- Check for Transaction Header & Detail for Invoice# 0528
SELECT * FROM [dbo].[trans_header] WHERE reference_id = 7110528;
SELECT * FROM [dbo].[trans_detail] WHERE reference_id = 7110528;

-- Check for Transaction Header & Detail for Invoice# 1326
SELECT * FROM [dbo].[trans_header] WHERE reference_id = 7111326;
SELECT * FROM [dbo].[trans_detail] WHERE reference_id = 7111326;

