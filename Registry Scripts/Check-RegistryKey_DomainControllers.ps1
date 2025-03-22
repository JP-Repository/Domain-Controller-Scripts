<#
.SYNOPSIS
    This script checks a specific registry key on all domain controllers in the domain and outputs the results with a progress bar.

.DESCRIPTION
    The script queries the registry key `StrongCertificateBindingEnforcement` under the specified path on each domain controller in the domain. The results are displayed in a table, and the script includes a progress bar to indicate the status of each domain controller being checked. Optionally, the results can be exported to a CSV file.

.NOTES
    Script Name    : CheckRegistryKeyOnDCs.ps1
    Version        : 1.0
    Author         : [Your Name]
    Approved By    : [Approver's Name]
    Date           : [Date]
    Purpose        : Query a specific registry key on all domain controllers to check its status.

.PREREQUISITES
    - The script requires the Active Directory module for PowerShell.
    - The script must be run by an account with sufficient privileges to query remote registry keys on domain controllers.
    - The specified registry path and key should exist on the domain controllers.

.PARAMETERS
    - None. All necessary variables are hard-coded in the script.

.EXAMPLE
    .\CheckRegistryKeyOnDCs.ps1

    This will check the `StrongCertificateBindingEnforcement` registry key on all domain controllers in the domain and display the results.

#>

# Start of Script

# Get a list of all domain controllers in the domain
$DomainControllers = Get-ADDomainController -Filter * | Select-Object -ExpandProperty HostName

# Define the registry path and key to check (this can be modified to any registry path/key)
$RegistryPath = "SYSTEM\CurrentControlSet\Services\Kdc"  # Example path
$RegistryKey = "StrongCertificateBindingEnforcement"    # Example registry key

# Initialize an array to store the results
$Results = @()

# Loop through each domain controller
$TotalDCs = $DomainControllers.Count
$Counter = 0

foreach ($DC in $DomainControllers) {
    try {
        # Update the progress bar
        $Counter++
        $PercentComplete = ($Counter / $TotalDCs) * 100
        Write-Progress -PercentComplete $PercentComplete -Status "Checking $DC" -Activity "Processing Domain Controllers"

        # Query the registry key remotely
        $KeyValue = Invoke-Command -ComputerName $DC -ScriptBlock {
            Get-ItemProperty -Path "HKLM:\$using:RegistryPath" -Name $using:RegistryKey
        }

        # Store the result
        $Results += [PSCustomObject]@{
            DomainController = $DC
            StrongCertificateBindingEnforcement = $KeyValue.$RegistryKey
            Status = "Success"
        }
    } catch {
        # Handle errors and store them
        $Results += [PSCustomObject]@{
            DomainController = $DC
            StrongCertificateBindingEnforcement = "N/A"
            Status = "Error: $_"
        }
    }
}

# Output the results in a table format
$Results | Format-Table -AutoSize

# Optional: Export the results to a CSV file
$Results | Export-Csv -Path "C:\Temp\RegistryKeyCheckResults.csv" -NoTypeInformation

# End of Script
