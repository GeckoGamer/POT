# serverstart.ps1
param(
    [string]$username = $env:USERNAME,
    [string]$password = $env:PASSWORD,
    [string]$guid = $env:GUID,
    [string]$authtoken = $env:AUTHTOKEN,
    [string]$branch = $env:BRANCH,
    [string]$port = $env:PORT,
    [string]$database = $env:DATABASE,
    [string]$additionalcommands = $env:ADDITIONAL_COMMANDS
)

# Set environment variables
$env:DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1"
$env:AG_AUTH_TOKEN = $authtoken

# Check if this is the first run
if (-not (Test-Path "C:\pot-server\CONTAINER_ALREADY_STARTED_PLACEHOLDER")) {
    Write-Host "*** Downloading Path of Titans Server"
    
    # Download and install the server
    Invoke-WebRequest -Uri "https://launcher-cdn.alderongames.com/AlderonGamesCmd-Win64.exe" -OutFile "C:\pot-server\AlderonGamesCmd-Win64.exe"
    
    Start-Process -FilePath "C:\pot-server\AlderonGamesCmd-Win64.exe" -ArgumentList @(
        "--game", "path-of-titans",
        "--server", "true",
        "--beta-branch", $branch,
        "--install-dir", ".\",
        "--username", $username,
        "--password", $password
    ) -Wait
    
    # Create placeholder file
    New-Item -ItemType File -Path "C:\pot-server\CONTAINER_ALREADY_STARTED_PLACEHOLDER" -Force
}

Write-Host "*** Starting Path of Titans Server"

# Start the server
$serverProcess = Start-Process -FilePath "C:\pot-server\PathOfTitans\Binaries\Win64\PathOfTitansServer-Win64-Shipping.exe" -ArgumentList @(
    "-Port=$port",
    "-BranchKey=$branch",
    "-log",
    "-Username=$username",
    "-Password=$password",
    "-ServerGUID=$guid",
    "-Database=$database",
    $additionalcommands
) -PassThru

# Signal handler for graceful shutdown
function Stop-Server {
    Write-Host "*** Stopping Path of Titans Server"
    if ($serverProcess -and (-not $serverProcess.HasExited)) {
        Stop-Process -Id $serverProcess.Id -Force
    }
    exit 0
}

# Register handler for termination signals
[Console]::TreatControlCAsInput = $true
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action { Stop-Server }

# Keep the container running
while ($true) {
    if ($serverProcess.HasExited) {
        Write-Host "Server process has exited unexpectedly"
        exit 1
    }
    Start-Sleep -Seconds 1
}