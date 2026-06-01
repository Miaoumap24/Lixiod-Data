<#
    .SYNOPSIS
        Lixiod System Repair for Windows
    .DESCRIPTION
        Remove Windows Bloatware and AI and execute SFC and DISM
#>

Clear-Host
$PercentComplete = 0

function Update-Progress ($TaskName, $Step, $TotalSteps) {
    $PercentComplete = [math]::Round(($Step / $TotalSteps) * 100)
    Write-Progress -Activity "Please wait..." -Status $TaskName -PercentComplete $PercentComplete
}

$TotalSteps = 6

Update-Progress "Removing AI..." 1 $TotalSteps
Write-Host "[-] Loading Slopilot..." -ForegroundColor Cyan
try {
    irm https://github.com/zoicware/RemoveWindowsAI/blob/dadc0b9e4b9fd6af48db6cfa7f0ae2817895a65d/RemoveWindowsAi.ps1 | iex
} catch {
    Write-Warning "ERROR : Continue with local tweaks..."
}
Start-Sleep -Seconds 2

Update-Progress "Configuring System Option..." 2 $TotalSteps
Write-Host "[-] Applicating System Tweaks..." -ForegroundColor Cyan

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeveloperSettings" -Name "TaskbarEndTask" -PropertyType DWord -Value 1 -Force | Out-Null

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -PropertyType DWord -Value 1 -Force | Out-Null

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Name "StartupBoostEnabled" -PropertyType DWord -Value 0 -Force | Out-Null
Start-Sleep -Seconds 1

Update-Progress "Disabling Non-privacy bloatwares..." 3 $TotalSteps
Write-Host "[-] Loading Privacy Tweaks..." -ForegroundColor Cyan

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "UserPreferenceDoNotShowFeedbackNotifications" -PropertyType DWord -Value 1 -Force | Out-Null

New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -PropertyType DWord -Value 0 -Force | Out-Null

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -PropertyType DWord -Value 1 -Force | Out-Null

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -PropertyType DWord -Value 0 -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -PropertyType DWord -Value 0 -Force | Out-Null
Start-Sleep -Seconds 1

Update-Progress "Disabling telemetry..." 4 $TotalSteps
Write-Host "[-] Disabling Telemetry and Ads..." -ForegroundColor Cyan

New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -PropertyType DWord -Value 0 -Force | Out-Null

$AdPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
)
foreach ($Path in $AdPaths) {
    if (-not (Test-Path $Path)) { New-Item $Path -Force | Out-Null }
    New-ItemProperty -Path $Path -Name "SystemPaneSuggestionsEnabled" -PropertyType DWord -Value 0 -Force | Out-Null
    New-ItemProperty -Path $Path -Name "SubscribedContent-338387Enabled" -PropertyType DWord -Value 0 -Force | Out-Null
    New-ItemProperty -Path $Path -Name "SubscribedContent-338388Enabled" -PropertyType DWord -Value 0 -Force | Out-Null
    New-ItemProperty -Path $Path -Name "SubscribedContent-338389Enabled" -PropertyType DWord -Value 0 -Force | Out-Null
    New-ItemProperty -Path $Path -Name "SubscribedContent-353698Enabled" -PropertyType DWord -Value 0 -Force | Out-Null
}
Start-Sleep -Seconds 1

Update-Progress "Cleaning Disk..." 5 $TotalSteps
Write-Host "[-] Loading Cleanmgr..." -ForegroundColor Cyan

$CleanmgrStateFlags = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
Get-ChildItem $CleanmgrStateFlags | ForEach-Object {
    New-ItemProperty -Path $_.PsPath -Name "StateFlags0001" -PropertyType DWord -Value 2 -Force | Out-Null
}
Start-Process cleanmgr.exe -ArgumentList "/sagerun:1" -Wait
Start-Sleep -Seconds 1

Update-Progress "Loading SFC and DISM..." 6 $TotalSteps

Write-Host "`n[1/3] Loading first SFC Scan..." -ForegroundColor Yellow
sfc /scannow

Write-Host "`n[2/3] Loading DISM..." -ForegroundColor Yellow
dism /online /cleanup-image /restorehealth

Write-Host "`n[3/3] Loading final SFC Scan..." -ForegroundColor Yellow
sfc /scannow

Write-Progress -Activity "Windows Debloating and Optimisinf" -Status "Finished !" -Completed
Write-Host "`n[+] Now, please reboot your PC." -ForegroundColor Green