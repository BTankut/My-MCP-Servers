# Working MCP Server Installer for Windows
param(
    [string[]]$Servers = @("github", "puppeteer", "sequential-thinking", "magic", "desktop-commander", "supabase"),
    [string]$App = "claude-code"
)

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Blue = "Blue"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

Write-Host "=== MCP Server Manager ===" -ForegroundColor $Blue
Write-Host "Installing MCP servers to $App..." -ForegroundColor $Green

$RegistryPath = Join-Path $ProjectDir "servers\registry.json"
if (-not (Test-Path $RegistryPath)) {
    Write-Host "ERROR: Registry not found: $RegistryPath" -ForegroundColor $Red
    exit 1
}

$Registry = Get-Content $RegistryPath | ConvertFrom-Json

foreach ($Server in $Servers) {
    Write-Host "`n--- Installing $Server ---" -ForegroundColor $Yellow
    
    $ServerConfig = $Registry.servers.$Server
    if (-not $ServerConfig) {
        Write-Host "ERROR: Server $Server not found in registry" -ForegroundColor $Red
        continue
    }
    
    try {
        if ($App -eq "claude-code") {
            if ($ServerConfig.config_template.command -eq "npx") {
                $Args = $ServerConfig.config_template.args -join " "
                $FullCommand = "claude mcp add $Server $($ServerConfig.config_template.command) $Args --scope user"
                Write-Host "Executing: $FullCommand" -ForegroundColor $Blue
                
                $result = Invoke-Expression $FullCommand 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "SUCCESS: $Server installed" -ForegroundColor $Green
                } else {
                    Write-Host "ERROR: $result" -ForegroundColor $Red
                }
            }
        }
    } catch {
        Write-Host "ERROR: Failed to install $Server - $($_.Exception.Message)" -ForegroundColor $Red
    }
}

Write-Host "`n=== Installation Summary ===" -ForegroundColor $Blue
Write-Host "Run 'claude mcp list' to verify all installations" -ForegroundColor $Yellow