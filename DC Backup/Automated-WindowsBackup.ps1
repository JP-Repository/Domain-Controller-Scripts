<#
.SYNOPSIS
    Automates Windows Server Backup and manages retention policy.

.DESCRIPTION
    This script performs a full system backup using wbadmin, storing backups in a specified 
    remote location. It also enforces a retention policy by deleting backups older than 
    the specified number of days.

.NOTES
    Script Name    : Automated-WindowsBackup.ps1
    Version        : 0.1
    Author         : Jonathan Preetham
    Approved By    : 
    Date           : 
    Purpose        : Automates full system backup and manages old backups.

.PREREQUISITES
    - Windows Server Backup must be installed.
    - The specified backup location must be accessible.
    - The script should be executed with administrative privileges.

.PARAMETERS
    None.

.EXAMPLE
    Run the script manually or configure it as a scheduled task:
    
    `.\Automated-WindowsBackup.ps1`
#>

# Start of Script

# Define Backup Location (Change as needed)
$BackupTarget = "\\ServerName\Backups"  # UNC path of remote location
$LogFile = "$BackupTarget\BackupLog.txt"
$RetentionDays = 2  # Number of days to keep backups

# Delete backups older than the retention period
Get-ChildItem $BackupTarget -Directory | Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-$RetentionDays) } | Remove-Item -Recurse -Force

# Create a timestamp for the backup folder
$Timestamp = Get-Date -Format "dd-MM-yyyy"
$BackupFolder = "$BackupTarget\ServerName_$Timestamp"

# Ensure Backup Folder Exists
if (!(Test-Path $BackupFolder)) {
    New-Item -ItemType Directory -Path $BackupFolder | Out-Null
}

# Perform Full System Backup
wbadmin start backup -backupTarget:$BackupFolder -allCritical -systemState -quiet >> $LogFile 2>&1



# End of Script
