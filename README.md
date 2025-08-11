# MCP Server Manager

Centralized MCP server configuration management for multiple applications and platforms.

## 🚀 Quick Start

### macOS/Linux
```bash
# Clone repository
git clone <your-repo-url>
cd My-MCP-Servers

# Interactive installation
./scripts/install.sh --interactive --backup

# Install all servers to Claude Code
./scripts/install.sh --all --apps=claude-code

# Install specific servers to multiple apps
./scripts/install.sh --servers=github,puppeteer --apps=claude-code,windsurf
```

### Windows
```powershell
# Interactive installation
.\scripts\install.ps1 -Interactive -Backup

# Install all servers to Claude Code
.\scripts\install.ps1 -All -Apps "claude-code"

# Install specific servers
.\scripts\install.ps1 -Servers "github,puppeteer" -Apps "claude-code,windsurf"
```

## 📋 Features

- ✅ **Multi-Platform**: Windows, macOS, Linux support
- ✅ **Multi-App**: Claude Code, Claude Desktop, Windsurf, Cursor, VS Code Cline
- ✅ **Interactive Installation**: Choose what to install with guided prompts
- ✅ **Backup System**: Automatic backup of existing configurations
- ✅ **Dry Run Mode**: Preview changes without making them
- ✅ **Server Registry**: Centralized server definitions and metadata

## 🎯 Supported Applications

| Application | Windows | macOS | Linux |
|-------------|---------|-------|-------|
| Claude Code | ✅ | ✅ | ✅ |
| Claude Desktop | ✅ | ✅ | ❌ |
| Windsurf | ✅ | ✅ | ❓ |
| Cursor | ✅ | ✅ | ❓ |
| VS Code Cline | ✅ | ✅ | ✅ |

## 🔧 Available Servers

Current registry includes:
- **github**: GitHub API integration
- **huggingface**: Hugging Face models and datasets
- **sequential-thinking**: Sequential reasoning capabilities
- **puppeteer**: Browser automation and web scraping
- **magic**: UI component generation (21st.dev)
- **context7**: Context-aware documentation
- **desktop-commander**: Desktop automation
- **cloud-run**: Google Cloud Run management
- **supabase**: Supabase database services

## 📝 Usage Examples

### Install Everything
```bash
# macOS/Linux
./scripts/install.sh --all --apps=all --backup

# Windows
.\scripts\install.ps1 -All -Apps "all" -Backup
```

### Selective Installation
```bash
# Only development-related servers to Claude Code
./scripts/install.sh --servers=github,puppeteer --apps=claude-code

# Only AI/ML servers to multiple apps
./scripts/install.sh --servers=huggingface,sequential-thinking --apps=claude-code,claude-desktop
```

### Interactive Mode (Recommended)
```bash
# macOS/Linux
./scripts/install.sh --interactive

# Windows
.\scripts\install.ps1 -Interactive
```

## 🛠️ Development

### Adding New Servers
1. Add server definition to `servers/registry.json`
2. Test installation with `--dry-run`
3. Create server-specific configuration templates in `configs/`

### Adding New Applications
1. Update `setup.json` with application details
2. Add detection logic to install scripts
3. Add configuration path handling

## 📁 Project Structure

```
My-MCP-Servers/
├── README.md                    # This file
├── setup.json                   # Main configuration
├── configs/                     # App-specific configurations
├── scripts/                     # Installation scripts
│   ├── install.sh              # macOS/Linux installer
│   ├── install.ps1             # Windows installer
│   └── utils/                  # Helper scripts
├── servers/                     # Server definitions
│   └── registry.json           # Server registry
└── docs/                       # Documentation
```

## 🔍 Troubleshooting

### Common Issues
1. **App not detected**: Ensure the application is properly installed
2. **Permission errors**: Run script with appropriate permissions
3. **Config not found**: Check if config paths match your system

### Backup Location
Backups are stored in `backups/YYYYMMDD_HHMMSS/` with timestamp.

### Dry Run Mode
Always test with `--dry-run` first:
```bash
./scripts/install.sh --dry-run --all --apps=claude-code
```

## 📄 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add your changes
4. Test thoroughly
5. Submit a pull request

---

**Note**: This is a community project for managing MCP servers. Always backup your configurations before making changes.