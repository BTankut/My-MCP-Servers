# My MCP Servers

Automated installation and management system for MCP (Model Context Protocol) servers. Centralized repository for managing MCP servers across different applications and platforms.

## ⚠️ Current Platform Support

**✅ Fully Supported:**
- Windows 10/11 + Claude Code
- macOS + Claude Code

**❌ Not Yet Supported (Planned):**
- Linux + Claude Code  
- Claude Desktop (Windows/macOS)
- Windsurf IDE
- Cursor IDE
- VS Code with Cline extension

## 🚀 Features

- ✅ **Automatic Installation** - Install all MCP servers with a single command
- 🔑 **API Key Management** - Interactive setup for required API keys
- 🌍 **Global Scope** - Servers available across all projects (`--scope user`)
- 📦 **Registry-based** - Dynamic server list from `servers/registry.json`
- 🔄 **HTTP Transport Support** - Works with both NPX and HTTP-based servers
- 📋 **Easy Management** - Add, remove, and list servers effortlessly

## 📦 Available Servers (10 Total)

| Server | Description | API Key | Status |
|--------|-------------|---------|---------|
| **GitHub** 🐙 | Repository management and API integration | 🔑 Required | ✅ Working |
| **Puppeteer** 🎭 | Browser automation and web scraping | ❌ None | ✅ Working |
| **Sequential Thinking** 🧠 | AI reasoning and thought chains | ❌ None | ✅ Working |
| **Magic** ✨ | UI component generation (21st.dev) | ❌ None | ✅ Working |
| **Desktop Commander** 💻 | Desktop automation and system control | ❌ None | ✅ Working |
| **Context7** 📚 | Context-aware documentation | ❌ None | ✅ Working (HTTP) |
| **Cloud Run** ☁️ | Google Cloud Run management | 🔑 Required | ✅ Working |
| **Supabase** 🗄️ | Database and backend services | 🔑 Required | ⚠️ Needs API Keys |
| **Hugging Face** 🤗 | AI model and dataset access | 🔑 Optional | ⚠️ Needs API Keys |
| **RunPod** 🏃 | GPU cloud infrastructure management | 🔑 Required | 🔧 Custom Install |

## 🛠️ Quick Start

### Prerequisites

**Windows:**
- Windows 10/11
- Claude Code CLI installed
- PowerShell 5.1+ or PowerShell Core

**macOS:**
- macOS 10.15+
- Claude Code CLI installed
- Bash shell
- jq (install with: `brew install jq`)

### Installation

**Windows:**
```powershell
# Clone repository
git clone https://github.com/BTankut/My-MCP-Servers.git
cd My-MCP-Servers

# Install all servers (recommended)
.\scripts\install-working.ps1 -All

# Verify installation
claude mcp list
```

**macOS:**
```bash
# Clone repository
git clone https://github.com/BTankut/My-MCP-Servers.git
cd My-MCP-Servers

# Install jq if not already installed
brew install jq

# Install all servers (recommended)
./scripts/install-macos.sh --all

# Verify installation
claude mcp list
```

## 📋 Installation Options

### Option 1: Install All Servers (Recommended)

**Windows:**
```powershell
.\scripts\install-working.ps1 -All
```

**macOS:**
```bash
./scripts/install-macos.sh --all
```

- Installs all 9 servers from registry
- Uses global scope (`--scope user`)
- Works across all projects

### Option 2: Install Specific Servers

**Windows:**
```powershell
.\scripts\install-working.ps1 -Servers "github,puppeteer,magic"
```

**macOS:**
```bash
./scripts/install-macos.sh --servers=github,puppeteer,magic
```

### Option 3: Interactive Installation (Advanced)

**Windows:**
```powershell
.\scripts\install-enhanced.ps1 -Interactive -SetupKeys
```

**macOS:**
```bash
./scripts/install-enhanced-macos.sh --interactive --setup-keys
```

- Choose specific servers
- Interactive API key setup
- Step-by-step guidance

## 🔑 API Key Setup

Some servers require API keys for full functionality:

### GitHub Personal Access Token
1. Go to [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
2. Generate new token (classic)
3. Select scopes: `repo`, `user`, `gist`
4. Set environment variable:

**Windows:**
```powershell
[Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", "your_token_here", "User")
```

**macOS:**
```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export GITHUB_PERSONAL_ACCESS_TOKEN="your_token_here"' >> ~/.zshrc
source ~/.zshrc
```

### Supabase API Keys
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project → Settings → API
3. Copy Project URL and anon key
4. Set environment variables:

**Windows:**
```powershell
[Environment]::SetEnvironmentVariable("SUPABASE_URL", "https://your-project.supabase.co", "User")
[Environment]::SetEnvironmentVariable("SUPABASE_ANON_KEY", "your_anon_key_here", "User")
```

**macOS:**
```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export SUPABASE_URL="https://your-project.supabase.co"' >> ~/.zshrc
echo 'export SUPABASE_ANON_KEY="your_anon_key_here"' >> ~/.zshrc
source ~/.zshrc
```

### Hugging Face API Token (Optional)
1. Go to [Hugging Face Settings → Access Tokens](https://huggingface.co/settings/tokens)
2. Create new token
3. Set environment variable:

**Windows:**
```powershell
[Environment]::SetEnvironmentVariable("HUGGINGFACE_API_TOKEN", "your_token_here", "User")
```

**macOS:**
```bash
# Add to ~/.bashrc or ~/.zshrc  
echo 'export HUGGINGFACE_API_TOKEN="your_token_here"' >> ~/.zshrc
source ~/.zshrc
```

### Google Cloud (for Cloud Run)
1. Create project at [Google Cloud Console](https://console.cloud.google.com)
2. Create service account and download JSON key
3. Set environment variables:

**Windows:**
```powershell
[Environment]::SetEnvironmentVariable("GOOGLE_CLOUD_PROJECT", "your-project-id", "User")
[Environment]::SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", "path\to\key.json", "User")
```

**macOS:**
```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export GOOGLE_CLOUD_PROJECT="your-project-id"' >> ~/.zshrc
echo 'export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"' >> ~/.zshrc
source ~/.zshrc
```

### RunPod API Key
1. Go to [RunPod Console → User Settings](https://www.runpod.io/console/user/settings)
2. Create new API key
3. Set environment variable:

**Windows:**
```powershell
[Environment]::SetEnvironmentVariable("RUNPOD_API_KEY", "your_api_key_here", "User")
```

**macOS:**
```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export RUNPOD_API_KEY="your_api_key_here"' >> ~/.zshrc
source ~/.zshrc
```

## 🔧 Custom Server Setup (RunPod)

RunPod server requires manual installation as it's not available via NPX:

**Prerequisites:**
- Node.js 18+ installed
- Git installed

**Installation:**
```bash
# Clone RunPod MCP server
git clone https://github.com/runpod/runpod-mcp-ts.git
cd runpod-mcp-ts

# Install dependencies and build
npm install
npm run build

# Set API key (see API Key Setup above)
export RUNPOD_API_KEY="your_api_key_here"
```

**Using Enhanced Custom Installer:**

**Windows:**
```powershell
.\scripts\install-enhanced-custom.ps1 -Interactive -SetupKeys
```

**macOS:**
```bash
./scripts/install-enhanced-custom-macos.sh --interactive --setup-keys
```

The installer will:
1. Guide you through API key setup
2. Check if RunPod server is built locally
3. Install it to Claude Code automatically

## 🔧 Available Scripts

### `install-working.ps1` (Recommended)
- **Purpose**: Production-ready installer
- **Usage**: `.\scripts\install-working.ps1 -All`
- **Features**: Registry-based, HTTP support, error handling

### `install-enhanced.ps1` (Advanced)
- **Purpose**: Interactive installer with API key management
- **Usage**: `.\scripts\install-enhanced.ps1 -Interactive -SetupKeys`
- **Features**: Interactive mode, automatic API key setup

### `install-enhanced-custom.ps1` (Custom Servers)
- **Purpose**: Support for custom/local build servers like RunPod
- **Usage**: `.\scripts\install-enhanced-custom.ps1 -Interactive -SetupKeys`
- **Features**: Custom server detection, local build support

### `install-macos.sh` (macOS Simple)
- **Purpose**: Production-ready installer for macOS
- **Usage**: `./scripts/install-macos.sh --all`
- **Features**: Registry-based, error handling

### `install-enhanced-custom-macos.sh` (macOS Custom)
- **Purpose**: macOS installer with custom server support
- **Usage**: `./scripts/install-enhanced-custom-macos.sh --interactive --setup-keys`
- **Features**: Interactive mode, custom server detection

### `install.ps1` (Legacy)
- **Purpose**: Feature-complete installer
- **Usage**: `.\scripts\install.ps1 -All -Apps "claude-code"`
- **Features**: Multi-app support, backup, dry-run mode

## 📁 Project Structure

```
My-MCP-Servers/
├── README.md                    # This file
├── scripts/
│   ├── install-working.ps1      # Main installer (Windows)
│   ├── install-enhanced.ps1     # Interactive installer (Windows)
│   ├── install-macos.sh         # Main installer (macOS)
│   ├── install-enhanced-macos.sh # Interactive installer (macOS)
│   ├── install.ps1              # Legacy installer (Windows)
│   └── install.sh               # Legacy installer (macOS/Linux)
├── servers/
│   └── registry.json            # Server definitions
└── configs/                     # Platform-specific configs (planned)
    ├── claude-desktop/
    ├── windsurf/
    └── cursor/
```

## 🔍 Troubleshooting

### MCP Servers Not Visible
```bash
# Restart Claude Code session
exit
claude

# Check server status
claude mcp list
```

### API Key Issues
```powershell
# Check environment variables
[Environment]::GetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", "User")

# Setup keys interactively
.\scripts\install-enhanced.ps1 -SetupKeys
```

### Connection Issues
```bash
# Check server health
claude mcp list

# Reinstall problematic server
claude mcp remove server_name
.\scripts\install-working.ps1 -Servers "server_name"
```

## 🚧 Roadmap

### Platform Support
- [x] macOS support (`install-macos.sh`)
- [ ] Linux support (`install-linux.sh`)
- [ ] Claude Desktop configuration
- [ ] Windsurf IDE integration
- [ ] Cursor IDE integration
- [ ] VS Code Cline extension support

### Features
- [ ] Server update mechanism
- [ ] Configuration backup/restore
- [ ] Web UI (optional)
- [ ] Team sharing capabilities
- [ ] Custom server development templates

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-server`)
3. Make your changes
4. Test thoroughly on Windows + Claude Code
5. Submit a pull request

### Adding New Servers
1. Add server definition to `servers/registry.json`
2. Test installation with `.\scripts\install-working.ps1 -Servers "new-server"`
3. Update README.md server table
4. Submit PR

## 📄 License

This project is for personal use. Individual MCP servers have their own licenses.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/BTankut/My-MCP-Servers/issues)
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check this README and script comments

---

**⚠️ Important**: Currently supports Windows + Claude Code and macOS + Claude Code. Other platforms are planned but not yet implemented.

**💡 Tip**: Use `-All` flag for first-time setup to install all available servers!