# Function to check service statuses
function Check-Services {
    $servicesToCheck = @(
        "pcasvc",  # Program Compatibility Assistant Service
        "DPS",     # Diagnostic Policy Service
        "Diagtrack", # Connected User Experiences and Telemetry
        "sysmain", # Superfetch
        "eventlog", # Windows Event Log
        "sgrmbroker", # Secure Guard Manager
        "cdpusersvc" # Connected Devices Platform User Service
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

# Function to check Activity History setting
function Check-ActivityHistory {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $valueName = "PublishUserActivities"

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
            Write-Output "PublishUserActivities key is not set. Activity History might use the default behavior."
        }
    } else {
        Write-Output "Registry path for Activity History does not exist. Activity History might not be configured via Group Policy."
    }
}

# Main script execution
Write-Output "Starting system checks...`n"
Check-Services
Check-ActivityHistory
Write-Output "`nSystem checks completed."
