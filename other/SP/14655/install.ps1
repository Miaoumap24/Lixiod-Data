if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERREUR : Tu dois lancer ce script en tant qu'ADMINISTRATEUR." -ForegroundColor Red
    Write-Host "Fais un clic droit sur PowerShell -> Exécuter en tant qu'administrateur, puis lance le script."
    Pause
    exit
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host "Mise a jour des sources Winget..." -ForegroundColor Magenta
winget source update

$apps = @(
    # Navigateurs
    "Zen-Browser.Zen",
    "TorProject.TorBrowser",
    
    # Communication
    "Discord.Discord",
    "Telegram.TelegramDesktop",
    
    # Media & Création
    "Spotify.Spotify",
    "OBSProject.OBSStudio",
    "VideoLAN.VLC",
    "KDE.Kdenlive",
    "GIMP.GIMP",
    "BlenderFoundation.Blender",
    "rocksdanister.LivelyWallpaper",
    
    # Développement
    "Microsoft.VisualStudioCode",
    "Microsoft.VisualStudio.2022.Community",
    "JetBrains.IntelliJIDEA.Community",
    "JetBrains.PyCharm.Community",
    "Google.AndroidStudio",
    "WinSCP.WinSCP",
    "Ollama.Ollama",
    
    # Gaming
    "Valve.Steam",
    "PrismLauncher.PrismLauncher",
    "EpicGames.EpicGamesLauncher",
    "ElectronicArts.EADesktop",
    "Roblox.Roblox",
    "ppy.osu",
    
    # Utilitaires & Système
    "BleachBit.BleachBit",
    "voidtools.Everything",
    "9P9H03XGQ8S2",
    "Proton.ProtonVPN",
    "Oracle.VirtualBox",
    "Dev47Apps.DroidCamClient",
    "SoftDeluxe.FreeDownloadManager",
    "TrackerSoftware.PDF-XChangeEditor",
    "Microsoft.VisualStudio.2022.BuildTools"
)

Write-Host "`nInstallation de $($apps.Count) logiciels en cours..." -ForegroundColor Cyan

foreach ($app in $apps) {
    Write-Host "`n[Traitement] : $app" -ForegroundColor Yellow
    
    winget install --id $app --silent --accept-package-agreements --accept-source-agreements --upgrade --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS : $app est prêt." -ForegroundColor Green
    } else {
        Write-Host "INFO/NOTE : $app (Vérifie si déjà installé ou nécessite un reboot)." -ForegroundColor Gray
    }
}

Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host "                   TERMINE !                    " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Pause