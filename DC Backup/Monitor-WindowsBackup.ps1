<#
.SYNOPSIS
    Monitors Windows Server Backup completion and sends an email notification.

.DESCRIPTION
    This script checks for the latest Windows Server Backup completion event (Event ID 4)
    and sends an email notification to specified recipients.

.NOTES
    Script Name    : Monitor-WindowsBackup.ps1
    Version        : 0.2
    Author         : Jonathan Preetham
    Approved By    : 
    Date           : 10/02/2025
    Modified       : 13/04/2025
    Purpose        : Sends an email notification when a full backup completes successfully.

.PREREQUISITES
    - Windows Server Backup must be configured.
    - SMTP server should be accessible for email notifications.
    - Required permissions to read event logs.

.PARAMETERS
    None.

.EXAMPLE
    Run the script manually or configure it as a scheduled task:
    
    `.​Monitor-WindowsBackup.ps1`
#>
# Start of Script

# Get the hostname of the machine where the script is running
$HostName = hostname

# Define the Event ID for a successful Windows Server Backup completion
$EventId = 4  
# Define the name of the event log to check
$BackupLogName = "Microsoft-Windows-Backup"

# Fetch the latest event with Event ID 4 (indicating backup completion)
$A = Get-WinEvent -MaxEvents 1 -FilterHashTable @{LogName = $BackupLogName; ID = $EventId}

# Extract relevant details from the event log
$Message = $A.Message  # Message describing the event
$EventID = $A.Id  # Event ID number
$MachineName = $A.MachineName  # Name of the machine where the event occurred
$Source = $A.ProviderName  # Source of the event
$Time = $A.TimeCreated  # Timestamp of the event

# Get the list of available backup folders from the backup directory
$BackupDirectories = Get-ChildItem -Path "\\ServerName\DCBackups" -Directory | Select-Object -ExpandProperty Name

# Convert the list of directories into a formatted string for email
$BackupFoldersList = $BackupDirectories -join "`n"

# Email Notification Parameters
$FromAddress = "Jonathan.Preetham@contoso.com"  # Sender's email address
$ToAddress = "Jonathan.Preetham@contoso.com"  # Recipient's email address (can add more if needed)
$MessageSubject = "ALERT: Daily Windows Server Backup Completed"  # Email subject
$SendingServer = "smtp-contoso.com"  # SMTP server for sending the email

# Construct the email body with event details and backup folders
$MessageBody = @"
Hello there,

Hope your day has started well...

As Scheduled, Windows Server Backup has been completed successfully.

Please find the Event Details below.

Backup Event Details:
------------------------
Event ID     : $EventID
Source       : $Source
Machine Name : $MachineName
Time         : $Time
Message      : $Message

List of Available Backups:
------------------------------------
$BackupFoldersList



Thanks & Regards,
Active Directory Team
Script Has Run From $HostName 
"@

# Create and send the email notification
$SMTPMessage = New-Object System.Net.Mail.MailMessage $FromAddress, $ToAddress, $MessageSubject, $MessageBody
$SMTPClient = New-Object System.Net.Mail.SMTPClient $SendingServer
$SMTPClient.Send($SMTPMessage)

# End of Script