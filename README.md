# 🛠️ WinForge

> Script PowerShell interativo para pós-formatação e automação de computadores com Windows 10 e 11.

**Desenvolvido por [Glaycon Oliveira](https://glaycon.github.io)**

---

## 🚀 Como Usar (Link Curto!)

### Método 1 — PowerShell (Recomendado)
Abra o **PowerShell como Administrador** e execute:

```powershell
irm is.gd/wforge | iex
```

### Método 2 — CMD como Administrador
```cmd
powershell -ExecutionPolicy Bypass -Command "irm is.gd/wforge | iex"
```

### Método 3 — URL Direta do GitHub
```powershell
irm https://raw.githubusercontent.com/glaycon/WinForge/main/install.ps1 | iex
```

---

## 📋 Menu Principal do WinForge

```
======================================================================
                               WINFORGE
                 Desenvolvido por Glaycon Oliveira
======================================================================

  --- 1. PROGRAMAS & DRIVERS ---
  [1]  Programas Essenciais (Chrome, Firefox, VLC, 7-Zip, Office...)
  [2]  Atualizar Drivers pelo Windows Update
  [3]  Instalar Driver Booster

  --- 2. PERFIS PREDEFINIDOS ---
  [4]  Perfil Básico / Home
  [5]  Perfil Gamer
  [6]  Perfil Desenvolvedor / Tech

  --- 3. OTIMIZAÇÃO & MANUTENÇÃO ---
  [7]  Tweaks de Otimização & Desempenho
  [8]  Debloat (Remover Apps Nativos e Bloatware)
  [9]  Otimização de Rede (DNS Cloudflare + Flush DNS)
  [10] Extras (Menu Clássico Win11, Extensões/Ocultos)
  [11] Desinstalar Programas (busca + remove arquivos residuais)
  [12] Criar Atalho na Área de Trabalho (Fixar no PC)

  ----------------------------------------------------------------------
  [88] Visitar GitHub (https://glaycon.github.io)
  [0]  Sair
======================================================================
```

---

## ⚡ Recursos em Destaque

- **Catálogo de 34 Programas Essenciais:** Seleção interativa em 2 colunas organizadas por 7 categorias, com barra de progresso linear 0–100% animada.
- **Desinstalador Inteligente:** Busca instantânea por nome, exibição da data de instalação e última vez usado (via Prefetch), com desinstalação silenciosa + limpeza completa de pastas residuais em `AppData`, `Program Files`, etc.
- **Atalho Permanente:** Opção `[12]` que instala um ícone do **WinForge** diretamente na sua Área de Trabalho com permissões de Administrador ativadas automaticamente.
- **Tweaks & Debloat:** Otimização de energia, remoção de bloatwares nativos (Xbox, Solitaire, Clima, Notícias), DNS Cloudflare (1.1.1.1) e restauração do menu clássico no Windows 11.

---

## 📦 Estrutura do Repositório

```
WinForge/
├── WinForge.ps1        # Script principal com menu interativo
├── install.ps1         # Launcher remoto (irm is.gd/winforge | iex)
├── TESTAR.bat          # Launcher local batch com auto-elevação UAC
└── README.md           # Documentação oficial
```

---

## 📄 Licença

MIT License — sinta-se livre para usar, modificar e distribuir.

---

<p align="center">
  Desenvolvido com ❤️ por <a href="https://glaycon.github.io">Glaycon Oliveira</a>
</p>
