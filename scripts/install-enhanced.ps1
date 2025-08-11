# Enhanced MCP Server Installer with API Key Management
param(
    [string[]]$Servers = @(),
    [string]$App = "claude-code",
    [switch]$All,
    [switch]$Interactive,
    [switch]$SetupKeys,
    [switch]$Help
)

$Green = "Green"
$Red = "Red" 
$Yellow = "Yellow"
$Blue = "Blue"
$Cyan = "Cyan"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor $Blue }
function Write-Success { param($Message) Write-Host "[SUCCESS] $Message" -ForegroundColor $Green }
function Write-Warning { param($Message) Write-Host "[WARNING] $Message" -ForegroundColor $Yellow }
function Write-Error { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor $Red }
function Write-Header { param($Message) Write-Host "`n=== $Message ===" -ForegroundColor $Cyan }

function Show-Usage {
    @"
Enhanced MCP Server Manager - Installation with API Key Setup

Usage: .\install-enhanced.ps1 [OPTIONS]

Parameters:
    -Servers            Comma-separated list of servers to install
    -App               Target application (default: claude-code)
    -All               Install all available servers
    -Interactive       Interactive mode with server selection
    -SetupKeys         Setup API keys for servers that require them
    -Help              Show this help message

Examples:
    .\install-enhanced.ps1 -Interactive
    .\install-enhanced.ps1 -All -SetupKeys
    .\install-enhanced.ps1 -Servers "github,supabase" -SetupKeys
"@
}

function Get-Registry {
    $RegistryPath = Join-Path $ProjectDir "servers\registry.json"
    if (-not (Test-Path $RegistryPath)) {
        Write-Error "Registry file not found: $RegistryPath"
        exit 1
    }
    return Get-Content $RegistryPath | ConvertFrom-Json
}

function Get-AvailableServers {
    $Registry = Get-Registry
    return $Registry.servers.PSObject.Properties.Name
}

function Test-EnvVariable {
    param($VarName)
    $Value = [Environment]::GetEnvironmentVariable($VarName, "User")
    return -not [string]::IsNullOrEmpty($Value)
}

function Set-EnvVariable {
    param($VarName, $VarValue, $Description)
    
    Write-Info "Setting environment variable: $VarName"
    [Environment]::SetEnvironmentVariable($VarName, $VarValue, "User")
    
    # Also set for current session
    Set-Item -Path "env:$VarName" -Value $VarValue
    
    Write-Success "✓ $VarName configured ($Description)"
}

function Setup-ServerApiKeys {
    param($ServerName, $ServerConfig)
    
    if (-not $ServerConfig.requires_api_key) {
        return $true
    }
    
    Write-Header "API Key Setup for $ServerName"
    Write-Host $ServerConfig.api_key_config.instructions -ForegroundColor $Yellow
    Write-Host ""
    
    $AllKeysSet = $true
    
    foreach ($EnvVar in $ServerConfig.api_key_config.env_vars) {
        if (Test-EnvVariable $EnvVar.name) {
            Write-Success "✓ $($EnvVar.name) is already configured"
        } else {
            Write-Warning "✗ $($EnvVar.name) is not configured"
            
            if ($SetupKeys) {
                Write-Host "Setup URL: $($EnvVar.setup_url)" -ForegroundColor $Cyan
                Write-Host ""
                
                do {
                    $Value = Read-Host "Enter your $($EnvVar.description)"
                } while ([string]::IsNullOrEmpty($Value))
                
                Set-EnvVariable $EnvVar.name $Value $EnvVar.description
            } else {
                $AllKeysSet = $false
                Write-Warning "Use -SetupKeys flag to configure API keys interactively"
                Write-Host "  Setup URL: $($EnvVar.setup_url)" -ForegroundColor $Cyan
            }
        }
    }
    
    return $AllKeysSet
}

function Install-ServerToApp {
    param($ServerName, $App, $ServerConfig)
    
    Write-Info "Installing $ServerName to $App..."
    
    # Check and setup API keys first
    $KeysReady = Setup-ServerApiKeys $ServerName $ServerConfig
    
    if (-not $KeysReady -and -not $SetupKeys) {
        Write-Warning "⚠️  $ServerName requires API keys but they are not configured"
        Write-Warning "   Server will be installed but may not function properly"
        Write-Host "   Use -SetupKeys flag to configure API keys" -ForegroundColor $Yellow
    }
    
    try {
        if ($App -eq "claude-code") {
            if ($ServerConfig.config_template.command -eq "npx") {
                $Args = $ServerConfig.config_template.args -join " "
                $Command = "claude mcp add $ServerName $($ServerConfig.config_template.command) $Args --scope user"
                Write-Info "Executing: $Command"
                
                $result = Invoke-Expression $Command 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "✓ $ServerName installed successfully"
                    
                    if ($KeysReady) {
                        Write-Success "✓ API keys are configured and ready"
                    }
                } else {
                    Write-Error "Failed to install: $result"
                }
            }
        }
    } catch {
        Write-Error "Installation failed: $($_.Exception.Message)"
    }
}

function Start-InteractiveMode {
    Write-Header "MCP Server Manager - Interactive Installation"
    
    $Registry = Get-Registry
    $AvailableServers = Get-AvailableServers
    
    Write-Info "Available servers:"
    for ($i = 0; $i -lt $AvailableServers.Count; $i++) {
        $ServerName = $AvailableServers[$i]
        $ServerConfig = $Registry.servers.$ServerName
        $KeyIcon = if ($ServerConfig.requires_api_key) { " 🔑" } else { "" }
        
        Write-Host "  $($i + 1). $ServerName$KeyIcon - $($ServerConfig.description)" -ForegroundColor $Yellow
    }
    
    Write-Host "`n🔑 = Requires API Key" -ForegroundColor $Cyan
    Write-Host ""
    
    $Selection = Read-Host "Select servers to install (comma-separated numbers or 'all')"
    
    if ($Selection -eq "all") {
        $script:Servers = $AvailableServers
        $script:All = $true
    } else {
        $SelectedIndices = $Selection -split ","
        $script:Servers = @()
        foreach ($Index in $SelectedIndices) {
            $IndexInt = [int]$Index.Trim()
            if ($IndexInt -ge 1 -and $IndexInt -le $AvailableServers.Count) {
                $script:Servers += $AvailableServers[$IndexInt - 1]
            }
        }
    }
    
    Write-Host ""
    $KeySetup = Read-Host "Setup API keys for servers that require them? (y/n)"
    if ($KeySetup -eq "y" -or $KeySetup -eq "Y") {
        $script:SetupKeys = $true
    }
}

# Main execution
function Main {
    if ($Help) {
        Show-Usage
        exit 0
    }
    
    Write-Header "MCP Server Manager - Enhanced Installation"
    
    if ($Interactive) {
        Start-InteractiveMode
    }
    
    if ($All) {
        $script:Servers = Get-AvailableServers
    }
    
    if ($Servers.Count -eq 0) {
        Write-Error "No servers specified. Use -Interactive, -All, or -Servers"
        Show-Usage
        exit 1
    }
    
    Write-Info "Installation Plan:"
    Write-Host "  Target App: $App" -ForegroundColor $Yellow
    Write-Host "  Servers: $($Servers -join ', ')" -ForegroundColor $Yellow  
    Write-Host "  Setup API Keys: $SetupKeys" -ForegroundColor $Yellow
    Write-Host ""
    
    $Registry = Get-Registry
    
    foreach ($ServerName in $Servers) {
        $ServerConfig = $Registry.servers.$ServerName
        if (-not $ServerConfig) {
            Write-Error "Server '$ServerName' not found in registry"
            continue
        }
        
        Install-ServerToApp $ServerName $App $ServerConfig
        Write-Host ""
    }
    
    Write-Header "Installation Summary"
    Write-Success "Installation process completed!"
    Write-Info "Run 'claude mcp list' to verify server status"
    
    if ($SetupKeys) {
        Write-Info "Environment variables have been set for the current user"
        Write-Warning "You may need to restart your terminal for some applications to pick up the new environment variables"
    }
}

Main