# Create log/report folders if they do not exist
$logFolder = "C:\DiskLogs"
if (-not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
}

$timeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$runLog    = Join-Path $logFolder "DiskJob.log"
$csvReport = Join-Path $logFolder "DiskReport_$timeStamp.csv"
$txtReport = Join-Path $logFolder "DiskReport_$timeStamp.txt"

# Log that the scheduled task started
"[$(Get-Date)] Script started on $env:COMPUTERNAME" | Out-File $runLog -Append

# Import AD module if needed
#Import-Module ActiveDirectory -ErrorAction Stop

# Limit targets so the script is faster
# Option 1: only machines with names like LDVM-*
$computers = Get-ADComputer -Filter 'Name -like "LDVM-*"' | Select-Object -ExpandProperty Name

# If you want all computers, use this instead:
# $computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

$diskSizeList = @()

foreach ($computer in $computers) {
    "[$(Get-Date)] Checking $computer" | Out-File $runLog -Append

    $status = "OK"
    $lastBoot = "N/A"

    # Quick ping test first so we do not wait a long time on dead VMs
    $isReachable = Test-Connection -ComputerName $computer -Count 1 -Quiet -ErrorAction SilentlyContinue

    if (-not $isReachable) {
        $diskSizeList += [PSCustomObject]@{
            ComputerName = $computer
            Status       = "Offline (Ping failed)"
            LastBoot     = "Boot info unavailable"
            Drive        = "N/A"
            SizeGB       = "N/A"
            FreeGB       = "N/A"
            UsedGB       = "N/A"
            PctFree      = "N/A"
        }

        "[$(Get-Date)] $computer is offline or not responding to ping" | Out-File $runLog -Append
        continue
    }

    try {
        # Get boot time
        $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
        $lastBoot = $os.ConvertToDateTime($os.LastBootUpTime)

        # Get disks
        $disks = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $computer -Filter "DriveType=3" -ErrorAction Stop

        foreach ($disk in $disks) {
            $diskSizeList += [PSCustomObject]@{
                ComputerName = $computer
                Status       = "Online"
                LastBoot     = $lastBoot
                Drive        = $disk.DeviceID
                SizeGB       = [math]::Round($disk.Size / 1GB, 2)
                FreeGB       = [math]::Round($disk.FreeSpace / 1GB, 2)
                UsedGB       = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 2)
                PctFree      = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)
            }
        }

        "[$(Get-Date)] Successfully collected disk data from $computer" | Out-File $runLog -Append
    }
    catch {
        if ($_.Exception.Message -like "*RPC*") {
            $status = "Offline (RPC Unavailable)"
        }
        elseif ($_.Exception.Message -like "*Access is denied*") {
            $status = "Error: Access is denied"
        }
        else {
            $status = "Error: $($_.Exception.Message)"
        }

        $diskSizeList += [PSCustomObject]@{
            ComputerName = $computer
            Status       = $status
            LastBoot     = "Boot info unavailable"
            Drive        = "N/A"
            SizeGB       = "N/A"
            FreeGB       = "N/A"
            UsedGB       = "N/A"
            PctFree      = "N/A"
        }

        "[$(Get-Date)] Failed on $computer : $status" | Out-File $runLog -Append
    }
}

# Save results to files
$diskSizeList |
    Sort-Object ComputerName, Drive |
    Export-Csv -Path $csvReport -NoTypeInformation

$diskSizeList |
    Sort-Object ComputerName, Drive |
    Format-Table -AutoSize -Wrap |
    Out-String |
    Out-File $txtReport

"[$(Get-Date)] Script completed. CSV: $csvReport TXT: $txtReport" | Out-File $runLog -Append
