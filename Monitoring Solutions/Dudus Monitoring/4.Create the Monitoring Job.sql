USE [msdb]
GO
DECLARE 
	@owner_login_name NVARCHAR(1000)= SUSER_NAME(),
	@notify_email_operator_name NVARCHAR(1000)= N'DBA'

DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'Monitoring', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@owner_login_name, 
		@notify_email_operator_name=@notify_email_operator_name, @job_id = @jobId OUTPUT
select @jobId

EXEC msdb.dbo.sp_add_jobserver @job_name=N'Monitoring', @server_name = @@SERVERNAME

EXEC msdb.dbo.sp_add_jobstep @job_name=N'Monitoring', @step_name=N'Monitor', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE	@MonitoringAlerts [dbo].[udt_IntTable]
EXEC [Report].[usp_GenerateMonitoringReport] @MonitoringAlerts=@MonitoringAlerts', 
		@database_name=N'DB_DBA', 
		@flags=0

EXEC msdb.dbo.sp_update_job @job_name=N'Monitoring', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@owner_login_name, 
		@notify_email_operator_name=@notify_email_operator_name, 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''

DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'Monitoring', @name=N'Every 1 Min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20141130, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
