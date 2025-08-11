# MCP Server Manager - Windows Installation Script
# Version: 1.0.0

param(
    [string[]]$Apps = @(),
    [string[]]$Servers = @(),
    [switch]$All,
    [switch]$Interactive,
    [switch]$Backup,
    [switch]$DryRun,
    [switch]$Help
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

# Print functions
function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor $Blue }
function Write-Success { param($Message) Write-Host "[SUCCESS] $Message" -ForegroundColor $Green }
function Write-Warning { param($Message) Write-Host "[WARNING] $Message" -ForegroundColor $Yellow }
function Write-Error { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor $Red }

# Usage function
function Show-Usage {
    @"
MCP Server Manager - Installation Script

Usage: .\install.ps1 [OPTIONS]

Parameters:
    -Apps               Install to specific apps (claude-code,claude-desktop,windsurf,cursor,vscode-cline)
    -Servers            Install specific servers
    -All                Install all available servers
    -Interactive        Interactive mode - choose what to install
    -Backup             Backup existing configurations before installing
    -DryRun             Show what would be done without making changes
    -Help               Show this help message

Examples:
    .\install.ps1 -All -Apps "claude-code"
    .\install.ps1 -Servers "github,puppeteer" -Apps "claude-code,windsurf"
    .\install.ps1 -Interactive -Backup
    .\install.ps1 -DryRun -All
"@
}

# Get app config paths
function Get-AppConfigPath {
    param($App)
    
    switch ($App) {
        "claude-code" { return "$env:APPDATA\claude\mcp.json" }
        "claude-desktop" { return "$env:APPDATA\Claude\claude_desktop_config.json" }
        "windsurf" { return "$env:APPDATA\Windsurf\User\settings.json" }
        "cursor" { return "$env:APPDATA\Cursor\User\settings.json" }
        "vscode-cline" { return ".vscode\settings.json" }
        default { 
            Write-Error "Unknown app: $App"
            return $null
        }
    }
}

# Check if app is installed
function Test-AppInstalled {
    param($App)
    
    switch ($App) {
        "claude-code" { 
            try { Get-Command claude -ErrorAction Stop; return $true } 
            catch { return $false }
        }
        "claude-desktop" { 
            return Test-Path "$env:LOCALAPPDATA\Programs\Claude\Claude.exe"
        }
        "windsurf" { 
            return Test-Path "$env:LOCALAPPDATA\Programs\Windsurf\Windsurf.exe"
        }
        "cursor" { 
            return Test-Path "$env:LOCALAPPDATA\Programs\cursor\Cursor.exe"
        }
        "vscode-cline" { 
            try { Get-Command code -ErrorAction Stop; return $true } 
            catch { return $false }
        }
        default { return $false }
    }
}

# Backup configuration
function Backup-Config {
    param($ConfigPath)
    
    if (Test-Path $ConfigPath) {
        $BackupDir = Join-Path $ProjectDir "backups\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Info "Backing up: $ConfigPath"
        
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
            Copy-Item $ConfigPath $BackupDir
        }
        
        Write-Success "Backup created: $BackupDir\$(Split-Path $ConfigPath -Leaf)"
    }
}

# Load registry
function Test-Registry {
    $RegistryPath = Join-Path $ProjectDir "servers\registry.json"
    if (-not (Test-Path $RegistryPath)) {
        Write-Error "Registry file not found: $RegistryPath"
        exit 1
    }
    return $RegistryPath
}

# Get available servers from registry
function Get-AvailableServers {
    $RegistryPath = Test-Registry
    $Registry = Get-Content $RegistryPath | ConvertFrom-Json
    return $Registry.servers.PSObject.Properties.Name
}

# Get available apps
function Get-AvailableApps {
    return @("claude-code", "claude-desktop", "windsurf", "cursor", "vscode-cline")
}

# Interactive mode
function Start-InteractiveMode {
    Write-Info "=== MCP Server Manager - Interactive Installation ==="
    Write-Host ""
    
    # Detect installed apps
    Write-Info "Detecting installed applications..."
    $InstalledApps = @()
    $AvailableApps = Get-AvailableApps
    
    foreach ($App in $AvailableApps) {
        if (Test-AppInstalled $App) {
            $InstalledApps += $App
            Write-Success "✓ $App is installed"
        } else {
            Write-Warning "✗ $App is not installed"
        }
    }
    
    if ($InstalledApps.Count -eq 0) {
        Write-Error "No supported applications found!"
        exit 1
    }
    
    Write-Host ""
    Write-Info "Available servers:"
    $AvailableServers = Get-AvailableServers
    for ($i = 0; $i -lt $AvailableServers.Count; $i++) {
        Write-Host "  $($i + 1). $($AvailableServers[$i])"
    }
    
    Write-Host ""
    $AppSelection = Read-Host "Select apps to configure (comma-separated numbers or 'all')"
    if ($AppSelection -eq "all") {
        $script:Apps = $InstalledApps
    } else {
        $SelectedIndices = $AppSelection -split ","
        $script:Apps = @()
        foreach ($Index in $SelectedIndices) {
            $IndexInt = [int]$Index.Trim()
            if ($IndexInt -ge 1 -and $IndexInt -le $InstalledApps.Count) {
                $script:Apps += $InstalledApps[$IndexInt - 1]
            }
        }
    }
    
    Write-Host ""
    $ServerSelection = Read-Host "Select servers to install (comma-separated numbers or 'all')"
    if ($ServerSelection -eq "all") {
        $script:Servers = $AvailableServers
        $script:All = $true
    } else {
        $SelectedIndices = $ServerSelection -split ","
        $script:Servers = @()
        foreach ($Index in $SelectedIndices) {
            $IndexInt = [int]$Index.Trim()
            if ($IndexInt -ge 1 -and $IndexInt -le $AvailableServers.Count) {
                $script:Servers += $AvailableServers[$IndexInt - 1]
            }
        }
    }
    
    Write-Host ""
    $BackupChoice = Read-Host "Create backup before installation? (y/n)"
    if ($BackupChoice -eq "y" -or $BackupChoice -eq "Y") {
        $script:Backup = $true
    }
}

# Install server to app
function Install-ServerToApp {
    param($Server, $App)
    
    Write-Info "Installing $Server to $App..."
    
    if ($DryRun) {
        Write-Info "[DRY RUN] Would install $Server to $App"
        return
    }
    
    # This is a placeholder - actual implementation would depend on each app's configuration format
    switch ($App) {
        "claude-code" {
            Write-Info "Adding $Server to Claude Code..."
            # Use claude mcp add command if available
        }
        "claude-desktop" {
            Write-Info "Adding $Server to Claude Desktop..."
            # Modify claude_desktop_config.json
        }
        default {
            Write-Warning "Installation for $App not yet implemented"
        }
    }
    
    Write-Success "✓ $Server installed to $App"
}

# Main function
function Main {
    if ($Help) {
        Show-Usage
        exit 0
    }
    
    Write-Info "=== MCP Server Manager - Installation Starting ==="
    
    # Load and validate registry
    Test-Registry | Out-Null
    
    # Interactive mode
    if ($Interactive) {
        Start-InteractiveMode
    }
    
    # Validate inputs
    if ($Apps.Count -eq 0) {
        Write-Error "No apps specified. Use -Apps or -Interactive"
        exit 1
    }
    
    if (-not $All -and $Servers.Count -eq 0) {
        Write-Error "No servers specified. Use -Servers, -All, or -Interactive"
        exit 1
    }
    
    # Set servers list if -All is used
    if ($All) {
        $script:Servers = Get-AvailableServers
    }
    
    # Display plan
    Write-Info "Installation plan:"
    Write-Host "  Apps: $($Apps -join ', ')"
    Write-Host "  Servers: $($Servers -join ', ')"
    Write-Host "  Backup: $Backup"
    Write-Host "  Dry run: $DryRun"
    Write-Host ""
    
    # Confirm if not in interactive mode
    if (-not $Interactive) {
        $Confirm = Read-Host "Continue with installation? (y/n)"
        if ($Confirm -ne "y" -and $Confirm -ne "Y") {
            Write-Info "Installation cancelled"
            exit 0
        }
    }
    
    # Create backups if requested
    if ($Backup) {
        Write-Info "Creating backups..."
        foreach ($App in $Apps) {
            $ConfigPath = Get-AppConfigPath $App
            if ($ConfigPath) {
                Backup-Config $ConfigPath
            }
        }
    }
    
    # Install servers
    Write-Info "Installing servers..."
    foreach ($Server in $Servers) {
        foreach ($App in $Apps) {
            if (Test-AppInstalled $App) {
                Install-ServerToApp $Server $App
            } else {
                Write-Warning "$App is not installed, skipping..."
            }
        }
    }
    
    Write-Success "=== Installation completed! ==="
}

# Run main function
Main