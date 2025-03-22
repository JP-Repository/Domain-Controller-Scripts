<#
.SYNOPSIS
    This script checks the DNS configuration (Primary and Secondary DNS IPs) on all Domain Controllers and provides recommendations based on the results.

.DESCRIPTION
    The script checks the DNS configuration on all Domain Controllers in the environment. It verifies that the primary DNS is set to the Domain Controller's IP and that the secondary DNS points to another Domain Controller in the same site. The results, along with recommendations, are logged in a CSV file.

.NOTES
    Script Name    : DNSCheckOnDCs.ps1
    Version        : 1.0
    Author         : [Your Name]
    Approved By    : [Approver's Name]
    Date           : [Date]
    Purpose        : Verify DNS settings on Domain Controllers and log the results.

.PREREQUISITES
    - The script requires the Active Directory module for PowerShell.
    - The script must be run by an account with sufficient privileges to query DNS settings on Domain Controllers.
    - The script assumes the Domain Controllers are running and accessible.

.PARAMETERS
    - None. All necessary variables are hard-coded in the script.

.EXAMPLE
    .\DNSCheckOnDCs.ps1

    This will check the DNS configuration on all Domain Controllers and log the results to a CSV file.

#>

# Start of Script

# Define the log file
$logFile = "C:\Scripts\DNSCheck_Log.csv"

# Check if the log file exists; if not, create it with headers
if (-not (Test-Path $logFile)) {
    "ServerName,PrimaryDNS,SecondaryDNS,Recommendation,Timestamp" | Out-File -FilePath $logFile
}

# Function to log actions
function Log-Action {
    param (
        [string]$ServerName,
        [string]$PrimaryDNS,
        [string]$SecondaryDNS,
        [string]$Recommendation
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$ServerName,$PrimaryDNS,$SecondaryDNS,$Recommendation,$timestamp" | Out-File -FilePath $logFile -Append
}

# Get all Domain Controllers
$domainControllers = Get-ADDomainController -Filter * | Select-Object -ExpandProperty HostName

# Loop through each Domain Controller
foreach ($dc in $domainControllers) {
    Write-Host "Checking DNS configuration for Domain Controller: $dc" -ForegroundColor Cyan

    try {
        # Get the DNS settings for the DC
        $dnsSettings = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $dc | Where-Object { $_.IPEnabled -eq $true }

        # Extract Primary and Secondary DNS IP addresses
        $primaryDNS = $dnsSettings.DNSServerSearchOrder[0]
        $secondaryDNS = if ($dnsSettings.DNSServerSearchOrder.Count -gt 1) { $dnsSettings.DNSServerSearchOrder[1] } else { "N/A" }

        # Default recommendation
        $recommendation = "Check DNS settings"

        # Check if primary DNS is set to its own IP
        if ($primaryDNS -eq $dc) {
            $recommendation = "Primary DNS is correctly set to the Domain Controller's IP."
        } else {
            $recommendation = "Primary DNS should be set to the Domain Controller's IP."
        }

        # Check if secondary DNS is set to another DC in the same site
        if ($secondaryDNS -eq $dc) {
            $recommendation += " Secondary DNS is incorrectly set to this DC's IP. It should point to another DC in the same site."
        } elseif ($secondaryDNS -eq "N/A") {
            $recommendation += " Secondary DNS is missing. Consider setting it to another DC in the same site."
        } else {
            $recommendation += " Secondary DNS is correctly set to another DC in the same site."
        }

        # Log the DNS check result
        Log-Action -ServerName $dc -PrimaryDNS $primaryDNS -SecondaryDNS $secondaryDNS -Recommendation $recommendation

    } catch {
        Write-Host "Error checking DNS settings for $dc: $_" -ForegroundColor Red
        Log-Action -ServerName $dc -PrimaryDNS "N/A" -SecondaryDNS "N/A" -Recommendation "Error: $_"
    }
}

Write-Host "DNS check completed. Log file saved at: $logFile" -ForegroundColor Cyan
