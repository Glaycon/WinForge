# ⚡ Pós-Formatação Automática

> Script PowerShell interativo para automação de pós-formatação de computadores com Windows 10 e 11.

**Desenvolvido por [Glaycon Oliveira](https://glaycon.github.io)**

---

## 🚀 Como Usar (Uma Linha!)

### Método 1 — PowerShell (Recomendado)
Abra o **PowerShell como Administrador** e execute:

```powershell
irm https://raw.githubusercontent.com/glaycon/PosFormatacao/main/install.ps1 | iex
```

### Método 2 — CMD como Administrador
```cmd
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/glaycon/PosFormatacao/main/install.ps1 | iex"
```

### Método 3 — Executar localmente
1. Baixe o arquivo `PosFormatacao.ps1`
2. Clique com o botão direito → **Executar com PowerShell** (como Administrador)

---

## 📋 Menu de Opções

```
======================================================================
                     POS-FORMATACAO AUTOMATICA
                  Desenvolvido por Glaycon Oliveira
======================================================================

  --- 1. PROGRAMAS & DRIVERS ---
  [1]  Programas Essenciais (Chrome, 7-Zip, VLC, Foxit)
  [2]  Atualizar Drivers pelo Windows Update
  [3]  Instalar Driver Booster

  --- 2. PERFIS PREDEFINIDOS ---
  [4]  Perfil Basico / Home
  [5]  Perfil Gamer
  [6]  Perfil Desenvolvedor / Tech

  --- 3. OTIMIZACAO & MANUTENCAO ---
  [7]  Tweaks de Otimizacao & Desempenho
  [8]  Debloat (Remover Apps Nativos e Bloatware)
  [9]  Otimizacao de Rede (DNS Cloudflare + Flush DNS)
  [10] Extras (Menu Classico Win11, Extensoes/Ocultos)

  ----------------------------------------------------------------------
  [88] Visitar GitHub (https://glaycon.github.io)
  [0]  Sair
======================================================================
```

---

## 🔧 O que cada opção faz?

| Opção | Descrição | Ferramentas |
|-------|-----------|-------------|
| **[1] Essenciais** | Chrome, 7-Zip, VLC, Foxit Reader | Winget |
| **[2] Drivers WU** | Busca e instala drivers via Windows Update | PSWindowsUpdate |
| **[3] Driver Booster** | Instala o Driver Booster da IObit | Winget |
| **[4] Perfil Básico** | Chrome, 7-Zip, VLC, Spotify, WhatsApp | Winget |
| **[5] Perfil Gamer** | DirectX, VC++ Redist, Steam, Discord, Epic, MSI Afterburner | Winget |
| **[6] Perfil Dev** | VS Code, Git, Node.js LTS, Docker Desktop, PowerShell 7 | Winget |
| **[7] Tweaks** | Plano Alto Desempenho, desativa telemetria e Cortana | powercfg, Registro |
| **[8] Debloat** | Remove Xbox, Solitaire, Clima, Notícias e outros bloatwares | AppxPackage |
| **[9] Rede** | DNS Cloudflare (1.1.1.1 / 1.0.0.1) + Flush DNS | NetAdapter, ipconfig |
| **[10] Extras** | Exibe extensões, arquivos ocultos, menu clássico Win11 | Registro HKCU |

---

## ✅ Requisitos

- Windows 10 ou Windows 11
- PowerShell 5.1 ou superior (nativo no Windows)
- Executar **como Administrador**
- Conexão com a internet (para instalações via Winget)
- **Winget** instalado (já vem no Windows 10 1709+ e Windows 11)

---

## 📦 Estrutura do Repositório

```
PosFormatacao/
├── PosFormatacao.ps1   # Script principal com menu interativo
├── install.ps1         # Launcher remoto (baixa e executa o script)
└── README.md           # Esta documentação
```

---

## 🛡️ Segurança

- O script **valida** se está rodando como Administrador antes de qualquer ação
- Todas as instalações são feitas via **Winget** (gerenciador oficial da Microsoft)
- Alterações de registro são feitas em `HKCU` (usuário atual) ou `HKLM` com políticas documentadas
- O código é **100% open source** — você pode inspecionar cada linha

---

## 🤝 Contribuindo

1. Faça um Fork deste repositório
2. Crie uma branch: `git checkout -b feature/nova-funcionalidade`
3. Faça commit das suas alterações
4. Abra um Pull Request

---

## 📄 Licença

MIT License — sinta-se livre para usar, modificar e distribuir.

---

<p align="center">
  Desenvolvido com ❤️ por <a href="https://glaycon.github.io">Glaycon Oliveira</a>
</p>
