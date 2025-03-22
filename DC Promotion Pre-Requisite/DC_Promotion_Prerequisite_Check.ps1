<#
.SYNOPSIS
    This script performs a prerequisite check before promoting a server to a Domain Controller.

.DESCRIPTION
    The script verifies essential prerequisites, including operating system compatibility, static IP configuration, DNS settings, hostname validation, firewall status, time synchronization, network connectivity, port availability, AD DS role installation, and disk space.

.NOTES
    Script Name    : DC_Promotion_Prerequisite_Check.ps1
    Version        : 0.1
    Author         : [Your Name]
    Approved By    : [Approver's Name]
    Date           : [Date]
    Purpose        : Ensure the server meets all prerequisites for Domain Controller promotion.

.PREREQUISITES
    - PowerShell 5.1 or later
    - Administrative privileges
    - Access to existing Domain Controllers for connectivity checks

.PARAMETERS
    [Optional] Define any script parameters here if applicable.

.EXAMPLE
    .\DC_Promotion_Prerequisite_Check.ps1
    This command runs the script and performs all prerequisite checks.

#>

# Start of Script

# Initialize results storage
$PrerequisiteResults = @{}

# Define required ports for AD and DNS
$requiredPorts = @{
    "LDAP"         = 389
    "LDAPS"        = 636
    "Kerberos"     = 88
    "DNS"          = 53
    "Global Catalog" = 3268
    "RPC Endpoint Mapper" = 135
    "Dynamic RPC"  = "49152-65535"
}

# 1. Check Operating System
$osVersion = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
if ($osVersion -match "Windows Server") {
    $PrerequisiteResults["Operating System"] = "PASS: $osVersion"
} else {
    $PrerequisiteResults["Operating System"] = "FAIL: Unsupported OS - $osVersion"
}

# 2. Check Static IP Address
$ipConfig = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null }
if ($ipConfig.IPv4DefaultGateway) {
    $PrerequisiteResults["Static IP"] = "PASS: Static IP configured"
} else {
    $PrerequisiteResults["Static IP"] = "FAIL: No Static IP configured"
}

# 3. Check DNS Configuration
$dnsServers = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses
if ($dnsServers -ne $null -and $dnsServers.Count -gt 0) {
    $PrerequisiteResults["DNS Configuration"] = "PASS: DNS Servers - $($dnsServers -join ', ')"
} else {
    $PrerequisiteResults["DNS Configuration"] = "FAIL: No DNS Servers configured"
}

# 4. Check Hostname
$hostname = $env:COMPUTERNAME
if ($hostname.Length -le 15) {
    $PrerequisiteResults["Hostname"] = "PASS: Hostname is $hostname"
} else {
    $PrerequisiteResults["Hostname"] = "FAIL: Hostname exceeds 15 characters"
}

# 5. Check Firewall Status
$firewallStatus = (Get-NetFirewallProfile | Where-Object Enabled -eq $true).Name
if ($firewallStatus) {
    $PrerequisiteResults["Firewall Status"] = "PASS: Firewall is enabled"
} else {
    $PrerequisiteResults["Firewall Status"] = "FAIL: Firewall is disabled"
}

# 6. Check Time Synchronization
$timeSource = w32tm /query /status | Select-String "Source"
if ($timeSource) {
    $PrerequisiteResults["Time Synchronization"] = "PASS: Time synchronized with $timeSource"
} else {
    $PrerequisiteResults["Time Synchronization"] = "FAIL: Time synchronization issue"
}

# 7. Network Connectivity to Existing DCs
$existingDCs = Get-ADDomainController -Filter * | Select-Object -ExpandProperty HostName
$connectivityResults = @()
foreach ($dc in $existingDCs) {
    if (Test-Connection -ComputerName $dc -Count 1 -Quiet) {
        $connectivityResults += "$dc: Reachable"
    } else {
        $connectivityResults += "$dc: Unreachable"
    }
}
$PrerequisiteResults["Network Connectivity"] = $connectivityResults -join "; "

# 8. Port Check
$portResults = @()
foreach ($service in $requiredPorts.Keys) {
    $port = $requiredPorts[$service]
    if ($port -match "-") {
        $portRange = $port -split "-"
        $portCheck = Test-NetConnection -ComputerName $env:COMPUTERNAME -Port $portRange[0]
    } else {
        $portCheck = Test-NetConnection -ComputerName $env:COMPUTERNAME -Port $port
    }
    if ($portCheck.TcpTestSucceeded) {
        $portResults += "$service: Port $port is open"
    } else {
        $portResults += "$service: Port $port is closed"
    }
}
$PrerequisiteResults["Port Check"] = $portResults -join "; "

# 9. Check AD DS Role Installation
$adRole = Get-WindowsFeature -Name AD-Domain-Services
if ($adRole.Installed) {
    $PrerequisiteResults["AD DS Role"] = "PASS: AD DS Role is installed"
} else {
    $PrerequisiteResults["AD DS Role"] = "FAIL: AD DS Role is not installed"
}

# 10. Check Disk Space
$diskSpace = Get-PSDrive -Name C | Select-Object -ExpandProperty Free
if ($diskSpace -ge 20GB) {
    $PrerequisiteResults["Disk Space"] = "PASS: Sufficient disk space available"
} else {
    $PrerequisiteResults["Disk Space"] = "FAIL: Insufficient disk space"
}

# Output Results
Write-Host "Prerequisite Check Results:" -ForegroundColor Green
foreach ($key in $PrerequisiteResults.Keys) {
    Write-Host "$key: $($PrerequisiteResults[$key])"
}

# Save Results to File
$PrerequisiteResults | Out-File -FilePath "C:\DC_Promotion_Prerequisite_Check.txt"
Write-Host "Results saved to C:\DC_Promotion_Prerequisite_Check.txt" -ForegroundColor Cyan

# End of Script
