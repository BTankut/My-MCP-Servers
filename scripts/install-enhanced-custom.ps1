# Enhanced MCP Server Installer with Custom Server Support
# Supports NPX, HTTP, and Custom/Local Build servers

param(
    [string[]]$Servers = @(),
    [string]$App = "claude-code",
    [switch]$All,
    [switch]$SetupKeys,
    [switch]$Interactive
)

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Blue = "Blue"
$Cyan = "Cyan"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

function Write-Header { param($Message) Write-Host "=== $Message ===" -ForegroundColor $Cyan }
function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor $Blue }
function Write-Success { param($Message) Write-Host "[SUCCESS] $Message" -ForegroundColor $Green }
function Write-Warning { param($Message) Write-Host "[WARNING] $Message" -ForegroundColor $Yellow }
function Write-Error { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor $Red }

Write-Header "Enhanced MCP Server Manager with Custom Support"

$RegistryPath = Join-Path $ProjectDir "servers\registry.json"
if (-not (Test-Path $RegistryPath)) {
    Write-Error "Registry not found: $RegistryPath"
    exit 1
}

$Registry = Get-Content $RegistryPath | ConvertFrom-Json

# Setup API keys function
function Setup-ApiKeys {
    Write-Header "API Key Setup"
    
    # RunPod API Key
    if (-not $env:RUNPOD_API_KEY) {
        Write-Info "RunPod API Key Setup"
        Write-Host "Required for: RunPod server functionality"
        Write-Host "Setup URL: https://www.runpod.io/console/user/settings"
        $RunPodKey = Read-Host "Enter RunPod API Key (or press Enter to skip)" -AsSecureString
        if ($RunPodKey.Length -gt 0) {
            $PlainKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($RunPodKey))
            [Environment]::SetEnvironmentVariable("RUNPOD_API_KEY", $PlainKey, "User")
            $env:RUNPOD_API_KEY = $PlainKey
            Write-Success "RunPod API key set"
            Write-Info "Restart PowerShell to use the key in future sessions"
        }
    } else {
        Write-Success "RunPod API key already set"
    }
    
    # GitHub Token
    if (-not $env:GITHUB_PERSONAL_ACCESS_TOKEN) {
        Write-Info "GitHub Personal Access Token Setup"
        Write-Host "Setup URL: https://github.com/settings/tokens"
        $GitHubToken = Read-Host "Enter GitHub Token (or press Enter to skip)" -AsSecureString
        if ($GitHubToken.Length -gt 0) {
            $PlainToken = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($GitHubToken))
            [Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", $PlainToken, "User")
            $env:GITHUB_PERSONAL_ACCESS_TOKEN = $PlainToken
            Write-Success "GitHub token set"
        }
    }
}

# Interactive server selection
function Select-Servers-Interactive {
    Write-Header "Interactive Server Selection"
    
    $AllServers = $Registry.servers.PSObject.Properties.Name
    Write-Host "Available servers:"
    
    for ($i = 0; $i -lt $AllServers.Count; $i++) {
        $ServerName = $AllServers[$i]
        $ServerConfig = $Registry.servers.$ServerName
        $Description = $ServerConfig.description
        $RequiresKey = if ($ServerConfig.requires_api_key) { " (requires API key)" } else { "" }
        $RequiresBuild = if ($ServerConfig.requires_local_build) { " (requires local build)" } else { "" }
        
        Write-Host "  $($i + 1). $ServerName - $Description$RequiresKey$RequiresBuild"
    }
    
    Write-Host ""
    $Selection = Read-Host "Select servers (numbers separated by spaces, or 'all')"
    
    if ($Selection -eq "all") {
        return $AllServers
    } else {
        $SelectedServers = @()
        $Numbers = $Selection -split " "
        foreach ($Num in $Numbers) {
            $Index = [int]$Num - 1
            if ($Index -ge 0 -and $Index -lt $AllServers.Count) {
                $SelectedServers += $AllServers[$Index]
            }
        }
        return $SelectedServers
    }
}

# Check if custom server is locally built
function Test-CustomServerBuilt {
    param($ServerName, $ServerConfig)
    
    if (-not $ServerConfig.requires_local_build) {
        return $true
    }
    
    # Check common locations for the server
    $PossiblePaths = @(
        "$HOME\$ServerName-mcp\build\index.js",
        "$HOME\$ServerName-mcp-ts\build\index.js",
        "$env:USERPROFILE\$ServerName-mcp\build\index.js",
        "$env:USERPROFILE\$ServerName-mcp-ts\build\index.js"
    )
    
    foreach ($Path in $PossiblePaths) {
        if (Test-Path $Path) {
            return $Path
        }
    }
    
    return $false
}

# Install custom server
function Install-CustomServer {
    param($ServerName, $ServerConfig)
    
    Write-Warning "Custom server installation required for: $ServerName"
    Write-Host "This server requires manual installation steps:"
    
    foreach ($Step in $ServerConfig.local_install_steps) {
        Write-Host "  - $Step"
    }
    
    Write-Host ""
    $Proceed = Read-Host "Have you completed the installation steps? (y/n)"
    
    if ($Proceed -ne "y") {
        Write-Warning "Skipping $ServerName - manual installation required"
        return $false
    }
    
    # Try to find the built server
    $ServerPath = Test-CustomServerBuilt $ServerName $ServerConfig
    if (-not $ServerPath) {
        Write-Error "Could not find built server for $ServerName"
        Write-Info "Please ensure you've run the installation steps above"
        return $false
    }
    
    # Install with the found path
    $Args = $ServerConfig.config_template.args -replace "{{RUNPOD_MCP_PATH}}", (Split-Path -Parent (Split-Path -Parent $ServerPath))
    $FullCommand = "claude mcp add $ServerName $($ServerConfig.config_template.command) $($Args -join ' ') --scope user"
    
    Write-Info "Executing: $FullCommand"
    
    try {
        $result = Invoke-Expression $FullCommand 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$ServerName installed successfully (Custom)"
            return $true
        } else {
            Write-Error "Failed to install $ServerName"
            return $false
        }
    } catch {
        Write-Error "Failed to install $ServerName - $($_.Exception.Message)"
        return $false
    }
}

# Install server function
function Install-Server {
    param($ServerName)
    
    Write-Warning "--- Installing $ServerName ---"
    
    $ServerConfig = $Registry.servers.$ServerName
    if (-not $ServerConfig) {
        Write-Error "Server $ServerName not found in registry"
        return $false
    }
    
    # Check if server requires API key
    if ($ServerConfig.requires_api_key) {
        Write-Info "$ServerName requires API keys - ensure they are configured"
    }
    
    try {
        if ($App -eq "claude-code") {
            # Handle custom/local build servers
            if ($ServerConfig.requires_local_build) {
                return Install-CustomServer $ServerName $ServerConfig
            }
            # Handle NPX servers
            elseif ($ServerConfig.config_template.command -eq "npx") {
                $Args = $ServerConfig.config_template.args -join " "
                $FullCommand = "claude mcp add $ServerName $($ServerConfig.config_template.command) $Args --scope user"
                Write-Info "Executing: $FullCommand"
                
                $result = Invoke-Expression $FullCommand 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "$ServerName installed successfully"
                    return $true
                } else {
                    Write-Error "Failed to install $ServerName"
                    return $false
                }
            }
            # Handle HTTP servers
            elseif ($ServerConfig.config_template.url) {
                $FullCommand = "claude mcp add $ServerName --transport http $($ServerConfig.config_template.url) --scope user"
                Write-Info "Executing: $FullCommand"
                
                $result = Invoke-Expression $FullCommand 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "$ServerName installed successfully (HTTP)"
                    return $true
                } else {
                    Write-Error "Failed to install $ServerName (HTTP)"
                    return $false
                }
            }
            else {
                Write-Error "Unknown server configuration for $ServerName"
                return $false
            }
        } else {
            Write-Warning "App $App not supported yet"
            return $false
        }
    } catch {
        Write-Error "Failed to install $ServerName - $($_.Exception.Message)"
        return $false
    }
}

# Main execution
if ($SetupKeys) {
    Setup-ApiKeys
}

if ($Interactive) {
    $Servers = Select-Servers-Interactive
}

# If -All flag is used or no servers specified, get all from registry
if ($All -or $Servers.Count -eq 0) {
    $Servers = $Registry.servers.PSObject.Properties.Name
    Write-Warning "Installing all servers from registry: $($Servers -join ', ')"
}

Write-Header "Server Installation"

$Successful = 0
$Failed = 0
$Skipped = 0

foreach ($Server in $Servers) {
    Write-Host ""
    $Result = Install-Server $Server
    if ($Result -eq $true) {
        $Successful++
    } elseif ($Result -eq $false) {
        $Failed++
    } else {
        $Skipped++
    }
}

Write-Host ""
Write-Header "Installation Summary"
Write-Success "Successfully installed: $Successful servers"
if ($Failed -gt 0) {
    Write-Error "Failed to install: $Failed servers"
}
if ($Skipped -gt 0) {
    Write-Warning "Skipped: $Skipped servers"
}

Write-Warning "Run 'claude mcp list' to verify all installations"
Write-Info "Restart Claude Code session if servers are not visible immediately"