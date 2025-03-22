# Domain-Controller-Scripts
PowerShell scripts and tools focused on managing, monitoring, and automating tasks related to Active Directory Domain Controllers. This repository aims to simplify domain controller health checks, replication monitoring, backup management, and security hardening.

# Overview
This PowerShell script performs a comprehensive health check on all Domain Controllers in your environment. It checks the status of critical services, verifies replication health, monitors resource usage, and ensures proper time synchronization. The script outputs detailed reports in both CSV and HTML formats for easy review.

# Features
✅ Verifies Active Directory Domain Services (NTDS) status
✅ Checks DNS Server service status
✅ Ensures Time Synchronization (NTP) is working correctly
✅ Monitors Active Directory Replication status
✅ Gathers CPU load, memory usage, and disk space
✅ Exports results to CSV and HTML reports

# Prerequisites
PowerShell 5.1+
ActiveDirectory module installed
Administrative privileges on Domain Controllers
Remote management enabled (WinRM, RPC/WMI)
Usage

# Run the script from a management server or admin workstation
.\DC_HealthCheck.ps1

# Output:
DC_HealthCheck_Report.csv
DC_HealthCheck_Report.html

# Example Report Screenshot
(Optional: Add a screenshot once you run the script!)

# Future Enhancements
Email alert functionality for failed checks
Scheduled execution via Task Scheduler
Threshold customization (CPU, memory, disk warnings)
