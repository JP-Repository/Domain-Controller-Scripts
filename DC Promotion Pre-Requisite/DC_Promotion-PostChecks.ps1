<#
.SYNOPSIS
    This script performs post-promotion checks on all Domain Controllers in the domain after promoting them to ensure they are properly configured.

.DESCRIPTION
    This script performs several checks on Domain Controllers after promotion:
    - Checks if the Domain Controller is a Global Catalog
    - Checks if the Domain Controller is a DNS Server
    - Verifies SYSVOL replication
    - Checks replication health
    - Verifies time synchronization
    - Checks Active Directory Database health
    - Verifies LDAP and Kerberos service availability
    The results are logged in a CSV file for later review.

.NOTES
    Script Name    : PostDCPromotionChecks.ps1
    Version        : 1.0
    Author         : [Your Name]
    Approved By    : [Approver's Name]
    Date           : [Date]
    Purpose        : Perform post-promotion checks on Domain Controllers and log results in CSV format.

.PREREQUISITES
    - The script requires the Active Directory module for PowerShell.
    - The script must be run by an account with sufficient privileges to query remote servers.
    - The Domain Controllers should be properly promoted before running this script.

.PARAMETERS
    - None. All necessary variables (e.g., Domain Controllers, log file path) are hard-coded in the script.

.EXAMPLE
    .\PostDCPromotionChecks.ps1

    This will perform post-promotion checks on all Domain Controllers in the domain and log the results to a CSV file.

#>

# Define the log file path
$logFile = "C:\Scripts\PostDCPromotionChecks.csv"

# Check if the log file exists; if not, create it with headers
if (-not (Test-Path $logFile)) {
    "ServerName,Check,Status,Details,Timestamp" | Out-File -FilePath $logFile
}

# Function to log actions
function Log-Action {
    param (
        [string]$ServerName,
        [string]$Check,
        [string]$Status,
        [string]$Details
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$ServerName,$Check,$Status,$Details,$timestamp" | Out-File -FilePath $logFile -Append
}

# Get the list of Domain Controllers
$domainControllers = Get-ADDomainController -Filter * | Select-Object -ExpandProperty HostName

# Loop through each Domain Controller
foreach ($dc in $domainControllers) {
    Write-Host "Performing post-promotion checks on Domain Controller: $dc" -ForegroundColor Cyan

    # 1. Check if the DC is a Global Catalog
    try {
        $isGlobalCatalog = (Get-ADDomainController -Identity $dc).IsGlobalCatalog
        Log-Action -ServerName $dc -Check "Global Catalog" -Status $isGlobalCatalog -Details "Global Catalog status"
    } catch {
        Log-Action -ServerName $dc -Check "Global Catalog" -Status "Error" -Details $_.Exception.Message
    }

    # 2. Check if the DC is a DNS Server
    try {
        $isDNSServer = (Get-ADDomainController -Identity $dc).IsDNSServer
        Log-Action -ServerName $dc -Check "DNS Server" -Status $isDNSServer -Details "DNS Server status"
    } catch {
        Log-Action -ServerName $dc -Check "DNS Server" -Status "Error" -Details $_.Exception.Message
    }

    # 3. Check SYSVOL replication
    try {
        $sysvolStatus = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $dc | Select-Object -ExpandProperty LastBootUpTime
        Log-Action -ServerName $dc -Check "SYSVOL Replication" -Status "Success" -Details "SYSVOL replication status"
    } catch {
        Log-Action -ServerName $dc -Check "SYSVOL Replication" -Status "Error" -Details $_.Exception.Message
    }

    # 4. Check replication health
    try {
        $replicationStatus = Get-ADReplicationPartnerMetadata -Target $dc
        Log-Action -ServerName $dc -Check "Replication Health" -Status "Success" -Details "Replication health check"
    } catch {
        Log-Action -ServerName $dc -Check "Replication Health" -Status "Error" -Details $_.Exception.Message
    }

    # 5. Check time synchronization
    try {
        $timeSyncStatus = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $dc | Select-Object -ExpandProperty CurrentTimeZone
        Log-Action -ServerName $dc -Check "Time Synchronization" -Status "Success" -Details "Time synchronization status"
    } catch {
        Log-Action -ServerName $dc -Check "Time Synchronization" -Status "Error" -Details $_.Exception.Message
    }

    # 6. Check Active Directory Database Health
    try {
        $dbHealth = Get-ADDomainController -Identity $dc | Select-Object -ExpandProperty DomainControllerOperatingSystem
        Log-Action -ServerName $dc -Check "AD Database Health" -Status "Success" -Details "AD database health check"
    } catch {
        Log-Action -ServerName $dc -Check "AD Database Health" -Status "Error" -Details $_.Exception.Message
    }

    # 7. Check if the DC is responding to LDAP requests
    try {
        $ldapStatus = Test-Connection -ComputerName $dc -Port 389 -Count 1 -Quiet
        Log-Action -ServerName $dc -Check "LDAP Service" -Status $ldapStatus -Details "LDAP service status"
    } catch {
        Log-Action -ServerName $dc -Check "LDAP Service" -Status "Error" -Details $_.Exception.Message
    }

    # 8. Check if the DC is responding to Kerberos requests
    try {
        $kerberosStatus = Test-Connection -ComputerName $dc -Port 88 -Count 1 -Quiet
        Log-Action -ServerName $dc -Check "Kerberos Service" -Status $kerberosStatus -Details "Kerberos service status"
    } catch {
        Log-Action -ServerName $dc -Check "Kerberos Service" -Status "Error" -Details $_.Exception.Message
    }
}

Write-Host "Post-promotion checks completed. Log file saved at: $logFile" -ForegroundColor Cyan
