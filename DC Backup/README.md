# Automated Windows Server Backup & Notification Scripts

# Overview

This solution includes two PowerShell scripts that work together to automate Windows Server Backup and notify administrators upon successful completion.

# Script Details

1. Automated-WindowsBackup.ps1

Purpose: Performs a full system backup using wbadmin and enforces a retention policy by deleting old backups.

# Backup Target: Remote UNC path (e.g., \\ServerName\Backups).

Retention: Deletes backups older than a specified number of days (default: 2 days).

Logging: Backup operation output is logged to BackupLog.txt.

2. Monitor-WindowsBackup.ps1

Purpose: Monitors for successful completion of Windows Server Backup by checking for Event ID 4.

Notification: Sends an email to the specified recipient with backup status and the list of available backup folders.

SMTP: Requires access to a configured SMTP server for email delivery.

# Prerequisites

Before running or scheduling the scripts, ensure the following:

- Windows Server Backup feature is installed.
- The backup target directory is accessible and write-permitted.
- Scripts are run with administrative privileges.
- SMTP server is reachable from the host.
- Credentials or mail relay access is configured if authentication is needed.

# Scheduling in Task Scheduler

- Both scripts should be scheduled in Task Scheduler to run one after the other:

# Recommended Order:

# Automated-WindowsBackup.ps1

- Run Daily (e.g., at 1:00 AM).
- Ensure it completes before triggering the second script.
- Run with highest privileges.

# Monitor-WindowsBackup.ps1

- Run Daily (e.g., at 2:00 AM).
- This script relies on the backup being completed.
- Run with highest privileges.

# Settings for Both Tasks:

Action: Start a program → powershell.exe

# Arguments:

-ExecutionPolicy Bypass -File "C:\Scripts\Automated-WindowsBackup.ps1"

(Adjust the path and filename accordingly.)

- Run whether user is logged on or not
- Run with highest privileges
- Logs and Output
- Backup Log: BackupLog.txt stored in the backup directory.
- Email Subject: "ALERT: Daily Windows Server Backup Completed"
- Backup List: Sent as part of the email body with backup folder names.

# Author

Jonathan Preetham

