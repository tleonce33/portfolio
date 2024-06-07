USE [PROJECTDB]
GO

------------------------------------------------------------------------------------------------------------------------
/*

DROP TABLE [PROJECTDB].[dbo].[user_security_group]
DROP TABLE [PROJECTDB].[dbo].[security_group]
DROP TABLE [PROJECTDB].[dbo].[users]
DROP TABLE [PROJECTDB].[dbo].[office]
DROP TABLE [PROJECTDB].[dbo].[division]
DROP TABLE [PROJECTDB].[dbo].[address]
DROP TABLE [PROJECTDB].[dbo].[address_type]
DROP TABLE [PROJECTDB].[dbo].[phone_type]
DROP TABLE [PROJECTDB].[dbo].[phone]
DROP TABLE [PROJECTDB].[dbo].[email_type]
DROP TABLE [PROJECTDB].[dbo].[email]
DROP TABLE [PROJECTDB].[dbo].[role]
DROP TABLE [PROJECTDB].[dbo].[employee]
DROP TABLE [PROJECTDB].[dbo].[person]
DROP TABLE [PROJECTDB].[dbo].[company]
DROP TABLE [PROJECTDB].[dbo].[case]
DROP TABLE [PROJECTDB].[dbo].[case_type]
DROP TABLE [PROJECTDB].[dbo].[case_party]
DROP TABLE [PROJECTDB].[dbo].[tasks]
DROP TABLE [PROJECTDB].[dbo].[task_type]
GO

*/
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE [PROJECTDB].[dbo].[users] (
  [user_id] INT IDENTITY(1,1) PRIMARY KEY,
  [user_name] nvarchar(255),
  [is_active] bit,
  [external_id] integer,
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[user_security_group] (
  [user_security_group_id] INT IDENTITY(1,1) PRIMARY KEY,
  [user_id] integer,
  [security_group_id] integer,
  [external_id] integer
)
GO

CREATE TABLE [PROJECTDB].[dbo].[security_group] (
  [security_group_id] INT IDENTITY(1,1) PRIMARY KEY,
  [security_group_name] nvarchar(255),
  [is_active] bit,
  [external_id] integer,
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[office] (
  [office_id] INT IDENTITY(1,1) PRIMARY KEY,
  [office_name] nvarchar(255),
  [address_id] integer,
  [is_active] bit,
  [external_id] integer,
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[division] (
  [division_id] INT IDENTITY(1,1) PRIMARY KEY,
  [division_name] nvarchar(255),
  [is_active] bit,
  [external_id] integer,
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[address] (
  [address_id] INT IDENTITY(1,1) PRIMARY KEY,
  [address_type_id] integer,
  [address_line_1] nvarchar(255),
  [address_line_2] nvarchar(255),
  [address_line_3] nvarchar(255),
  [city] nvarchar(255),
  [state] nvarchar(255),
  [postal_code] nvarchar(255),
  [country] nvarchar(255),
  [external_id] integer,
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[address_type] (
  [address_type_id] INT IDENTITY(1,1) PRIMARY KEY,
  [address_type_name] nvarchar(255),
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[phone_type] (
  [phone_type_id] INT IDENTITY(1,1) PRIMARY KEY,
  [phone_type_name] nvarchar(255),
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[phone] (
  [phone_id] INT IDENTITY(1,1) PRIMARY KEY,
  [phone_type_id] integer,
  [phone_number] nvarchar(255),
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[email_type] (
  [email_type_id] INT IDENTITY(1,1) PRIMARY KEY,
  [email_type_name] nvarchar(255),
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[email] (
  [email_id] INT IDENTITY(1,1) PRIMARY KEY,
  [email_type_id] integer,
  [email_address] nvarchar(255),
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[role] (
  [role_id] INT IDENTITY(1,1) PRIMARY KEY,
  [role_name] nvarchar(255),
  [role_type] nvarchar(255),
  [external_id] integer,
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[employee] (
  [employee_id] INT IDENTITY(1,1) PRIMARY KEY,
  [user_id] integer,
  [company_id] integer,
  [salutation] nvarchar(255),
  [first_name] nvarchar(255),
  [middle_name] nvarchar(255),
  [last_name] nvarchar(255),
  [suffix] nvarchar(255),
  [initials] nvarchar(255),
  [title] nvarchar(255),
  [gender] nvarchar(255),
  [address_1_type_id] integer,
  [address_1_id] integer,
  [address_2_type_id] integer,
  [address_2_id] integer,
  [address_3_type_id] integer,
  [address_3_id] integer,
  [phone_1_type_id] integer,
  [phone_1_id] integer,
  [phone_2_type_id] integer,
  [phone_2_id] integer,
  [phone_3_type_id] integer,
  [phone_3_id] integer,
  [email_1_type_id] integer,
  [email_1_id] integer,
  [email_2_type_id] integer,
  [email_2_id] integer,
  [email_3_type_id] integer,
  [email_3_id] integer,
  [professional_id] nvarchar(255),
  [role_id] integer,
  [is_active] bit,
  [office_id] integer,
  [division_id] integer,
  [external_id] integer,
  [created_at] DATETIME DEFAULT GETDATE(),
  [created_by] nvarchar(255)
)
GO

CREATE TABLE [PROJECTDB].[dbo].[person] (
  [person_id] INT IDENTITY(1,1) PRIMARY KEY,
  [company_id] integer,
  [user_id] integer,
  [salutation] nvarchar(255),
  [first_name] nvarchar(255),
  [middle_name] nvarchar(255),
  [last_name] nvarchar(255),
  [suffix] nvarchar(255),
  [initials] nvarchar(255),
  [title] nvarchar(255),
  [gender] nvarchar(255),
  [address_1_type_id] integer,
  [address_1_id] integer,
  [address_2_type_id] integer,
  [address_2_id] integer,
  [address_3_type_id] integer,
  [address_3_id] integer,
  [phone_1_type_id] integer,
  [phone_1_id] integer,
  [phone_2_type_id] integer,
  [phone_2_id] integer,
  [phone_3_type_id] integer,
  [phone_3_id] integer,
  [email_1_type_id] integer,
  [email_1_id] integer,
  [email_2_type_id] integer,
  [email_2_id] integer,
  [email_3_type_id] integer,
  [email_3_id] integer,
  [professional_id] nvarchar(255),
  [role_id] integer,
  [is_active] bit,
  [is_client] bit,
  [is_billable] bit,
  [external_id] integer,
  [external_company_id] nvarchar(255),
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[company] (
  [company_id] INT IDENTITY(1,1) PRIMARY KEY,
  [company_name] nvarchar(255),
  [address_1_type_id] integer,
  [address_1_id] integer,
  [phone_1_type_id] integer,
  [phone_1_id] integer,
  [phone_2_type_id] integer,
  [phone_2_id] integer,
  [phone_3_type_id] integer,
  [phone_3_id] integer,
  [email_1_type_id] integer,
  [email_1_id] integer,
  [is_active] bit,
  [is_client] bit,
  [is_billable] bit,
  [external_id] integer,
  [external_company_id] nvarchar(255),
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[case] (
  [case_id] INT IDENTITY(1,1) PRIMARY KEY,
  [parent_case_id] integer,
  [case_name] nvarchar(255),
  [case_type_id] integer,
  [case_status] nvarchar(255),
  [external_id] integer,
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[case_type] (
  [case_type_id] INT IDENTITY(1,1) PRIMARY KEY,
  [case_type_name] nvarchar(255),
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[case_party] (
  [case_party_id] INT IDENTITY(1,1) PRIMARY KEY,
  [case_id] integer,
  [employee_id] integer,
  [person_id] integer,
  [company_id] integer,
  [role_id] integer,
  [is_client] bit,
  [is_billable] bit,
  [party_type] nvarchar(255),
  [external_id] integer,
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[tasks] (
  [task_id] INT IDENTITY(1,1) PRIMARY KEY,
  [case_id] integer,
  [task_name] nvarchar(255),
  [task description] nvarchar(max),
  [task_type_id] integer,
  [assignee_id] integer,
  [assignor_id] integer,
  [start_date] datetime,
  [end_date] datetime,
  [duration_in_days] integer,
  [priority] nvarchar(255),
  [status] nvarchar(255),
  [completed_date] datetime,
  [external_id] integer,
  [created_at] DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [PROJECTDB].[dbo].[task_type] (
  [task_type_id] INT IDENTITY(1,1) PRIMARY KEY,
  [task_type_name] nvarchar(255),
  [created_at] DATETIME DEFAULT GETDATE()
)
GO


