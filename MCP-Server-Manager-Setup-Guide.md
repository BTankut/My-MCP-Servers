# MCP Server Manager - Kurulum ve Planlama Rehberi

## 📋 Proje Özeti

Bu proje, farklı işletim sistemleri (Windows/macOS) ve farklı uygulamalar (Claude Code, Windsurf, Cursor, VS Code Cline, Claude Desktop) için MCP server'larını merkezi bir yerden yönetmeyi sağlayan otomatik kurulum sistemi.

## 🏗️ Repository Yapısı

```
my-mcp-servers/
├── README.md                     # Ana kullanım rehberi
├── setup.json                    # Ana konfigürasyon dosyası
├── configs/                      # Uygulama-specific konfigürasyonlar
│   ├── claude-code/
│   │   ├── windows.mcp.json
│   │   └── macos.mcp.json
│   ├── windsurf/
│   │   ├── windows.json
│   │   └── macos.json
│   ├── cursor/
│   │   ├── settings.json
│   ├── vscode-cline/
│   │   ├── settings.json
│   └── claude-desktop/
│       ├── claude_desktop_config.json (Windows)
│       └── claude_desktop_config.json (macOS)
├── scripts/                      # Otomatik kurulum scriptleri
│   ├── install.ps1               # Windows ana installer
│   ├── install.sh                # macOS ana installer
│   ├── uninstall.ps1             # Windows kaldırma
│   ├── uninstall.sh              # macOS kaldırma
│   ├── add-server.ps1            # Yeni server ekleme (Windows)
│   ├── add-server.sh             # Yeni server ekleme (macOS)
│   └── utils/
│       ├── detect-apps.ps1       # Kurulu uygulamaları tespit
│       ├── detect-apps.sh        # Kurulu uygulamaları tespit
│       ├── backup.ps1            # Mevcut ayarları backup
│       └── backup.sh             # Mevcut ayarları backup
├── servers/                      # MCP Server tanımları
│   ├── registry.json             # Tüm server listesi ve meta bilgiler
│   ├── filesystem/
│   │   ├── config.json
│   │   └── install-commands.json
│   ├── database/
│   ├── web-scraper/
│   └── custom/                   # Özel server'lar
└── docs/                         # Dokümantasyon
    ├── app-specific-setup.md     # Uygulama-specific kurulum rehberi
    ├── server-development.md     # Yeni server ekleme rehberi
    └── troubleshooting.md        # Sorun giderme
```

## 🎯 Özellikler

### 1. Multi-Platform Desteği
- **Windows**: PowerShell scriptleri
- **macOS**: Bash scriptleri
- Platform-specific path ve komutlar

### 2. Multi-App Desteği
| Uygulama | Windows Config Path | macOS Config Path |
|----------|-------------------|-------------------|
| Claude Code | `%APPDATA%\claude\mcp.json` | `~/.config/claude/mcp.json` |
| Claude Desktop | `%APPDATA%\Claude\claude_desktop_config.json` | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| VS Code Cline | `.vscode/settings.json` | `.vscode/settings.json` |
| Cursor | `%APPDATA%\Cursor\User\settings.json` | `~/Library/Application Support/Cursor/User/settings.json` |
| Windsurf | `%APPDATA%\Windsurf\User\settings.json` | `~/Library/Application Support/Windsurf/User/settings.json` |

### 3. Kurulum Seçenekleri
```bash
# Tüm server'ları tüm uygulamalara kur
./install.sh --all --apps=all

# Sadece belirli server'ları kur
./install.sh --servers=filesystem,database --apps=claude-code,windsurf

# Sadece belirli uygulamalara kur
./install.sh --all --apps=claude-code

# Interactive mode (kullanıcı seçer)
./install.sh --interactive
```

## 📝 Kurulum Adımları

### 1. Repository Oluşturma
```bash
# GitHub'da yeni repo oluştur: my-mcp-servers
git clone https://github.com/[username]/my-mcp-servers.git
cd my-mcp-servers

# İlk yapıyı oluştur
mkdir -p configs/{claude-code,windsurf,cursor,vscode-cline,claude-desktop}
mkdir -p scripts/utils
mkdir -p servers/custom
mkdir -p docs
```

### 2. Mevcut MCP Server'ları İçe Aktarma
```bash
# Claude Code'daki mevcut server'ları listele
claude mcp list

# Her server için config export et
claude mcp export filesystem > servers/filesystem/config.json
```

### 3. Registry Dosyası Oluşturma (servers/registry.json)
```json
{
  "servers": {
    "filesystem": {
      "name": "Filesystem MCP",
      "description": "File system operations",
      "npm_package": "@mcp-server/filesystem",
      "github_repo": "modelcontextprotocol/servers",
      "install_command": {
        "npm": "npm install -g @mcp-server/filesystem",
        "pip": null
      },
      "config_template": {
        "command": "filesystem",
        "args": ["--root-path", "/"]
      },
      "supported_platforms": ["windows", "macos", "linux"],
      "supported_apps": ["claude-code", "claude-desktop", "windsurf"]
    }
  }
}
```

### 4. Ana Kurulum Scripti Özellikleri

#### Windows (install.ps1)
```powershell
param(
    [string[]]$Apps = @(),
    [string[]]$Servers = @(),
    [switch]$All,
    [switch]$Interactive,
    [switch]$Backup
)
```

#### macOS (install.sh)
```bash
#!/bin/bash
APPS=()
SERVERS=()
ALL=false
INTERACTIVE=false
BACKUP=false
```

### 5. Örnek Kullanım Senaryoları

#### Senaryo 1: Yeni bilgisayar kurulumu
```bash
# Repo'yu klonla
git clone https://github.com/[username]/my-mcp-servers.git

# Interactive kurulum
./scripts/install.sh --interactive --backup

# Kullanıcı seçer:
# - Hangi uygulamalar kurulu?
# - Hangi server'ları kurmak istiyor?
# - Backup yapmak istiyor mu?
```

#### Senaryo 2: Yeni server ekleme
```bash
# Yeni server ekle
./scripts/add-server.sh --name=custom-api --npm=@custom/api-mcp

# Registry'ye otomatik ekler ve config template'ini oluşturur
```

#### Senaryo 3: Sadece belirli app için kurulum
```bash
# Sadece Claude Code için tüm server'ları kur
./scripts/install.sh --all --apps=claude-code

# Windsurf'e sadece filesystem server'ını ekle
./scripts/install.sh --servers=filesystem --apps=windsurf
```

## 🔧 Geliştirme Planı

### Faz 1: Temel Yapı
1. Repository yapısını oluştur
2. Registry sistemini kur
3. Temel install script'lerini yaz

### Faz 2: Multi-App Desteği
1. Her uygulama için config template'leri
2. Path detection logic
3. App-specific kurulum komutları

### Faz 3: İleri Özellikler
1. Interactive kurulum modu
2. Backup/restore sistem
3. Update mekanizması
4. Conflict resolution

### Faz 4: Extras
1. Web UI (opsiyonel)
2. Server marketplace integration
3. Team sharing özellikleri

## 🚀 İlk Adımlar

1. **GitHub repo oluştur**: `my-mcp-servers`
2. **Bu dosyayı repoya ekle**: `README.md` olarak
3. **Mevcut server'ları export et**: `claude mcp list` ile başla
4. **İlk script'i yaz**: Basit bir server eklemek için
5. **Test et**: Bir server'ı farklı app'e kurarak

## 💡 İpuçları

- Başlangıçta sadece Claude Code desteği ile başla
- Her script'te `--dry-run` modu ekle
- Config dosyalarını commit etmeden önce sensitive bilgileri temizle
- Her major değişiklikte backup al
- Script'lerde error handling ekle

## 🔍 Sonraki Adımlar

1. Bu rehberi takip ederek repo'yu kur
2. İlk MCP server'ını export et
3. Basit bir install script'i yaz
4. Test et ve iterasyon yap
5. Diğer uygulamalar için destek ekle

---

**Not**: Bu doküman bir başlangıç planıdır. Geliştirme sürecinde güncellenecektir.