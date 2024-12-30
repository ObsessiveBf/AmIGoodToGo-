function Check-Services {
    $servicesToCheck = @(
        "SysMain",          # System performance monitoring
        "CDPUserSvc",       # Connected Devices Platform
        "PcaSvc",           # Program Compatibility Assistant
        "DPS",              # Diagnostic Policy Service
        "EventLog",         # Event logging for system monitoring
        "Schedule",         # Task Scheduler
        "SearchIndexer",    # Search indexing for file visibility
        "bam",              # Background Activity Moderator
        "dam",              # Background Activity Manager
        "Dusmsvc",          # Data Usage Service
        "Appinfo"           # Application Information Service
    )

    Write-Output "Checking service statuses..."
    foreach ($service in $servicesToCheck) {
        $serviceStatus = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($serviceStatus) {
            Write-Output "$($service): $($serviceStatus.Status)"
        } else {
            Write-Output "$($service): Service not found or unavailable."
        }
    }
}

function Check-ActivityHistory {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"
    $valueName = "ActivityHistoryEnabled"

    Write-Output "`nChecking Activity History setting..."
    if (Test-Path $regPath) {
        $regValue = Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue

        if ($regValue) {
            if ($regValue.$valueName -eq 1) {
                Write-Output "Activity History is enabled."
            } elseif ($regValue.$valueName -eq 0) {
                Write-Output "Activity History is disabled."
            } else {
                Write-Output "Activity History setting is undefined."
            }
        } else {
            Write-Output "$valueName key is not set. Activity History might use the default behavior."
        }
    } else {
        Write-Output "Registry path for Activity History does not exist. Activity History might not be configured."
    }
}

function Check-JumpLists {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $valueName = "Start_TrackDocs"

    Write-Output "`nChecking Jump Lists setting..."
    if (Test-Path $regPath) {
        $regValue = Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue

        if ($regValue) {
            if ($regValue.$valueName -eq 1) {
                Write-Output "Jump Lists are enabled."
            } elseif ($regValue.$valueName -eq 0) {
                Write-Output "Jump Lists are disabled."
            } else {
                Write-Output "Jump Lists setting is undefined."
            }
        } else {
            Write-Output "Start_TrackDocs key is not set. Jump Lists might use the default behavior."
        }
    } else {
        Write-Output "Registry path for Jump Lists does not exist. Jump Lists might not be configured."
    }
}

function Check-FAT32-Drives {
    Write-Output "`nChecking connected drives for FAT32 format..."
    $drives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 -or $_.DriveType -eq 3 } 

    foreach ($drive in $drives) {
        if ($drive.FileSystem -eq "FAT32") {
            Write-Output "Drive $($drive.DeviceID) is formatted as FAT32."
        } else {
            Write-Output "Drive $($drive.DeviceID) is not FAT32 (FileSystem: $($drive.FileSystem))."
        }
    }
}

Write-Output "Starting system checks...`n"
Check-Services
Check-ActivityHistory
Check-JumpLists
Check-FAT32-Drives
Write-Output "`nSystem checks completed."
