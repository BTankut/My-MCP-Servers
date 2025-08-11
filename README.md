# My MCP Servers

Automated installation and management system for MCP (Model Context Protocol) servers. Centralized repository for managing MCP servers across different applications and platforms.

## ⚠️ Current Platform Support

**✅ Fully Supported:**
- Windows 10/11 + Claude Code

**❌ Not Yet Supported (Planned):**
- macOS + Claude Code
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

## 📦 Available Servers (9 Total)

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

## 🛠️ Quick Start

### Prerequisites
- Windows 10/11
- Claude Code CLI installed
- PowerShell 5.1+ or PowerShell Core

### Installation
```bash
# Clone repository
git clone https://github.com/BTankut/My-MCP-Servers.git
cd My-MCP-Servers

# Install all servers (recommended)
.\scripts\install-working.ps1 -All

# Verify installation
claude mcp list
```

## 📋 Installation Options

### Option 1: Install All Servers (Recommended)
```powershell
.\scripts\install-working.ps1 -All
```
- Installs all 9 servers from registry
- Uses global scope (`--scope user`)
- Works across all projects

### Option 2: Install Specific Servers
```powershell
.\scripts\install-working.ps1 -Servers "github,puppeteer,magic"
```

### Option 3: Interactive Installation (Advanced)
```powershell
.\scripts\install-enhanced.ps1 -Interactive -SetupKeys
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
```powershell
[Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", "your_token_here", "User")
```

### Supabase API Keys
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project → Settings → API
3. Copy Project URL and anon key
4. Set environment variables:
```powershell
[Environment]::SetEnvironmentVariable("SUPABASE_URL", "https://your-project.supabase.co", "User")
[Environment]::SetEnvironmentVariable("SUPABASE_ANON_KEY", "your_anon_key_here", "User")
```

### Hugging Face API Token (Optional)
1. Go to [Hugging Face Settings → Access Tokens](https://huggingface.co/settings/tokens)
2. Create new token
3. Set environment variable:
```powershell
[Environment]::SetEnvironmentVariable("HUGGINGFACE_API_TOKEN", "your_token_here", "User")
```

### Google Cloud (for Cloud Run)
1. Create project at [Google Cloud Console](https://console.cloud.google.com)
2. Create service account and download JSON key
3. Set environment variables:
```powershell
[Environment]::SetEnvironmentVariable("GOOGLE_CLOUD_PROJECT", "your-project-id", "User")
[Environment]::SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", "path\to\key.json", "User")
```

## 🔧 Available Scripts

### `install-working.ps1` (Recommended)
- **Purpose**: Production-ready installer
- **Usage**: `.\scripts\install-working.ps1 -All`
- **Features**: Registry-based, HTTP support, error handling

### `install-enhanced.ps1` (Advanced)
- **Purpose**: Interactive installer with API key management
- **Usage**: `.\scripts\install-enhanced.ps1 -Interactive -SetupKeys`
- **Features**: Interactive mode, automatic API key setup

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
│   ├── install-enhanced.ps1     # Interactive installer
│   ├── install.ps1              # Legacy installer
│   └── install.sh               # macOS/Linux (planned)
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
- [ ] macOS support (`install-macos.sh`)
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

**⚠️ Important**: Currently only supports Windows + Claude Code. Other platforms are planned but not yet implemented.

**💡 Tip**: Use `-All` flag for first-time setup to install all available servers!