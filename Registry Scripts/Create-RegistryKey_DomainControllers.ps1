<#
.SYNOPSIS
    This script checks and creates registry paths and values on all Domain Controllers in the domain.

.DESCRIPTION
    This script automates the process of verifying if specific registry paths and values exist on all Domain Controllers. If they are missing, the script will create them and log the actions performed.

.NOTES
    Script Name    : Create-RegistryEntries
    Version        : 0.1
    Author         : [Your Name]
    Approved By    : [Approver's Name]
    Date           : [Date]
    Purpose        : To ensure specific registry paths and values exist on all Domain Controllers and log the actions performed.

.PREREQUISITES
    - The script must be executed by a user with administrative privileges on the target Domain Controllers.
    - PowerShell Remoting must be enabled on the Domain Controllers to run remote commands.

.PARAMETERS
    [Optional] Define any script parameters here if applicable.

.EXAMPLE
    .\Create-RegistryEntries.ps1
    This will check and create the specified registry entries on all Domain Controllers and log the actions in the specified CSV file.

#>

# Start of Script

# Define the log file
$logFile = "C:\Scripts\Registry_Log.csv"

# Check if the log file exists; if not, create it with headers
if (-not (Test-Path $logFile)) {
    "ServerName,RegistryPath,Action,Status,Timestamp" | Out-File -FilePath $logFile
}

# Function to log actions
function Log-Action {
    param (
        [string]$ServerName,
        [string]$RegistryPath,
        [string]$Action,
        [string]$Status
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$ServerName,$RegistryPath,$Action,$Status,$timestamp" | Out-File -FilePath $logFile -Append
}

# Define the registry paths and values
$registryEntries = @(
    @{
        Path = "HKLM:\SOFTWARE\MyCompany\Settings"
        Name = "ConfigValue1"
        Value = "Enabled"
        Type = "String"
    },
    @{
        Path = "HKLM:\SOFTWARE\MyCompany\Settings"
        Name = "ConfigValue2"
        Value = 1
        Type = "DWord"
    }
)

# Get all Domain Controllers
$domainControllers = Get-ADDomainController -Filter * | Select-Object -ExpandProperty HostName

# Loop through each Domain Controller
foreach ($dc in $domainControllers) {
    Write-Host "Processing Domain Controller: $dc" -ForegroundColor Cyan

    foreach ($entry in $registryEntries) {
        try {
            # Check if the registry path exists
            if (-not (Test-Path -Path "\\$dc\$($entry.Path.Replace(':', '$'))")) {
                Write-Host "Registry path $($entry.Path) is missing on $dc. Creating it..." -ForegroundColor Yellow
                Invoke-Command -ComputerName $dc -ScriptBlock {
                    param ($Path)
                    New-Item -Path $Path -Force | Out-Null
                } -ArgumentList $entry.Path -ErrorAction Stop
                Log-Action -ServerName $dc -RegistryPath $entry.Path -Action "Create Registry Path" -Status "Success"
            } else {
                Write-Host "Registry path $($entry.Path) exists on $dc." -ForegroundColor Green
            }

            # Check if the registry value exists
            $valueExists = Invoke-Command -ComputerName $dc -ScriptBlock {
                param ($Path, $Name)
                Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
            } -ArgumentList $entry.Path, $entry.Name

            if (-not $valueExists) {
                Write-Host "Registry value $($entry.Name) is missing on $dc. Creating it..." -ForegroundColor Yellow
                Invoke-Command -ComputerName $dc -ScriptBlock {
                    param ($Path, $Name, $Value, $Type)
                    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
                } -ArgumentList $entry.Path, $entry.Name, $entry.Value, $entry.Type -ErrorAction Stop
                Log-Action -ServerName $dc -RegistryPath "$($entry.Path)\$($entry.Name)" -Action "Create Registry Value" -Status "Success"
            } else {
                Write-Host "Registry value $($entry.Name) exists on $dc." -ForegroundColor Green
                Log-Action -ServerName $dc -RegistryPath "$($entry.Path)\$($entry.Name)" -Action "Check Registry Value" -Status "Already Exists"
            }
        } catch {
            Write-Host "Error processing $dc for registry path $($entry.Path): $_" -ForegroundColor Red
            Log-Action -ServerName $dc -RegistryPath $entry.Path -Action "Error" -Status $_.Exception.Message
        }
    }
}

Write-Host "Script execution completed. Log file saved at: $logFile" -ForegroundColor Cyan

# End of Script
