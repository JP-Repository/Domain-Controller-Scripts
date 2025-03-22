<#
.SYNOPSIS
    This script provides an interactive menu for running various `repadmin` commands and saves the results to the user's Desktop.

.DESCRIPTION
    The script presents an interactive menu with different `repadmin` command options. The user can choose which command to run, and the script will execute the selected command and save the result to the Desktop.

.NOTES
    Script Name    : Repadmin-Interactive.ps1
    Version        : 1.0
    Author         : [Your Name]
    Approved By    : [Approver's Name]
    Date           : [Date]
    Purpose        : Provide an interactive menu for troubleshooting Active Directory replication with `repadmin`.

.PARAMETERS
    None

.EXAMPLE
    .\RepadminInteractive.ps1

    This will display a menu with options for running different `repadmin` commands. The user selects an option to execute the corresponding command.

#>

# Define the output file path (Desktop location)
$outputFile = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), 'Repadmin_Results.txt')

# Function to display options and execute the selected command
function Show-RepadminOptions {
    Clear-Host
    Write-Host "Select a Repadmin command to run:" -ForegroundColor Green
    Write-Host "1. repadmin /replsummary" -ForegroundColor Cyan
    Write-Host "2. repadmin /showrepl" -ForegroundColor Cyan
    Write-Host "3. repadmin /syncall" -ForegroundColor Cyan
    Write-Host "4. repadmin /kcc" -ForegroundColor Cyan
    Write-Host "5. repadmin /showobjmeta" -ForegroundColor Cyan
    Write-Host "6. repadmin /replicate" -ForegroundColor Cyan
    Write-Host "7. repadmin /checkhealth" -ForegroundColor Cyan
    Write-Host "8. repadmin /showchanges" -ForegroundColor Cyan
    Write-Host "9. repadmin /lastsync" -ForegroundColor Cyan
    Write-Host "10. repadmin /removelingeringobjects" -ForegroundColor Cyan
    Write-Host "11. Exit" -ForegroundColor Red

    $selection = Read-Host "Enter the number of your choice"
    
    switch ($selection) {
        1 { Run-RepadminReplSummary }
        2 { Run-RepadminShowRepl }
        3 { Run-RepadminSyncAll }
        4 { Run-RepadminKCC }
        5 { Run-RepadminShowObjMeta }
        6 { Run-RepadminReplicate }
        7 { Run-RepadminCheckHealth }
        8 { Run-RepadminShowChanges }
        9 { Run-RepadminLastSync }
        10 { Run-RepadminRemoveLingeringObjects }
        11 { Write-Host "Exiting script..." -ForegroundColor Red; exit }
        default { Write-Host "Invalid selection. Please choose a valid option." -ForegroundColor Yellow; Show-RepadminOptions }
    }
}

# Function to run repadmin /replsummary
function Run-RepadminReplSummary {
    Write-Host "Running 'repadmin /replsummary'..." -ForegroundColor Green
    repadmin /replsummary | Out-File -FilePath $outputFile
    Write-Host "Results saved to $outputFile" -ForegroundColor Green
    # Example Explanation
    Write-Host "This command provides a summary of replication status for all domain controllers in the forest." -ForegroundColor Yellow
    Write-Host "It shows the current replication state, including any errors or issues." -ForegroundColor Yellow
}

# Function to run repadmin /showrepl
function Run-RepadminShowRepl {
    $DCName = Read-Host "Enter the domain controller name"
    Write-Host "Running 'repadmin /showrepl $DCName'..." -ForegroundColor Green
    repadmin /showrepl $DCName | Out-File -FilePath $outputFile
    Write-Host "Results saved to $outputFile" -ForegroundColor Green
    # Example Explanation
    Write-Host "This command shows detailed replication information for a specific domain controller (DC)." -ForegroundColor Yellow
    Write-Host "It provides a list of partners, replication status, and last replication times." -ForegroundColor Yellow
}

# Function to run repadmin /syncall
function Run-RepadminSyncAll {
    Write-Host "Running 'repadmin /syncall'..." -ForegroundColor Green
    repadmin /syncall | Out-File -FilePath $outputFile
    Write-Host "Results saved to $outputFile" -ForegroundColor Green
    # Example Explanation
    Write-Host "This command forces a full synchronization of all replication partners for the specified domain controller." -ForegroundColor Yellow
    Write-Host "It is helpful to ensure that a DC has the most up-to-date information from all its replication partners." -ForegroundColor Yellow
}

# Function to run repadmin /kcc
function Run-RepadminKCC {
    Write-Host "Running 'repadmin /kcc'..." -ForegroundColor Green
    repadmin /kcc | Out-File -FilePath $outputFile
    Write-Host "Results saved to $outputFile" -ForegroundColor Green
    # Example Explanation
    Write-Host "This command forces the Knowledge Consistency Checker (KCC) to recalculate the replication topology." -ForegroundColor Yellow
    Write-Host "It helps resolve replication issues caused by topology changes or KCC not updating replication links." -ForegroundColor Yellow
}

# Function to run repadmin /showobjmeta
function Run-RepadminShowObjMeta {
    $DN = Read-Host "Enter the Distinguished Name of the object"
    $DCName = Read-Host "Enter the domain controller name"
    Write-Host "Running 'repadmin /showobjmeta $DCName $DN'..." -ForegroundColor Green
    repadmin /showobjmeta $DCName $DN | Out-File -FilePath $outputFile
    Write-Host "Results saved to $outputFile" -ForegroundColor Green
    # Example Explanation
    Write-Host "This command displays metadata for a specific object in Active Directory." -ForegroundColor Yellow
    Write-Host "It is useful for troubleshooting issues related to object replication and updates." -ForegroundColor Yellow
}

# Function to run repadmin /replicate
function Run-RepadminReplicate {
    $SourceDC = Read-Host "Enter the source domain controller"
    $TargetDC = Read-Host "Enter the target domain controller"
    $DN = Read-Host "Enter the Distinguished Name of the object"
    Write-Host "Running 'repadmin /replicate $SourceDC $TargetDC $DN'..." -ForegroundColor Green
    repadmin /replicate $SourceDC $TargetDC $DN | Out-File -FilePath $outputFile
    Write-Host "Results saved to $outputFile" -ForegroundColor Green
    # Example Explanation
    Write-Host "This command forces replication between two domain controllers for a specific object." -ForegroundColor Yellow
    Write-Host "It is useful for manually triggering replication between two specific DCs." -ForegroundColor Yellow
}

# Function to run repadmin /checkhealth
function Run-RepadminCheckHealth {
    Write-Host "Running 'repadmin /checkhealth'..." -ForegroundColor Green
    repadmin /checkhealth | Out-File -FilePath $outputFile
    Write-Host "Results saved to $outputFile" -ForegroundColor Green
    # Example Explanation
    Write-Host "This command checks the overall health of the Active Directory replication topology." -ForegroundColor Yellow
    Write-Host "It helps identify any issues with replication, such as broken connections or failed replication." -ForegroundColor Yellow
}

# Function to run repadmin /showchanges
function Run-RepadminShowChanges {
    $DCName = Read-Host "Enter the domain controller name"
    $DN = Read-Host "Enter the Distinguished Name of the object"
    Write-Host "Running 'repadmin /showchanges $DCName $DN'..." -ForegroundColor Green
    repadmin /showchanges $DCName $DN | Out-File -FilePath $outputFile
    Write-Host "Results saved to $outputFile" -ForegroundColor Green
    # Example Explanation
    Write-Host "This command shows the changes made to a specific object in Active Directory." -ForegroundColor Yellow
    Write-Host "It is useful for tracking changes and identifying replication issues for a specific object." -ForegroundColor Yellow
}

# Function to run repadmin /lastsync
function Run-RepadminLastSync {
    $DC1 = Read-Host "Enter the first domain controller"
    $DC2 = Read-Host "Enter the second domain controller"
    Write-Host "Running 'repadmin /lastsync $DC1 $DC2'..." -ForegroundColor Green
    repadmin /lastsync $DC1 $DC2 | Out-File -FilePath $outputFile
    Write-Host "Results saved to $outputFile" -ForegroundColor Green
    # Example Explanation
    Write-Host "This command shows the last synchronization time between two domain controllers." -ForegroundColor Yellow
    Write-Host "It helps verify when the last successful replication occurred between the two DCs." -ForegroundColor Yellow
}

# Function to run repadmin /removelingeringobjects
function Run-RepadminRemoveLingeringObjects {
    $DCName = Read-Host "Enter the domain controller name"
    $PartnerDC = Read-Host "Enter the replication partner domain controller"
    $NCName = Read-Host "Enter the Naming Context"
    Write-Host "Running 'repadmin /removelingeringobjects $DCName $PartnerDC $NCName'..." -ForegroundColor Green
    repadmin /removelingeringobjects $DCName $PartnerDC $NCName | Out-File -FilePath $outputFile
    Write-Host "Results saved to $outputFile" -ForegroundColor Green
    # Example Explanation
    Write-Host "This command removes lingering objects (deleted objects) from a domain controller that are no longer present in the replication partner." -ForegroundColor Yellow
    Write-Host "It is useful for cleaning up objects that may have caused replication issues." -ForegroundColor Yellow
}

# Start the interactive menu
Show-RepadminOptions
