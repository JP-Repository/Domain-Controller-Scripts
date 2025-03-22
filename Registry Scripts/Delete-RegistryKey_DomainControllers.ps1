<#
.SYNOPSIS
    This script deletes specified registry values from all Domain Controllers in the domain.

.DESCRIPTION
    This script automates the process of checking if specific registry paths and values exist on all Domain Controllers. If the registry values exist, the script will delete them and log the actions performed.

.NOTES
    Script Name    : Delete-RegistryEntries
    Version        : 0.1
    Author         : [Your Name]
    Approved By    : [Approver's Name]
    Date           : [Date]
    Purpose        : To delete specific registry values from all Domain Controllers and log the actions performed.

.PREREQUISITES
    - The script must be executed by a user with administrative privileges on the target Domain Controllers.
    - PowerShell Remoting must be enabled on the Domain Controllers to run remote commands.

.PARAMETERS
    [Optional] Define any script parameters here if applicable.

.EXAMPLE
    .\Delete-RegistryEntries.ps1
    This will check and delete the specified registry entries on all Domain Controllers and log the actions in the specified CSV file.

#>

# Start of Script

# Define the log file
$logFile = "C:\Scripts\Registry_Delete_Log.csv"

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

# Define the registry entries to delete
$registryEntries = @(
    @{
        Path = "HKLM:\SOFTWARE\MyCompany\Settings"
        Name = "ConfigValue1"
    },
    @{
        Path = "HKLM:\SOFTWARE\MyCompany\Settings"
        Name = "ConfigValue2"
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
            $pathExists = Invoke-Command -ComputerName $dc -ScriptBlock {
                param ($Path)
                Test-Path -Path $Path
            } -ArgumentList $entry.Path

            if ($pathExists) {
                # Check if the registry value exists
                $valueExists = Invoke-Command -ComputerName $dc -ScriptBlock {
                    param ($Path, $Name)
                    Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
                } -ArgumentList $entry.Path, $entry.Name

                if ($valueExists) {
                    Write-Host "Deleting registry value $($entry.Name) under $($entry.Path) on $dc..." -ForegroundColor Yellow
                    Invoke-Command -ComputerName $dc -ScriptBlock {
                        param ($Path, $Name)
                        Remove-ItemProperty -Path $Path -Name $Name -Force
                    } -ArgumentList $entry.Path, $entry.Name -ErrorAction Stop
                    Log-Action -ServerName $dc -RegistryPath "$($entry.Path)\$($entry.Name)" -Action "Delete Registry Value" -Status "Success"
                } else {
                    Write-Host "Registry value $($entry.Name) does not exist on $dc." -ForegroundColor Green
                    Log-Action -ServerName $dc -RegistryPath "$($entry.Path)\$($entry.Name)" -Action "Check Registry Value" -Status "Does Not Exist"
                }
            } else {
                Write-Host "Registry path $($entry.Path) does not exist on $dc." -ForegroundColor Green
                Log-Action -ServerName $dc -RegistryPath $entry.Path -Action "Check Registry Path" -Status "Does Not Exist"
            }
        } catch {
            Write-Host "Error processing $dc for registry path $($entry.Path): $_" -ForegroundColor Red
            Log-Action -ServerName $dc -RegistryPath $entry.Path -Action "Error" -Status $_.Exception.Message
        }
    }
}

Write-Host "Script execution completed. Log file saved at: $logFile" -ForegroundColor Cyan

# End of Script
