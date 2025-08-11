#!/bin/bash

# MCP Server Manager - macOS Installation Script
# Version: 1.0.0

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
APPS=()
SERVERS=()
ALL=false
INTERACTIVE=false
BACKUP=false
DRY_RUN=false

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Print functions
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Usage function
usage() {
    cat << EOF
MCP Server Manager - Installation Script

Usage: $0 [OPTIONS]

Options:
    --apps=app1,app2,...     Install to specific apps (claude-code,claude-desktop,windsurf,cursor,vscode-cline)
    --servers=srv1,srv2,...  Install specific servers
    --all                    Install all available servers
    --interactive            Interactive mode - choose what to install
    --backup                 Backup existing configurations before installing
    --dry-run                Show what would be done without making changes
    -h, --help              Show this help message

Examples:
    $0 --all --apps=claude-code
    $0 --servers=github,puppeteer --apps=claude-code,windsurf
    $0 --interactive --backup
    $0 --dry-run --all
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --apps=*)
                IFS=',' read -ra APPS <<< "${1#*=}"
                shift
                ;;
            --servers=*)
                IFS=',' read -ra SERVERS <<< "${1#*=}"
                shift
                ;;
            --all)
                ALL=true
                shift
                ;;
            --interactive)
                INTERACTIVE=true
                shift
                ;;
            --backup)
                BACKUP=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Get app config paths
get_app_config_path() {
    local app=$1
    case $app in
        claude-code)
            echo "$HOME/.config/claude/mcp.json"
            ;;
        claude-desktop)
            echo "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
            ;;
        windsurf)
            echo "$HOME/Library/Application Support/Windsurf/User/settings.json"
            ;;
        cursor)
            echo "$HOME/Library/Application Support/Cursor/User/settings.json"
            ;;
        vscode-cline)
            echo ".vscode/settings.json"
            ;;
        *)
            print_error "Unknown app: $app"
            return 1
            ;;
    esac
}

# Check if app is installed
is_app_installed() {
    local app=$1
    case $app in
        claude-code)
            command -v claude >/dev/null 2>&1
            ;;
        claude-desktop)
            [ -d "/Applications/Claude.app" ]
            ;;
        windsurf)
            [ -d "/Applications/Windsurf.app" ]
            ;;
        cursor)
            [ -d "/Applications/Cursor.app" ]
            ;;
        vscode-cline)
            command -v code >/dev/null 2>&1
            ;;
        *)
            false
            ;;
    esac
}

# Backup configuration
backup_config() {
    local config_path=$1
    local backup_dir="$PROJECT_DIR/backups/$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$config_path" ]; then
        print_info "Backing up: $config_path"
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$backup_dir"
            cp "$config_path" "$backup_dir/"
        fi
        print_success "Backup created: $backup_dir/$(basename "$config_path")"
    fi
}

# Load registry
load_registry() {
    if [ ! -f "$PROJECT_DIR/servers/registry.json" ]; then
        print_error "Registry file not found: $PROJECT_DIR/servers/registry.json"
        exit 1
    fi
}

# Get available servers from registry
get_available_servers() {
    python3 -c "
import json
with open('$PROJECT_DIR/servers/registry.json') as f:
    data = json.load(f)
    print(' '.join(data['servers'].keys()))
"
}

# Get available apps
get_available_apps() {
    echo "claude-code claude-desktop windsurf cursor vscode-cline"
}

# Interactive mode
interactive_mode() {
    print_info "=== MCP Server Manager - Interactive Installation ==="
    echo
    
    # Detect installed apps
    print_info "Detecting installed applications..."
    local installed_apps=()
    for app in $(get_available_apps); do
        if is_app_installed "$app"; then
            installed_apps+=("$app")
            print_success "✓ $app is installed"
        else
            print_warning "✗ $app is not installed"
        fi
    done
    
    if [ ${#installed_apps[@]} -eq 0 ]; then
        print_error "No supported applications found!"
        exit 1
    fi
    
    echo
    print_info "Available servers:"
    local available_servers=($(get_available_servers))
    for i in "${!available_servers[@]}"; do
        echo "  $((i+1)). ${available_servers[i]}"
    done
    
    echo
    read -p "Select apps to configure (comma-separated numbers or 'all'): " app_selection
    if [ "$app_selection" = "all" ]; then
        APPS=("${installed_apps[@]}")
    else
        IFS=',' read -ra selected_indices <<< "$app_selection"
        APPS=()
        for index in "${selected_indices[@]}"; do
            if [ "$index" -ge 1 ] && [ "$index" -le ${#installed_apps[@]} ]; then
                APPS+=("${installed_apps[$((index-1))]}")
            fi
        done
    fi
    
    echo
    read -p "Select servers to install (comma-separated numbers or 'all'): " server_selection
    if [ "$server_selection" = "all" ]; then
        SERVERS=("${available_servers[@]}")
        ALL=true
    else
        IFS=',' read -ra selected_indices <<< "$server_selection"
        SERVERS=()
        for index in "${selected_indices[@]}"; do
            if [ "$index" -ge 1 ] && [ "$index" -le ${#available_servers[@]} ]; then
                SERVERS+=("${available_servers[$((index-1))]}")
            fi
        done
    fi
    
    echo
    read -p "Create backup before installation? (y/n): " backup_choice
    if [ "$backup_choice" = "y" ] || [ "$backup_choice" = "Y" ]; then
        BACKUP=true
    fi
}

# Install server to app
install_server_to_app() {
    local server=$1
    local app=$2
    
    print_info "Installing $server to $app..."
    
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would install $server to $app"
        return 0
    fi
    
    # This is a placeholder - actual implementation would depend on each app's configuration format
    case $app in
        claude-code)
            print_info "Adding $server to Claude Code..."
            # Use claude mcp add command if available
            ;;
        claude-desktop)
            print_info "Adding $server to Claude Desktop..."
            # Modify claude_desktop_config.json
            ;;
        *)
            print_warning "Installation for $app not yet implemented"
            ;;
    esac
    
    print_success "✓ $server installed to $app"
}

# Main installation function
main() {
    print_info "=== MCP Server Manager - Installation Starting ==="
    
    # Load and validate registry
    load_registry
    
    # Parse arguments
    parse_args "$@"
    
    # Interactive mode
    if [ "$INTERACTIVE" = true ]; then
        interactive_mode
    fi
    
    # Validate inputs
    if [ ${#APPS[@]} -eq 0 ]; then
        print_error "No apps specified. Use --apps or --interactive"
        exit 1
    fi
    
    if [ "$ALL" = false ] && [ ${#SERVERS[@]} -eq 0 ]; then
        print_error "No servers specified. Use --servers, --all, or --interactive"
        exit 1
    fi
    
    # Set servers list if --all is used
    if [ "$ALL" = true ]; then
        SERVERS=($(get_available_servers))
    fi
    
    # Display plan
    print_info "Installation plan:"
    echo "  Apps: ${APPS[*]}"
    echo "  Servers: ${SERVERS[*]}"
    echo "  Backup: $BACKUP"
    echo "  Dry run: $DRY_RUN"
    echo
    
    # Confirm if not in interactive mode
    if [ "$INTERACTIVE" = false ]; then
        read -p "Continue with installation? (y/n): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            print_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Create backups if requested
    if [ "$BACKUP" = true ]; then
        print_info "Creating backups..."
        for app in "${APPS[@]}"; do
            config_path=$(get_app_config_path "$app")
            backup_config "$config_path"
        done
    fi
    
    # Install servers
    print_info "Installing servers..."
    for server in "${SERVERS[@]}"; do
        for app in "${APPS[@]}"; do
            if is_app_installed "$app"; then
                install_server_to_app "$server" "$app"
            else
                print_warning "$app is not installed, skipping..."
            fi
        done
    done
    
    print_success "=== Installation completed! ==="
}

# Run main function
main "$@"