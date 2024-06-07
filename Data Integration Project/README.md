# Data Integration Project

This data integration project will take a pipe delimited file and import it into a sample database.

## Overview

The LEDES is a global standard in legal data exchange, which defines a e-billing file format for 98B.  The 98B file format can be found here: https://ledes.org/ledes-98b-format/.  There is a sample file available for download, which is used as part of this data integration project.


## Prerequisites

Before you begin, make sure you perform the following steps:

- Restore the sample database backup: PROJECTDB.bak to a SQL Server database engine.
- Deploy the 2 functions in the database: dbo.fn_CheckFileExists, dbo.fn_CleanFileName
- Deploy the stored procedure in the database: dbo.sp_LEDES98B_Import
- Download the sample file: Ledes98B-Sample-File-Rev-7-2014.txt

## How to Run This Project

1. Open SSMS (SQL Server Management Studio)
2. Connect to the PROJECTDB database.
3. Open the script: Test Import Integration.sql
4. Enter the Folder Path in the @FilePath variable in the script.
5. Run the stored procedure to run the import process: [dbo].[sp_LEDES98B_Import] @FilePath, @FileName;
6. View errors and validate the data was populated in the database tables accordingly.

## Lessons Learned

This was an interesting project as the row terminator was [] and line break (CRLF), which is rare in the years I've dealt with flat files. Most files nowadays are CSV (comma separated) and this one is pipe delimited, which wasn't too challenging but different than the norm. I am glad I was able to leverage the database from my data modeling project with this project.

## Contact

Please feel free to contact me if you have any questions at: [LinkedIn](https://www.linkedin.com/in/tanya-leonce/)
