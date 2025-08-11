# Working MCP Server Installer for Windows
param(
    [string[]]$Servers = @(),
    [string]$App = "claude-code",
    [switch]$All
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

# If -All flag is used or no servers specified, get all from registry
if ($All -or $Servers.Count -eq 0) {
    $Servers = $Registry.servers.PSObject.Properties.Name
    Write-Host "Installing all servers from registry: $($Servers -join ', ')" -ForegroundColor $Yellow
}

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
            } elseif ($ServerConfig.config_template.url) {
                $FullCommand = "claude mcp add $Server --transport http $($ServerConfig.config_template.url) --scope user"
                Write-Host "Executing: $FullCommand" -ForegroundColor $Blue
                
                $result = Invoke-Expression $FullCommand 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "SUCCESS: $Server installed (HTTP)" -ForegroundColor $Green
                } else {
                    Write-Host "ERROR: $result" -ForegroundColor $Red
                }
            } elseif ($ServerConfig.install_command.type -eq "custom") {
                Write-Host "CUSTOM SERVER: $Server requires manual installation" -ForegroundColor $Yellow
                Write-Host "Instructions: $($ServerConfig.install_command.instructions)" -ForegroundColor $Yellow
                
                if ($ServerConfig.github_repo) {
                    Write-Host "Repository: $($ServerConfig.github_repo)" -ForegroundColor "Cyan"
                }
                
                if ($ServerConfig.local_install_steps) {
                    Write-Host "Installation steps:" -ForegroundColor "Cyan"
                    foreach ($step in $ServerConfig.local_install_steps) {
                        Write-Host "  - $step" -ForegroundColor "Cyan"
                    }
                }
                
                # Check if RunPod server is built locally
                if ($Server -eq "runpod") {
                    # Try to find RunPod in common locations
                    $PossiblePaths = @(
                        ".\runpod-mcp-ts\build\index.js",
                        "..\runpod-mcp-ts\build\index.js", 
                        "$env:USERPROFILE\runpod-mcp-ts\build\index.js",
                        "C:\runpod-mcp-ts\build\index.js"
                    )
                    
                    $RunPodPath = $null
                    foreach ($Path in $PossiblePaths) {
                        if (Test-Path $Path) {
                            $RunPodPath = (Resolve-Path $Path).Path
                            break
                        }
                    }
                    
                    if ($RunPodPath) {
                        $WrapperPath = Join-Path (Split-Path $RunPodPath -Parent) "runpod-wrapper.bat"
                        Write-Host "RunPod server found locally!" -ForegroundColor $Green
                        
                        # Create wrapper if doesn't exist
                        if (-not (Test-Path $WrapperPath)) {
                            Write-Host "Creating wrapper script..." -ForegroundColor $Blue
                            $WrapperContent = @"
@echo off
REM RunPod MCP Server Wrapper Script
REM This script sets environment variables and launches the RunPod MCP server

REM Set RunPod API Key (placeholder - set actual key via environment variable)
if not defined RUNPOD_API_KEY (
    echo Warning: RUNPOD_API_KEY environment variable is not set
    echo Please set your RunPod API key:
    echo [Environment]::SetEnvironmentVariable("RUNPOD_API_KEY", "your_api_key_here", "User")
)

REM Launch RunPod MCP server
node "$RunPodPath" %*
"@
                            Set-Content -Path $WrapperPath -Value $WrapperContent
                            Write-Host "Wrapper script created at: $WrapperPath" -ForegroundColor $Green
                        }
                        
                        # Install to Claude Code
                        $FullCommand = "claude mcp add $Server `"$WrapperPath`" --scope user"
                        Write-Host "Executing: $FullCommand" -ForegroundColor $Blue
                        
                        $result = Invoke-Expression $FullCommand 2>&1
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "SUCCESS: $Server installed (Custom)" -ForegroundColor $Green
                        } else {
                            Write-Host "ERROR: $result" -ForegroundColor $Red
                        }
                    } else {
                        Write-Host "WARNING: RunPod server not found in common locations" -ForegroundColor $Red
                        Write-Host "Please clone and build the server first:" -ForegroundColor $Yellow
                        Write-Host "  git clone https://github.com/runpod/runpod-mcp-ts.git" -ForegroundColor $Yellow
                        Write-Host "  cd runpod-mcp-ts" -ForegroundColor $Yellow
                        Write-Host "  npm install && npm run build" -ForegroundColor $Yellow
                    }
                }
            }
        }
    } catch {
        Write-Host "ERROR: Failed to install $Server - $($_.Exception.Message)" -ForegroundColor $Red
    }
}

Write-Host "`n=== Installation Summary ===" -ForegroundColor $Blue
Write-Host "Run 'claude mcp list' to verify all installations" -ForegroundColor $Yellow