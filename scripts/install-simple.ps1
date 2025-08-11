# Simple MCP Server Installer for Windows
param(
    [string[]]$Servers = @("github", "puppeteer", "sequential-thinking", "magic", "desktop-commander"),
    [string]$App = "claude-code"
)

# Colors
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

Write-Host "Installing MCP servers to $App..." -ForegroundColor $Green

# Load registry
$RegistryPath = Join-Path $ProjectDir "servers\registry.json"
if (-not (Test-Path $RegistryPath)) {
    Write-Host "Registry not found: $RegistryPath" -ForegroundColor $Red
    exit 1
}

$Registry = Get-Content $RegistryPath | ConvertFrom-Json

foreach ($Server in $Servers) {
    Write-Host "`nInstalling $Server..." -ForegroundColor $Yellow
    
    $ServerConfig = $Registry.servers.$Server
    if (-not $ServerConfig) {
        Write-Host "Server $Server not found in registry" -ForegroundColor $Red
        continue
    }
    
    try {
        if ($App -eq "claude-code") {
            if ($ServerConfig.config_template.command -eq "npx") {
                $Args = $ServerConfig.config_template.args -join " "
                $Command = "claude mcp add $Server $($ServerConfig.config_template.command) $Args"
                Write-Host "Running: $Command" -ForegroundColor $Yellow
                Invoke-Expression $Command
            } elseif ($ServerConfig.config_template.url) {
                $Command = "claude mcp add $Server --url `"$($ServerConfig.config_template.url)`""
                Write-Host "Running: $Command" -ForegroundColor $Yellow
                Invoke-Expression $Command
            }
        }
        
        Write-Host "✓ $Server installed successfully" -ForegroundColor $Green
    } catch {
        Write-Host "✗ Failed to install $Server : $($_.Exception.Message)" -ForegroundColor $Red
    }
}

Write-Host "`nInstallation completed!" -ForegroundColor $Green
Write-Host "Run 'claude mcp list' to verify installations." -ForegroundColor $Yellow