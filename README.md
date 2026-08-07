# 🛠️ WinForge

<p align="center">
  <b>Script Automático Pós-Formatação para Windows 10 & 11</b><br>
  <i>Interface interativa no terminal, catálogo com 34 programas, desinstalador inteligente e otimizações de sistema.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows 10/11">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white" alt="PowerShell 5.1+">
  <img src="https://img.shields.io/badge/Winget-Oficial-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="Winget">
  <img src="https://img.shields.io/badge/Licen%C3%A7a-MIT-green?style=for-the-badge" alt="MIT License">
</p>

---

## ⚡ Execução Rápida (Copie e Cole)

Abra o **PowerShell como Administrador** e cole o comando abaixo:

```powershell
irm bit.ly/winforge | iex
```

> 💡 **Dica:** No Prompt de Comando (CMD) como Administrador, você também pode executar:
> ```cmd
> powershell -ExecutionPolicy Bypass -Command "irm bit.ly/winforge | iex"
> ```

---

## 🖥️ Preview da Interface

```
======================================================================
                               WINFORGE
                 Desenvolvido por Glaycon Oliveira
                    https://glaycon.github.io
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

## 🔥 Principais Recursos

- 📦 **34 Programas Essenciais:** Catálogo em 2 colunas organizadas por 7 categorias (Navegadores, PDF, Mídia, Comunicação, Jogos, Utilitários, etc.) com instalação via `winget` oficial.
- 📊 **Progresso Linear Realista (0–100%):** Barra de carregamento com porcentagem contínua, status por fases e spinner animado.
- 🗑️ **Desinstalador Inteligente:** Lista contínua de todos os apps instalados, busca por nome, exibição de data de instalação, última vez usado (via Prefetch) e limpeza profunda de arquivos residuais (`AppData`, `Program Files`, etc.).
- 🚀 **Perfis Prontos:** Instalação em lote com 1 clique para perfil **Básico**, **Gamer** ou **Desenvolvedor**.
- 🛠️ **Debloat & Tweaks:** Remoção de aplicativos nativos inúteis (bloatware), otimização de energia, DNS Cloudflare (1.1.1.1), limpeza de cache e ativação do menu clássico no Windows 11.
- 📌 **Atalho Permanente:** Opção `[12]` para instalar o **WinForge** na Área de Trabalho com permissão de Administrador ativada automaticamente.

---

## 📂 Estrutura do Repositório

| Arquivo | Descrição |
| :--- | :--- |
| [`WinForge.ps1`](WinForge.ps1) | Script principal com todo o menu interativo e funções |
| [`install.ps1`](install.ps1) | Launcher remoto responsável pelo comando em 1 linha |
| [`TESTAR.bat`](TESTAR.bat) | Arquivo batch para testes locais com auto-elevação UAC |
| [`README.md`](README.md) | Documentação oficial do projeto |

---

## 👨‍💻 Autor & Créditos

Desenvolvido com dedicação por **[Glaycon Oliveira](https://glaycon.github.io)**.

- 🌐 Website: [glaycon.github.io](https://glaycon.github.io)
- 📜 Licença: [MIT License](LICENSE)
