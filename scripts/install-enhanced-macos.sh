#!/bin/bash

# Enhanced MCP Server Installer for macOS with API Key Management
# Usage: ./install-enhanced-macos.sh [--all] [--servers=server1,server2] [--interactive] [--setup-keys]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
SERVERS=()
APP="claude-code"
ALL=false
INTERACTIVE=false
SETUP_KEYS=false

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Print functions
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${CYAN}=== $1 ===${NC}"; }

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
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        --setup-keys)
            SETUP_KEYS=true
            shift
            ;;
        -h|--help)
            cat << EOF
Enhanced MCP Server Manager - macOS Installation Script

Usage: $0 [OPTIONS]

Options:
    --servers=srv1,srv2,...  Install specific servers
    --app=APP               Target application (default: claude-code)
    --all                   Install all available servers
    --interactive           Interactive server selection
    --setup-keys            Interactive API key setup
    -h, --help              Show this help message

Examples:
    $0 --all                                    # Install all servers
    $0 --servers=github,puppeteer               # Install specific servers  
    $0 --interactive --setup-keys               # Full interactive setup
    $0 --setup-keys                            # Only setup API keys
EOF
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_header "Enhanced MCP Server Manager for macOS"

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check jq
    if ! command -v jq &> /dev/null; then
        print_error "jq is required for JSON parsing. Install it with: brew install jq"
        exit 1
    fi
    
    # Check Claude CLI
    if ! command -v claude &> /dev/null; then
        print_error "Claude Code CLI is not installed or not in PATH"
        print_info "Install it from: https://docs.anthropic.com/en/docs/claude-code"
        exit 1
    fi
    
    # Check registry
    REGISTRY_PATH="$PROJECT_DIR/servers/registry.json"
    if [ ! -f "$REGISTRY_PATH" ]; then
        print_error "Registry not found: $REGISTRY_PATH"
        exit 1
    fi
    
    print_success "All prerequisites met"
}

# Setup API keys interactively
setup_api_keys() {
    print_header "API Key Setup"
    
    # GitHub
    echo
    print_info "GitHub Personal Access Token Setup"
    echo "Required for: GitHub server functionality"
    echo "Setup URL: https://github.com/settings/tokens"
    
    if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
        echo -n "Enter GitHub Personal Access Token (or press Enter to skip): "
        read -s GITHUB_TOKEN
        echo
        if [ -n "$GITHUB_TOKEN" ]; then
            export GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN"
            print_success "GitHub token set for this session"
            print_info "To make permanent, add to your shell profile (~/.bashrc, ~/.zshrc):"
            echo "export GITHUB_PERSONAL_ACCESS_TOKEN=\"your_token_here\""
        else
            print_warning "GitHub token skipped - GitHub server may not work fully"
        fi
    else
        print_success "GitHub token already set"
    fi
    
    # Hugging Face
    echo
    print_info "Hugging Face API Token Setup (Optional)"
    echo "Required for: Hugging Face server functionality"
    echo "Setup URL: https://huggingface.co/settings/tokens"
    
    if [ -z "$HUGGINGFACE_API_TOKEN" ]; then
        echo -n "Enter Hugging Face API Token (or press Enter to skip): "
        read -s HF_TOKEN
        echo
        if [ -n "$HF_TOKEN" ]; then
            export HUGGINGFACE_API_TOKEN="$HF_TOKEN"
            print_success "Hugging Face token set for this session"
            print_info "To make permanent, add to your shell profile:"
            echo "export HUGGINGFACE_API_TOKEN=\"your_token_here\""
        else
            print_warning "Hugging Face token skipped - functionality may be limited"
        fi
    else
        print_success "Hugging Face token already set"
    fi
    
    # Supabase
    echo
    print_info "Supabase Configuration Setup"
    echo "Required for: Supabase server functionality"
    echo "Setup URL: https://app.supabase.com"
    
    if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
        echo -n "Enter Supabase URL (or press Enter to skip): "
        read SUPABASE_URL_INPUT
        if [ -n "$SUPABASE_URL_INPUT" ]; then
            echo -n "Enter Supabase Anon Key: "
            read -s SUPABASE_ANON_INPUT
            echo
            if [ -n "$SUPABASE_ANON_INPUT" ]; then
                export SUPABASE_URL="$SUPABASE_URL_INPUT"
                export SUPABASE_ANON_KEY="$SUPABASE_ANON_INPUT"
                print_success "Supabase configuration set for this session"
                print_info "To make permanent, add to your shell profile:"
                echo "export SUPABASE_URL=\"your_project_url\""
                echo "export SUPABASE_ANON_KEY=\"your_anon_key\""
            fi
        else
            print_warning "Supabase configuration skipped"
        fi
    else
        print_success "Supabase configuration already set"
    fi
}

# Interactive server selection
interactive_selection() {
    print_header "Interactive Server Selection"
    
    mapfile -t ALL_SERVERS < <(jq -r '.servers | keys[]' "$REGISTRY_PATH")
    
    echo "Available servers:"
    for i in "${!ALL_SERVERS[@]}"; do
        SERVER="${ALL_SERVERS[i]}"
        DESCRIPTION=$(jq -r ".servers.\"$SERVER\".description" "$REGISTRY_PATH")
        REQUIRES_KEY=$(jq -r ".servers.\"$SERVER\".requires_api_key // false" "$REGISTRY_PATH")
        KEY_INFO=""
        if [ "$REQUIRES_KEY" = "true" ]; then
            KEY_INFO=" ${YELLOW}(requires API key)${NC}"
        fi
        echo -e "  $((i+1)). ${GREEN}$SERVER${NC} - $DESCRIPTION$KEY_INFO"
    done
    
    echo
    echo "Select servers to install:"
    echo "  - Enter numbers separated by spaces (e.g., 1 3 5)"
    echo "  - Enter 'all' for all servers"
    echo "  - Press Enter for none"
    
    read -p "Your selection: " SELECTION
    
    if [ "$SELECTION" = "all" ]; then
        SERVERS=("${ALL_SERVERS[@]}")
        ALL=true
    elif [ -n "$SELECTION" ]; then
        SERVERS=()
        for num in $SELECTION; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#ALL_SERVERS[@]} ]; then
                SERVERS+=("${ALL_SERVERS[$((num-1))]}")
            fi
        done
    fi
    
    if [ ${#SERVERS[@]} -gt 0 ]; then
        print_success "Selected servers: ${SERVERS[*]}"
    else
        print_warning "No servers selected"
        exit 0
    fi
}

# Install server function
install_server() {
    local SERVER=$1
    
    print_warning "--- Installing $SERVER ---"
    
    # Get server config from registry
    SERVER_CONFIG=$(jq ".servers.\"$SERVER\"" "$REGISTRY_PATH")
    
    if [ "$SERVER_CONFIG" = "null" ]; then
        print_error "Server $SERVER not found in registry"
        return 1
    fi
    
    # Check if API key is required
    REQUIRES_KEY=$(echo "$SERVER_CONFIG" | jq -r '.requires_api_key // false')
    if [ "$REQUIRES_KEY" = "true" ]; then
        print_info "$SERVER requires API keys - please ensure they are configured"
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
            
            if eval "$FULL_COMMAND" 2>/dev/null; then
                print_success "$SERVER installed successfully"
                return 0
            else
                print_error "Failed to install $SERVER"
                return 1
            fi
            
        elif [ -n "$TRANSPORT_URL" ]; then
            # Handle HTTP-based servers
            FULL_COMMAND="claude mcp add \"$SERVER\" --transport http \"$TRANSPORT_URL\" --scope user"
            
            print_info "Executing: $FULL_COMMAND"
            
            if eval "$FULL_COMMAND" 2>/dev/null; then
                print_success "$SERVER installed successfully (HTTP)"
                return 0
            else
                print_error "Failed to install $SERVER (HTTP)"
                return 1
            fi
        else
            print_error "Unknown configuration format for $SERVER"
            return 1
        fi
    else
        print_warning "App $APP not supported yet (only claude-code is implemented)"
        return 1
    fi
}

# Main execution
main() {
    check_prerequisites
    
    # Setup API keys if requested
    if [ "$SETUP_KEYS" = true ]; then
        setup_api_keys
    fi
    
    # Interactive mode
    if [ "$INTERACTIVE" = true ]; then
        interactive_selection
    fi
    
    # Get all servers from registry if --all flag is used or no servers specified
    if [ "$ALL" = true ] || [ ${#SERVERS[@]} -eq 0 ]; then
        if [ "$INTERACTIVE" = false ]; then
            mapfile -t SERVERS < <(jq -r '.servers | keys[]' "$REGISTRY_PATH")
            print_warning "Installing all servers from registry: ${SERVERS[*]}"
        fi
    fi
    
    # Exit if no servers to install
    if [ ${#SERVERS[@]} -eq 0 ]; then
        print_warning "No servers to install"
        exit 0
    fi
    
    print_header "Server Installation"
    
    # Install each server
    SUCCESSFUL=0
    FAILED=0
    
    for SERVER in "${SERVERS[@]}"; do
        echo
        if install_server "$SERVER"; then
            ((SUCCESSFUL++))
        else
            ((FAILED++))
        fi
    done
    
    # Summary
    echo
    print_header "Installation Summary"
    print_success "Successfully installed: $SUCCESSFUL servers"
    if [ $FAILED -gt 0 ]; then
        print_error "Failed to install: $FAILED servers"
    fi
    
    print_warning "Run 'claude mcp list' to verify all installations"
    print_info "Restart Claude Code session if servers are not visible immediately"
    
    if [ $FAILED -gt 0 ]; then
        exit 1
    fi
}

# If only setting up keys, do that and exit
if [ "$SETUP_KEYS" = true ] && [ ${#SERVERS[@]} -eq 0 ] && [ "$ALL" = false ] && [ "$INTERACTIVE" = false ]; then
    check_prerequisites
    setup_api_keys
    exit 0
fi

# Run main function
main