# My MCP Servers

Kişisel MCP (Model Context Protocol) server koleksiyonunuz için otomatik kurulum ve yönetim sistemi. Windows ve macOS üzerinde Claude Code, Claude Desktop, Windsurf, Cursor ve VS Code Cline uygulamaları için MCP server'larını tek komutla kurun.

## 🚀 Özellikler

- ✅ **Otomatik kurulum** - Tek komutla tüm MCP server'ları kur
- 🔑 **API Key yönetimi** - Gerekli API key'lerini interaktif kurulum
- 🌐 **Multi-platform** - Windows ve macOS desteği  
- 📱 **Multi-app** - 5 farklı uygulama desteği
- 📋 **İnteraktif mod** - Kullanıcı dostu kurulum süreci
- 🔄 **Scope yönetimi** - Local, project ve user scope seçenekleri

## 📦 Kurulu Server'lar

| Server | Açıklama | API Key | Durum |
|--------|----------|---------|-------|
| **GitHub** 🐙 | Repository yönetimi ve API entegrasyonu | 🔑 Gerekli | ✅ |
| **Puppeteer** 🎭 | Browser automation ve web scraping | ❌ | ✅ |
| **Sequential Thinking** 🧠 | AI reasoning ve düşünce zincirleri | ❌ | ✅ |
| **Magic** ✨ | UI component generation (21st.dev) | ❌ | ✅ |
| **Desktop Commander** 💻 | Desktop automation ve sistem kontrolü | ❌ | ✅ |
| **Supabase** 🗄️ | Database ve backend servisleri | 🔑 Gerekli | ⚠️ |
| **Context7** 📚 | Context-aware dokümantasyon | ❌ | ⚠️ |
| **Hugging Face** 🤗 | AI model ve dataset erişimi | 🔑 Opsiyonel | ⚠️ |
| **Cloud Run** ☁️ | Google Cloud Run yönetimi | 🔑 Gerekli | ⚠️ |

## 🛠️ Kurulum

### Hızlı Başlangıç
```bash
# Repo'yu klonla
git clone https://github.com/BTankut/My-MCP-Servers.git
cd My-MCP-Servers

# İnteraktif kurulum (Önerilen)
.\scripts\install-enhanced.ps1 -Interactive -SetupKeys
```

### Kurulum Seçenekleri

#### 1. İnteraktif Kurulum (Önerilen)
```powershell
.\scripts\install-enhanced.ps1 -Interactive -SetupKeys
```
- Server'ları seçebilirsiniz
- API key'leri otomatik ayarlar
- Adım adım rehberlik

#### 2. Tüm Server'ları Kur
```powershell
.\scripts\install-enhanced.ps1 -All -SetupKeys
```

#### 3. Belirli Server'ları Kur
```powershell
.\scripts\install-enhanced.ps1 -Servers "github,puppeteer,magic" -SetupKeys
```

#### 4. API Key'siz Kurulum
```powershell
.\scripts\install-enhanced.ps1 -All
```

## 🔑 API Key Kurulumu

### GitHub Personal Access Token
1. GitHub → Settings → Developer settings → Personal access tokens
2. "Generate new token" → Classic token
3. Scope'ları seç: `repo`, `user`, `gist`
4. Token'ı kopyala

### Supabase API Keys
1. [Supabase Dashboard](https://app.supabase.com) → Project seç
2. Settings → API
3. Project URL ve anon key'i kopyala

### Manuel Environment Variable Kurulumu
```powershell
# GitHub
[Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", "your_token_here", "User")

# Supabase  
[Environment]::SetEnvironmentVariable("SUPABASE_URL", "https://your-project.supabase.co", "User")
[Environment]::SetEnvironmentVariable("SUPABASE_ANON_KEY", "your_anon_key_here", "User")
```

## 📱 Desteklenen Uygulamalar

| Uygulama | Windows | macOS | Durum |
|----------|---------|-------|-------|
| **Claude Code** | ✅ | ✅ | Tam destek |
| **Claude Desktop** | ✅ | ✅ | Geliştiriliyor |
| **Windsurf** | ⚠️ | ⚠️ | Planlanan |
| **Cursor** | ⚠️ | ⚠️ | Planlanan |
| **VS Code Cline** | ⚠️ | ⚠️ | Planlanan |

## 🔧 Script'ler

### `install-enhanced.ps1` (Ana Script)
En gelişmiş kurulum script'i:
- İnteraktif mod
- API key yönetimi
- Environment variable kurulumu
- Server seçimi

### `install-working.ps1` (Basit)
Test edilmiş, hızlı kurulum:
- Temel server kurulumu
- Hata ayıklama çıktıları

### `install.ps1` (Gelişmiş)
Tam özellikli script:
- Multi-app desteği
- Backup özelliği
- Dry-run modu

## 📋 Kullanım Örnekleri

### Yeni Bilgisayar Kurulumu
```powershell
# 1. Repo'yu klonla
git clone https://github.com/BTankut/My-MCP-Servers.git
cd My-MCP-Servers

# 2. İnteraktif kurulum
.\scripts\install-enhanced.ps1 -Interactive -SetupKeys

# 3. Kurulumu kontrol et  
claude mcp list
```

### Sadece GitHub ve Magic Server'ı Kur
```powershell
.\scripts\install-enhanced.ps1 -Servers "github,magic" -SetupKeys
```

### Tüm Server'ları API Key'siz Test Et
```powershell
.\scripts\install-enhanced.ps1 -All
```

## 🔍 Sorun Giderme

### MCP Server'lar Görünmüyor
```bash
# Session'ı yeniden başlat
exit
claude

# Scope kontrolü
claude mcp list
```

### API Key Hataları
```powershell
# Environment variable'ları kontrol et
[Environment]::GetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", "User")

# Manuel kurulum
.\scripts\install-enhanced.ps1 -SetupKeys
```

### Bağlantı Sorunları
```bash
# Server durumunu kontrol et
claude mcp list

# Problematik server'ı yeniden kur
claude mcp remove server_name
.\scripts\install-enhanced.ps1 -Servers "server_name" -SetupKeys
```

## 📈 Gelecek Özellikler

- [ ] macOS script desteği (`install.sh`)
- [ ] Claude Desktop konfigürasyonu
- [ ] Windsurf/Cursor entegrasyonu
- [ ] Server update mekanizması
- [ ] Web UI (opsiyonel)
- [ ] Team sharing özellikleri
- [ ] Otomatik backup/restore

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/new-server`)
3. Commit yapın (`git commit -am 'Add new server'`)
4. Push yapın (`git push origin feature/new-server`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje kişisel kullanım içindir. MCP server'ların kendi lisansları geçerlidir.

---

**💡 İpucu:** İlk kez kurulum yapıyorsanız `-Interactive -SetupKeys` parametrelerini kullanın!