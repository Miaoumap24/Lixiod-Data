<#
    .SYNOPSIS
        Script Ultime de Debloat & Optimisation Windows
    .DESCRIPTION
        Applique les tweaks de registre demandés, exécute Slopilot (Debloat IA),
        nettoie le système et lance une maintenance approfondie (SFC/DISM).
#>

Clear-Host
$PercentComplete = 0

function Update-Progress ($TaskName, $Step, $TotalSteps) {
    $PercentComplete = [math]::Round(($Step / $TotalSteps) * 100)
    Write-Progress -Activity "Optimisation Ultime de Windows" -Status $TaskName -PercentComplete $PercentComplete
}

# Nombre total d'étapes principales
$TotalSteps = 6

# ---------------------------------------------------------
# ÉTAPE 1 : Exécution de Slopilot (Debloat IA)
# ---------------------------------------------------------
Update-Progress "Exécution de Slopilot (Retrait des fonctions IA)..." 1 $TotalSteps
Write-Host "[-] Lancement de Slopilot..." -ForegroundColor Cyan
try {
    # Appel du script officiel Slopilot en tâche de fond
    irm https://raw.githubusercontent.com/redw0lf-dev/Slopilot/main/slopilot.ps1 | iex
} catch {
    Write-Warning "Impossible de charger Slopilot directement. Passage aux tweaks locaux."
}
Start-Sleep -Seconds 2

# ---------------------------------------------------------
# ÉTAPE 2 : Tweaks Système (End Task, First Run Experience, Start Boost)
# ---------------------------------------------------------
Update-Progress "Configuration des options système..." 2 $TotalSteps
Write-Host "[-] Application des tweaks système..." -ForegroundColor Cyan

# Enable End Task in Taskbar
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\DeveloperSettings" -Name "TaskbarEndTask" -PropertyType DWord -Value 1 -Force | Out-Null

# Don't Show First Run Experience
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -PropertyType DWord -Value 1 -Force | Out-Null

# Disable Edge Start Boost
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Name "StartupBoostEnabled" -PropertyType DWord -Value 0 -Force | Out-Null
Start-Sleep -Seconds 1

# ---------------------------------------------------------
# ÉTAPE 3 : Vie privée & Recherche (Bing, Suggestions, Feedback, Location)
# ---------------------------------------------------------
Update-Progress "Désactivation des mouchards et de Bing Search..." 3 $TotalSteps
Write-Host "[-] Optimisation de la vie privée et de la recherche..." -ForegroundColor Cyan

# Don't Submit User Feedback Option
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "UserPreferenceDoNotShowFeedbackNotifications" -PropertyType DWord -Value 1 -Force | Out-Null

# Disable Search Box Suggestion & Bing Search
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -PropertyType DWord -Value 0 -Force | Out-Null

# Disable Location Tracking
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -PropertyType DWord -Value 1 -Force | Out-Null

# Disable Activity History
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -PropertyType DWord -Value 0 -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -PropertyType DWord -Value 0 -Force | Out-Null
Start-Sleep -Seconds 1

# ---------------------------------------------------------
# ÉTAPE 4 : Télémesure & Publicités
# ---------------------------------------------------------
Update-Progress "Désactivation complète de la télémétrie et des pubs..." 4 $TotalSteps
Write-Host "[-] Blocage de la télémétrie et des pubs..." -ForegroundColor Cyan

# Turn Off ALL Telemetry
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -PropertyType DWord -Value 0 -Force | Out-Null

# Turn Off ALL Ads (Content Delivery Manager)
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

# ---------------------------------------------------------
# ÉTAPE 5 : Nettoyage Cleanmgr (Mode SageSet automatisé)
# ---------------------------------------------------------
Update-Progress "Nettoyage du disque (Cleanmgr Admin)..." 5 $TotalSteps
Write-Host "[-] Lancement du nettoyage de disque automatisé..." -ForegroundColor Cyan

# Configuration des options de Cleanmgr via le registre pour tout cocher d'un coup
$CleanmgrStateFlags = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
Get-ChildItem $CleanmgrStateFlags | ForEach-Object {
    New-ItemProperty -Path $_.PsPath -Name "StateFlags0001" -PropertyType DWord -Value 2 -Force | Out-Null
}
# Exécution silencieuse en tâche de fond
Start-Process cleanmgr.exe -ArgumentList "/sagerun:1" -Wait
Start-Sleep -Seconds 1

# ---------------------------------------------------------
# ÉTAPE 6 : Combo Maintenance (SFC -> DISM -> SFC)
# ---------------------------------------------------------
Update-Progress "Maintenance Système (SFC & DISM)..." 6 $TotalSteps

Write-Host "`n[1/3] Lancement du premier scan SFC..." -ForegroundColor Yellow
sfc /scannow

Write-Host "`n[2/3] Lancement de la réparation de l'image DISM..." -ForegroundColor Yellow
dism /online /cleanup-image /restorehealth

Write-Host "`n[3/3] Lancement du second scan SFC de vérification..." -ForegroundColor Yellow
sfc /scannow

# ---------------------------------------------------------
# FIN DU SCRIPT
# ---------------------------------------------------------
Write-Progress -Activity "Optimisation Ultime de Windows" -Status "Terminé !" -Completed
Write-Host "`n[+] Tout est fait, Timéo ! Ton Windows est propre, optimisé et débarrassé des bloatwares." -ForegroundColor Green