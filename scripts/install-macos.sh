#!/bin/bash

# Working MCP Server Installer for macOS
# Usage: ./install-macos.sh [--all] [--servers=server1,server2] [--app=claude-code]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SERVERS=()
APP="claude-code"
ALL=false

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Print functions
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --servers=*)
            IFS=',' read -ra SERVERS <<< "${1#*=}"
            shift
            ;;
        --app=*)
            APP="${1#*=}"
            shift
            ;;
        --all)
            ALL=true
            shift
            ;;
        -h|--help)
            cat << EOF
MCP Server Manager - macOS Installation Script

Usage: $0 [OPTIONS]

Options:
    --servers=srv1,srv2,...  Install specific servers
    --app=APP               Target application (default: claude-code)
    --all                   Install all available servers
    -h, --help              Show this help message

Examples:
    $0 --all
    $0 --servers=github,puppeteer
    $0 --servers=magic --app=claude-code
EOF
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_info "=== MCP Server Manager for macOS ==="
print_info "Installing MCP servers to $APP..."

# Check if registry exists
REGISTRY_PATH="$PROJECT_DIR/servers/registry.json"
if [ ! -f "$REGISTRY_PATH" ]; then
    print_error "Registry not found: $REGISTRY_PATH"
    exit 1
fi

# Check if jq is available for JSON parsing
if ! command -v jq &> /dev/null; then
    print_error "jq is required for JSON parsing. Install it with: brew install jq"
    exit 1
fi

# Check if claude command is available
if ! command -v claude &> /dev/null; then
    print_error "Claude Code CLI is not installed or not in PATH"
    print_info "Install it from: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# Get all servers from registry if --all flag is used or no servers specified
if [ "$ALL" = true ] || [ ${#SERVERS[@]} -eq 0 ]; then
    mapfile -t SERVERS < <(jq -r '.servers | keys[]' "$REGISTRY_PATH")
    print_warning "Installing all servers from registry: ${SERVERS[*]}"
fi

# Install each server
for SERVER in "${SERVERS[@]}"; do
    echo
    print_warning "--- Installing $SERVER ---"
    
    # Get server config from registry
    SERVER_CONFIG=$(jq ".servers.\"$SERVER\"" "$REGISTRY_PATH")
    
    if [ "$SERVER_CONFIG" = "null" ]; then
        print_error "Server $SERVER not found in registry"
        continue
    fi
    
    # Extract configuration
    COMMAND_TYPE=$(echo "$SERVER_CONFIG" | jq -r '.config_template.command // empty')
    TRANSPORT_URL=$(echo "$SERVER_CONFIG" | jq -r '.config_template.url // empty')
    
    if [ "$APP" = "claude-code" ]; then
        if [ -n "$COMMAND_TYPE" ] && [ "$COMMAND_TYPE" = "npx" ]; then
            # Handle NPX-based servers
            ARGS=$(echo "$SERVER_CONFIG" | jq -r '.config_template.args[]' | tr '\n' ' ')
            FULL_COMMAND="claude mcp add \"$SERVER\" npx $ARGS --scope user"
            
            print_info "Executing: $FULL_COMMAND"
            
            if eval "$FULL_COMMAND"; then
                print_success "$SERVER installed successfully"
            else
                print_error "Failed to install $SERVER"
            fi
            
        elif [ -n "$TRANSPORT_URL" ]; then
            # Handle HTTP-based servers
            FULL_COMMAND="claude mcp add \"$SERVER\" --transport http \"$TRANSPORT_URL\" --scope user"
            
            print_info "Executing: $FULL_COMMAND"
            
            if eval "$FULL_COMMAND"; then
                print_success "$SERVER installed successfully (HTTP)"
            else
                print_error "Failed to install $SERVER (HTTP)"
            fi
        else
            print_error "Unknown configuration format for $SERVER"
        fi
    else
        print_warning "App $APP not supported yet (only claude-code is implemented)"
    fi
done

echo
print_info "=== Installation Summary ==="
print_warning "Run 'claude mcp list' to verify all installations"
print_info "Restart Claude Code session if servers are not visible immediately"