# Run in an elevated PowerShell session

# Stop and disable Windows Search
Stop-Service -Name WSearch -Force -ErrorAction SilentlyContinue
Set-Service -Name WSearch -StartupType Disabled

# Optional: stop/disable other non-essential services if approved: when disabled themes for windows will go back to classic windows font size styling, etc
# Stop-Service -Name Themes -Force -ErrorAction SilentlyContinue
# Set-Service -Name Themes -StartupType Disabled

# Clear Windows Search index database> EDB files for Win10 and or DB files for Win11
Remove-Item -Path @(
    "C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb",
    "C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.db"
) -Force -ErrorAction SilentlyContinue

# Re-enable Windows Search later if needed
Set-Service -Name WSearch -StartupType Automatic
Start-Service -Name WSearch

# Clear Windows Update download cache
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Stop-Service -Name bits -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service -Name bits -ErrorAction SilentlyContinue
Start-Service -Name wuauserv -ErrorAction SilentlyContinue

# Component store cleanup
Dism /Online /Cleanup-Image /AnalyzeComponentStore
Dism /Online /Cleanup-Image /StartComponentCleanup

# Optional repair if needed
Dism /Online /Cleanup-Image /RestoreHealth

# Optional system file check
sfc /scannow

# Clear common temp and cache locations > can add more locations based on temp and cache files of apps using > I placed some examples below
$targets = @(
    "$env:WINDIR\Temp\*",
#    "$env:WINDIR\Prefetch\*", could add this but may cause slower load times of computer and apps since this is handled by MS and optimize how platforms load
    "$env:TEMP\*",
    "$env:LOCALAPPDATA\Temp\*",
    "$env:ProgramData\Microsoft\Windows\WER\ReportArchive\*",#reports on crashes that may have occurred on windows apps that is upload to MS, strictly for forensic purposes
    "$env:ProgramData\Microsoft\Windows\WER\ReportQueue\*",#reports that are going to be sent to MS, failed, or configured to not be sent
    "C:\ProgramData\VMware\VDM\logs\*",
    "C:\ProgramData\VMware\VDM\Dumps\*",
    "C:\ProgramData\Adobe\ARM\Read*\*",
    "C:\ProgramData\Adobe\ARM\Acro*\*"
)

Remove-Item -Path $targets -Recurse -Force -ErrorAction SilentlyContinue

# User profile temp folders for all profiles
Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    Remove-Item -Path "$($_.FullName)\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
}

# Check free space
Get-Volume | Select-Object DriveLetter, FileSystemLabel, SizeRemaining, Size


#Will show GUI of cleanmgr to choose what to delete > to include system files will need to run as admin
# cleanmgr /lowdisk

#Will allow the ability to automtically delete files based on what was set ( usually do everything except recycle bin )
cleanmgr /sageset:1

#Once sageset is established > cleanmgr will run automatically of cleanse
cleanmgr /sagerun:1

# Exit remote session if applicable
Exit-PSSession

# Reboot if desired but recommended
# Restart-Computer -Force