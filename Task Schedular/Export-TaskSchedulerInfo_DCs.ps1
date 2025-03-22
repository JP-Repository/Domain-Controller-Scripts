<#
.SYNOPSIS
    This script checks and exports Task Scheduler information from Domain Controllers.

.DESCRIPTION
    The script retrieves Task Scheduler details (task names, status, triggers, etc.) from all Domain Controllers in the domain and exports the information to a CSV file on the user's Desktop.

.NOTES
    Script Name    : Export-TaskSchedulerInfo.ps1
    Version        : 1.0
    Author         : [Your Name]
    Approved By    : [Approver's Name]
    Date           : [Date]
    Purpose        : Export Task Scheduler information from Domain Controllers.

.PARAMETERS
    None

.EXAMPLE
    .\Export-TaskSchedulerInfo.ps1

    This will retrieve Task Scheduler information from all Domain Controllers and export it to a CSV file on the Desktop.

#>

# Define the output file path (Desktop location)
$outputFile = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), 'TaskScheduler_Info.csv')

# Get all Domain Controllers in the domain
$domainControllers = Get-ADDomainController -Filter *

# Initialize an empty array to store task information
$taskInfoArray = @()

# Loop through each Domain Controller and retrieve Task Scheduler information
foreach ($dc in $domainControllers) {
    Write-Host "Retrieving Task Scheduler information from $($dc.Name)..." -ForegroundColor Green

    # Get all scheduled tasks on the Domain Controller
    $tasks = Get-ScheduledTask -ComputerName $dc.Name

    # Loop through each task and collect the necessary information
    foreach ($task in $tasks) {
        $taskInfo = New-Object PSObject -property @{
            DCName          = $dc.Name
            TaskName        = $task.TaskName
            State           = $task.State
            LastRunTime     = $task.LastRunTime
            NextRunTime     = $task.NextRunTime
            TriggerType     = ($task.Triggers | ForEach-Object { $_.TriggerType }) -join ', '
            Author          = $task.Principal.UserId
            TaskPath        = $task.TaskPath
        }

        # Add the task information to the array
        $taskInfoArray += $taskInfo
    }
}

# Export the task information to a CSV file
$taskInfoArray | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "Task Scheduler information has been exported to $outputFile" -ForegroundColor Green
