#Requires -RunAsAdministrator
<#
.SYNOPSIS
    POS-FORMATACAO AUTOMATICA - Script de automacao pos-formatacao para Windows 10/11
.DESCRIPTION
    Script interativo para instalacao de programas, drivers, tweaks de otimizacao,
    debloat e configuracoes de rede apos a formatacao do Windows.
.AUTHOR
    Glaycon Oliveira
.LINK
    https://glaycon.github.io
.VERSION
    1.2.0
#>

$Script:WinForgeVersion = "v1.2.0"

# ============================================================
#  CONFIGURACAO INICIAL
# ============================================================

# Garante que o script usa UTF-8 para exibir acentos corretamente
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Forca o fundo do terminal para PRETO absoluto
try {
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.UI.RawUI.ForegroundColor = "White"
    [Console]::BackgroundColor = [System.ConsoleColor]::Black
    [Console]::ForegroundColor = [System.ConsoleColor]::White
    [Console]::Clear()
} catch {
    Clear-Host
}

# Ajusta o tamanho da janela do console para exibir o menu sem rolagem nem quebras
try {
    if ($Host.Name -eq "ConsoleHost") {
        $rawUI = $Host.UI.RawUI
        $rawUI.WindowTitle = "WINFORGE - Glaycon Oliveira"
        $buf = $rawUI.BufferSize
        if ($buf.Width -lt 90)   { $buf.Width = 90 }
        if ($buf.Height -lt 300) { $buf.Height = 300 }
        $rawUI.BufferSize = $buf

        $win = $rawUI.WindowSize
        if ($win.Width -lt 90)  { $win.Width = 90 }
        if ($win.Height -lt 42) { $win.Height = 42 }
        $rawUI.WindowSize = $win
    }
} catch { }

# Politica de execucao temporaria para a sessao atual
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# ============================================================
#  VALIDACAO: ADMINISTRADOR
# ============================================================
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal   = [Security.Principal.WindowsPrincipal]$currentUser
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Host ""
    Write-Host "  [ERRO] Este script precisa ser executado como Administrador!" -ForegroundColor Red
    Write-Host "  Clique com o botao direito no PowerShell e escolha 'Executar como administrador'." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Pressione ENTER para sair"
    exit 1
}

# ============================================================
#  FUNCOES AUXILIARES
# ============================================================

# Exibe o cabecalho do menu
function Show-Header {
    try {
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "White"
        [Console]::BackgroundColor = [System.ConsoleColor]::Black
        [Console]::ForegroundColor = [System.ConsoleColor]::White
        [Console]::Clear()
    } catch {
        Clear-Host
    }
    Write-Host ""
    Write-Host "  ======================================================================" -ForegroundColor Cyan
    Write-Host "                                 WINFORGE" -ForegroundColor Yellow
    Write-Host "                 Seu canivete suico para pos-formatacao!" -ForegroundColor DarkYellow
    Write-Host "                    https://glaycon.github.io" -ForegroundColor DarkCyan
    Write-Host "                              $Script:WinForgeVersion" -ForegroundColor DarkGray
    Write-Host "  ======================================================================" -ForegroundColor Cyan
}

# Exibe o menu principal
function Show-Menu {
    Show-Header
    Write-Host ""
    Write-Host "    --- 1. PROGRAMAS & DRIVERS ---" -ForegroundColor Magenta
    Write-Host "    [1]  Programas Essenciais (Chrome, 7-Zip, VLC, Foxit)" -ForegroundColor White
    Write-Host "    [2]  Atualizar Drivers pelo Windows Update" -ForegroundColor White
    Write-Host "    [3]  Instalar Driver Booster" -ForegroundColor White
    Write-Host ""
    Write-Host "    --- 2. PERFIS PREDEFINIDOS ---" -ForegroundColor Magenta
    Write-Host "    [4]  Perfil Basico / Home" -ForegroundColor White
    Write-Host "    [5]  Perfil Gamer" -ForegroundColor White
    Write-Host "    [6]  Perfil Desenvolvedor / Tech" -ForegroundColor White
    Write-Host ""
    Write-Host "    --- 3. OTIMIZACAO & MANUTENCAO ---" -ForegroundColor Magenta
    Write-Host "    [7]  Tweaks de Otimizacao & Desempenho" -ForegroundColor White
    Write-Host "    [8]  Debloat (Remover Apps Nativos e Bloatware)" -ForegroundColor White
    Write-Host "    [9]  Otimizacao de Rede (DNS Cloudflare + Flush DNS)" -ForegroundColor White
    Write-Host "    [10] Extras (Menu Classico Win11, Extensoes/Ocultos)" -ForegroundColor White
    Write-Host "    [11] Desinstalar Programas (busca + remove arquivos residuais)" -ForegroundColor White
    Write-Host "    [12] Criar Atalho na Area de Trabalho (Fixar no PC)" -ForegroundColor White
    Write-Host ""
    Write-Host "  ----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "    [88] Visitar GitHub (https://glaycon.github.io)" -ForegroundColor Green
    Write-Host "    [0]  Sair" -ForegroundColor Red
    Write-Host "  ======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

# Aguarda tecla e volta ao menu
function Pause-AndReturn {
    Write-Host ""
    Write-Host "  Pressione qualquer tecla para voltar ao menu..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Instala um pacote via Winget com tratamento de erro
# Instala um pacote via Winget (chamada simples, sem barra — usada pelos perfis)
function Install-WithWinget {
    param(
        [string]$PackageId,
        [string]$PackageName
    )
    Write-Host "  >> Instalando: $PackageName..." -ForegroundColor Yellow
    try {
        $proc = Start-Process winget -ArgumentList (
            "install --id $PackageId " +
            "--silent --accept-source-agreements " +
            "--accept-package-agreements --disable-interactivity"
        ) -PassThru -WindowStyle Hidden -ErrorAction Stop

        $proc.WaitForExit()

        if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq -1978335189) {
            Write-Host "  [OK] $PackageName instalado com sucesso." -ForegroundColor Green
        } else {
            Write-Host "  [AVISO] $PackageName - Codigo: $($proc.ExitCode)" -ForegroundColor DarkYellow
        }
    }
    catch {
        Write-Host "  [ERRO] Falha ao instalar $PackageName : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Instala com barra de progresso animada (usada em Programas Essenciais)
function Install-WithProgress {
    param(
        [string]$PackageId,
        [string]$PackageName
    )

    # --- Configuracoes visuais ---
    $barLen  = 30                                   # largura da barra em caracteres
    $filled  = [char]0x2588                         # bloco cheio  █
    $empty   = [char]0x2591                         # bloco vazio  ░
    $spinner = @([char]0x280B, [char]0x2819,        # spinner braille:
                 [char]0x2839, [char]0x2838,        #  ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏
                 [char]0x283C, [char]0x2834,
                 [char]0x2826, [char]0x2827,
                 [char]0x2807, [char]0x280F)

    # Fases com limiar de % e mensagem de status
    $phases = @(
        @{ Limit=12; Msg="Verificando pacote...  "; Speed=180 }
        @{ Limit=45; Msg="Baixando arquivo...    "; Speed=110 }
        @{ Limit=80; Msg="Instalando...          "; Speed=90  }
        @{ Limit=98; Msg="Finalizando...         "; Speed=200 }
    )

    # --- Inicia o processo winget em segundo plano ---
    try {
        $proc = Start-Process winget -ArgumentList (
            "install --id $PackageId " +
            "--silent --accept-source-agreements " +
            "--accept-package-agreements --disable-interactivity"
        ) -PassThru -WindowStyle Hidden -ErrorAction Stop
    }
    catch {
        Write-Host "  [ERRO] Nao foi possivel iniciar: $PackageName" -ForegroundColor Red
        return
    }

    # --- Cabecalho fixo do app ---
    Write-Host "  Programa : $PackageName" -ForegroundColor White
    Write-Host "  ID       : $PackageId"   -ForegroundColor DarkGray
    Write-Host ""

    $pct      = 0
    $spinIdx  = 0
    $phaseIdx = 0

    # ---- Loop de animacao ----
    while ($pct -lt 100) {

        # Se o processo terminou, pula direto para 100%
        if ($proc.HasExited -and $pct -ge 5) {
            $pct = 100
            break
        }

        # Determina a fase atual e o delay
        $currentPhase = $phases[$phaseIdx]
        if ($pct -ge $currentPhase.Limit -and $phaseIdx -lt ($phases.Count - 1)) {
            $phaseIdx++
            $currentPhase = $phases[$phaseIdx]
        }

        # Incremento aleatorio pequeno para parecer realista
        $step = Get-Random -Minimum 1 -Maximum 4
        # Desacelera perto dos limites de fase
        if ($pct -ge ($currentPhase.Limit - 5)) { $step = 1 }
        $pct = [math]::Min($pct + $step, $currentPhase.Limit)

        # Monta a barra
        $filledCount = [math]::Round(($pct / 100) * $barLen)
        $emptyCount  = $barLen - $filledCount
        $barStr      = ([string]::new($filled, $filledCount)) + ([string]::new($empty, $emptyCount))

        # Cor da barra muda conforme progresso
        $barColor = if ($pct -lt 40) { 'Cyan' } elseif ($pct -lt 75) { 'Yellow' } else { 'Green' }

        $spin = $spinner[$spinIdx % $spinner.Count]
        $pctLabel = "$pct%".PadLeft(4)

        # Linha 1: spinner + barra + %
        Write-Host "`r  $spin [" -NoNewline -ForegroundColor DarkGray
        Write-Host $barStr      -NoNewline -ForegroundColor $barColor
        Write-Host "] " -NoNewline -ForegroundColor DarkGray
        Write-Host $pctLabel    -NoNewline -ForegroundColor White
        Write-Host "  $($currentPhase.Msg)" -NoNewline -ForegroundColor DarkGray

        Start-Sleep -Milliseconds $currentPhase.Speed
        $spinIdx++
    }

    # --- Animacao final: enche a barra ate 100% suavemente se o processo ja saiu ---
    if ($pct -lt 100) { $pct = 100 }
    $fullBar = [string]::new($filled, $barLen)

    # Limpa a linha e exibe resultado final
    $clearLine = " " * 80
    Write-Host "`r$clearLine`r" -NoNewline

    $success = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq -1978335189)

    if ($success) {
        Write-Host "  " -NoNewline
        Write-Host [char]0x2714 -NoNewline -ForegroundColor Green      # checkmark ✔
        Write-Host " [" -NoNewline -ForegroundColor DarkGray
        Write-Host $fullBar -NoNewline -ForegroundColor Green
        Write-Host "] 100%  Concluido!" -ForegroundColor Green
    }
    else {
        $errBar = [string]::new($empty, $barLen)
        Write-Host "  " -NoNewline
        Write-Host [char]0x2718 -NoNewline -ForegroundColor Red         # x ✘
        Write-Host " [" -NoNewline -ForegroundColor DarkGray
        Write-Host $errBar -NoNewline -ForegroundColor Red
        Write-Host "]  Falha! (cod: $($proc.ExitCode))" -ForegroundColor Red
    }
    Write-Host ""
}

# Exibe uma secao com titulo formatado
function Show-Section {
    param([string]$Title)
    Show-Header
    Write-Host ""
    Write-Host "  >> $Title" -ForegroundColor Cyan
    Write-Host "  ----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

# ============================================================
#  CATALOGO DE PROGRAMAS ESSENCIAIS (por categoria)
# ============================================================
$Script:ProgramCatalog = @(
    # --- NAVEGADORES ---
    [PSCustomObject]@{ Id=1;  Category="NAVEGADORES";                    Name="Google Chrome";           WingetId="Google.Chrome" }
    [PSCustomObject]@{ Id=2;  Category="NAVEGADORES";                    Name="Mozilla Firefox";         WingetId="Mozilla.Firefox" }
    [PSCustomObject]@{ Id=3;  Category="NAVEGADORES";                    Name="Brave Browser";           WingetId="Brave.Brave" }
    [PSCustomObject]@{ Id=4;  Category="NAVEGADORES";                    Name="Opera GX";                WingetId="Opera.OperaGX" }

    # --- DOCUMENTOS & PDF ---
    [PSCustomObject]@{ Id=5;  Category="DOCUMENTOS & PDF";               Name="Foxit PDF Reader";        WingetId="Foxit.FoxitReader" }
    [PSCustomObject]@{ Id=6;  Category="DOCUMENTOS & PDF";               Name="Adobe Acrobat Reader";   WingetId="Adobe.Acrobat.Reader.64-bit" }
    [PSCustomObject]@{ Id=7;  Category="DOCUMENTOS & PDF";               Name="Sumatra PDF (Leve)";      WingetId="SumatraPDF.SumatraPDF" }
    [PSCustomObject]@{ Id=8;  Category="DOCUMENTOS & PDF";               Name="LibreOffice";             WingetId="TheDocumentFoundation.LibreOffice" }

    # --- COMPACTADORES & TEXTO ---
    [PSCustomObject]@{ Id=9;  Category="COMPACTADORES & TEXTO";          Name="7-Zip";                   WingetId="7zip.7zip" }
    [PSCustomObject]@{ Id=10; Category="COMPACTADORES & TEXTO";          Name="WinRAR";                  WingetId="RARLab.WinRAR" }
    [PSCustomObject]@{ Id=11; Category="COMPACTADORES & TEXTO";          Name="PeaZip";                  WingetId="Giorgiotani.Peazip" }
    [PSCustomObject]@{ Id=12; Category="COMPACTADORES & TEXTO";          Name="Notepad++";               WingetId="Notepad++.Notepad++" }

    # --- MIDIA & AUDIO ---
    [PSCustomObject]@{ Id=13; Category="MIDIA & AUDIO";                  Name="VLC Media Player";        WingetId="VideoLAN.VLC" }
    [PSCustomObject]@{ Id=14; Category="MIDIA & AUDIO";                  Name="MPC-HC (K-Lite)";         WingetId="clsid2.mpc-hc" }
    [PSCustomObject]@{ Id=15; Category="MIDIA & AUDIO";                  Name="Spotify";                 WingetId="Spotify.Spotify" }
    [PSCustomObject]@{ Id=16; Category="MIDIA & AUDIO";                  Name="OBS Studio (Gravacao)";   WingetId="OBSProject.OBSStudio" }

    # --- COMUNICACAO & SUPORTE REMOTO ---
    [PSCustomObject]@{ Id=17; Category="COMUNICACAO & SUPORTE REMOTO";   Name="WhatsApp";                WingetId="9NKSQGP7F2NH" }
    [PSCustomObject]@{ Id=18; Category="COMUNICACAO & SUPORTE REMOTO";   Name="Telegram";                WingetId="Telegram.TelegramDesktop" }
    [PSCustomObject]@{ Id=19; Category="COMUNICACAO & SUPORTE REMOTO";   Name="Discord";                 WingetId="Discord.Discord" }
    [PSCustomObject]@{ Id=20; Category="COMUNICACAO & SUPORTE REMOTO";   Name="Zoom / Teams";            WingetId="Zoom.Zoom" }
    [PSCustomObject]@{ Id=21; Category="COMUNICACAO & SUPORTE REMOTO";   Name="AnyDesk";                 WingetId="AnyDeskSoftwareGmbH.AnyDesk" }
    [PSCustomObject]@{ Id=22; Category="COMUNICACAO & SUPORTE REMOTO";   Name="TeamViewer";              WingetId="TeamViewer.TeamViewer" }

    # --- JOGOS & LAUNCHERS ---
    [PSCustomObject]@{ Id=23; Category="JOGOS & LAUNCHERS";              Name="Steam";                   WingetId="Valve.Steam" }
    [PSCustomObject]@{ Id=24; Category="JOGOS & LAUNCHERS";              Name="Epic Games Launcher";     WingetId="EpicGames.EpicGamesLauncher" }
    [PSCustomObject]@{ Id=25; Category="JOGOS & LAUNCHERS";              Name="Xbox App (PC)";           WingetId="Microsoft.GamingApp" }
    [PSCustomObject]@{ Id=26; Category="JOGOS & LAUNCHERS";              Name="EA App";                  WingetId="ElectronicArts.EADesktop" }

    # --- DIAGNOSTICO & MANUTENCAO ---
    [PSCustomObject]@{ Id=27; Category="DIAGNOSTICO & MANUTENCAO";       Name="Everything (Busca)";      WingetId="voidtools.Everything" }
    [PSCustomObject]@{ Id=28; Category="DIAGNOSTICO & MANUTENCAO";       Name="PowerToys";               WingetId="Microsoft.PowerToys" }
    [PSCustomObject]@{ Id=29; Category="DIAGNOSTICO & MANUTENCAO";       Name="CPU-Z";                   WingetId="CPUID.CPU-Z" }
    [PSCustomObject]@{ Id=30; Category="DIAGNOSTICO & MANUTENCAO";       Name="GPU-Z";                   WingetId="TechPowerUp.GPU-Z" }
    [PSCustomObject]@{ Id=31; Category="DIAGNOSTICO & MANUTENCAO";       Name="CrystalDiskInfo (SSD)";   WingetId="CrystalData.CrystalDiskInfo" }
    [PSCustomObject]@{ Id=32; Category="DIAGNOSTICO & MANUTENCAO";       Name="TreeSize Free (Espaco)";  WingetId="JAMSoftware.TreeSize.Free" }
    [PSCustomObject]@{ Id=33; Category="DIAGNOSTICO & MANUTENCAO";       Name="Revo Uninstaller";        WingetId="RevoUninstaller.RevoUninstaller" }
    [PSCustomObject]@{ Id=34; Category="DIAGNOSTICO & MANUTENCAO";       Name="HWMonitor (Temps)";       WingetId="CPUID.HWMonitor" }
)

# Exibe o menu de selecao de programas agrupados por categoria em 2 colunas
function Show-ProgramSelectionMenu {
    param([System.Collections.Generic.HashSet[int]]$Selected)

    Show-Header
    Write-Host ""
    Write-Host "  PROGRAMAS ESSENCIAIS  -  Selecione os programas desejados para instalacao" -ForegroundColor Cyan
    Write-Host "  =======================================================================================" -ForegroundColor DarkGray

    # Agrupa por categoria e exibe cada grupo em 2 colunas perfeitamente alinhadas
    $grouped = $Script:ProgramCatalog | Group-Object Category
    foreach ($group in $grouped) {
        $catName = " $($(([string]$group.Name).Trim())) "
        $padLen  = [math]::Max(0, 83 - $catName.Length - 2)
        $line    = [string]::new([char]0x2500, $padLen)  # linha horizontal ─

        Write-Host "  " -NoNewline
        Write-Host $catName -NoNewline -ForegroundColor Magenta
        Write-Host $line -ForegroundColor DarkGray

        $items = $group.Group
        for ($i = 0; $i -lt $items.Count; $i += 2) {
            $left  = $items[$i]
            $right = if (($i + 1) -lt $items.Count) { $items[$i+1] } else { $null }

            # --- COLUNA ESQUERDA ---
            $isSelL = $Selected.Contains($left.Id)
            $boxL   = if ($isSelL) { "[X]" } else { "[ ]" }
            $colorL = if ($isSelL) { "Green" } else { "White" }
            $idL    = $left.Id.ToString().PadLeft(2)
            $nameL  = $left.Name.PadRight(28)

            Write-Host "    $boxL " -NoNewline -ForegroundColor $colorL
            Write-Host "($idL)"    -NoNewline -ForegroundColor DarkGray
            Write-Host " $nameL"   -NoNewline -ForegroundColor $colorL

            # --- COLUNA DIREITA ---
            if ($right) {
                $isSelR = $Selected.Contains($right.Id)
                $boxR   = if ($isSelR) { "[X]" } else { "[ ]" }
                $colorR = if ($isSelR) { "Green" } else { "White" }
                $idR    = $right.Id.ToString().PadLeft(2)
                $nameR  = $right.Name.PadRight(28)

                Write-Host "    $boxR " -NoNewline -ForegroundColor $colorR
                Write-Host "($idR)"    -NoNewline -ForegroundColor DarkGray
                Write-Host " $nameR"   -ForegroundColor $colorR
            } else {
                Write-Host ""
            }
        }
    }

    Write-Host "  =======================================================================================" -ForegroundColor DarkGray

    $selCount = $Selected.Count
    if ($selCount -gt 0) {
        Write-Host "  >> $selCount programa(s) selecionado(s)." -ForegroundColor Yellow
    } else {
        Write-Host "  >> Nenhum programa selecionado." -ForegroundColor DarkGray
    }
    Write-Host ""

    # ---- Barra de navegacao colorida (1 linha compacta perfeitamente alinhada) ----
    Write-Host "  " -NoNewline
    Write-Host " NUM " -NoNewline -BackgroundColor DarkCyan    -ForegroundColor Black
    Write-Host " Marcar/Desmarcar  " -NoNewline -ForegroundColor Cyan
    Write-Host " A " -NoNewline -BackgroundColor DarkYellow  -ForegroundColor Black
    Write-Host " Todos  " -NoNewline -ForegroundColor Yellow
    Write-Host " D " -NoNewline -BackgroundColor DarkGreen   -ForegroundColor Black
    Write-Host " Limpar  " -NoNewline -ForegroundColor Green
    Write-Host " I " -NoNewline -BackgroundColor DarkMagenta -ForegroundColor White
    Write-Host " Instalar Selecionados  " -NoNewline -ForegroundColor Magenta
    Write-Host " 0 " -NoNewline -BackgroundColor DarkRed     -ForegroundColor White
    Write-Host " Voltar" -ForegroundColor Red
    Write-Host ""
}

# ============================================================
#  OPCAO [1] - PROGRAMAS ESSENCIAIS (menu interativo)
# ============================================================
function Install-EssentialPrograms {
    $selected = [System.Collections.Generic.HashSet[int]]::new()

    while ($true) {
        Show-ProgramSelectionMenu -Selected $selected
        $input = (Read-Host "  Opcao").Trim().ToUpper()

        switch ($input) {
            "0" { return }   # Voltar ao menu principal

            "A" {
                # Seleciona todos
                foreach ($p in $Script:ProgramCatalog) { $null = $selected.Add($p.Id) }
            }

            "D" {
                # Desmarca todos
                $selected.Clear()
            }

            "I" {
                # Instalar selecionados
                if ($selected.Count -eq 0) {
                    Write-Host "  [!] Nenhum programa selecionado!" -ForegroundColor Red
                    Start-Sleep -Seconds 2
                    continue
                }

                # Tela de instalacao
                Show-Header
                Write-Host ""
                Write-Host "  INSTALANDO PROGRAMAS SELECIONADOS" -ForegroundColor Cyan
                Write-Host "  ----------------------------------------------------------------------" -ForegroundColor DarkGray
                Write-Host ""

                $toInstall = $Script:ProgramCatalog | Where-Object { $selected.Contains($_.Id) }
                $total     = $toInstall.Count
                $current   = 0

                foreach ($prog in $toInstall) {
                    $current++
                    Write-Host "  [$current/$total] " -NoNewline -ForegroundColor DarkGray
                    Install-WithProgress -PackageId $prog.WingetId -PackageName $prog.Name
                }

                Write-Host ""
                Write-Host "  ============================================================" -ForegroundColor Cyan
                Write-Host "  [CONCLUIDO] $total programa(s) processado(s)!" -ForegroundColor Green
                Write-Host "  ============================================================" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "  Pressione qualquer tecla para voltar a selecao..." -ForegroundColor DarkGray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

                # Limpa selecao e volta para a tela de selecao
                $selected.Clear()
            }

            default {
                # Tenta interpretar como numero para toggle
                $num = 0
                if ([int]::TryParse($input, [ref]$num)) {
                    $exists = $Script:ProgramCatalog | Where-Object { $_.Id -eq $num }
                    if ($exists) {
                        if ($selected.Contains($num)) {
                            $null = $selected.Remove($num)
                        } else {
                            $null = $selected.Add($num)
                        }
                    } else {
                        Write-Host "  [!] Numero invalido: $num" -ForegroundColor Red
                        Start-Sleep -Seconds 1
                    }
                } else {
                    Write-Host "  [!] Comando nao reconhecido." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            }
        }
    }
}

# ============================================================
#  OPCAO [2] - ATUALIZAR DRIVERS VIA WINDOWS UPDATE
# ============================================================
function Update-DriversWindowsUpdate {
    Show-Section "ATUALIZAR DRIVERS VIA WINDOWS UPDATE"

    Write-Host "  Verificando modulo PSWindowsUpdate..." -ForegroundColor White

    # Instala o modulo se nao existir
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "  Modulo PSWindowsUpdate nao encontrado. Instalando..." -ForegroundColor Yellow
        try {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue | Out-Null
            Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
            Write-Host "  [OK] Modulo PSWindowsUpdate instalado." -ForegroundColor Green
        }
        catch {
            Write-Host "  [ERRO] Nao foi possivel instalar PSWindowsUpdate: $($_.Exception.Message)" -ForegroundColor Red
            Pause-AndReturn
            return
        }
    } else {
        Write-Host "  [OK] Modulo PSWindowsUpdate ja esta disponivel." -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "  Buscando e instalando drivers via Windows Update..." -ForegroundColor White
    Write-Host "  (Isso pode levar alguns minutos...)" -ForegroundColor DarkGray
    Write-Host ""

    try {
        Import-Module PSWindowsUpdate -Force
        Get-WindowsUpdate -Category "Drivers" -Install -AutoReboot:$false -AcceptAll -Verbose
        Write-Host ""
        Write-Host "  [CONCLUIDO] Atualizacao de drivers finalizada!" -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERRO] Falha ao atualizar drivers: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ============================================================
#  OPCAO [3] - DRIVER BOOSTER
# ============================================================
function Install-DriverBooster {
    Show-Section "INSTALAR DRIVER BOOSTER"

    Install-WithWinget -PackageId "IObit.DriverBooster" -PackageName "Driver Booster (IObit)"

    Write-Host ""
    Write-Host "  [CONCLUIDO] Driver Booster instalado!" -ForegroundColor Green
}

# ============================================================
#  OPCAO [4] - PERFIL BASICO / HOME
# ============================================================
function Install-ProfileBasic {
    Show-Section "PERFIL BASICO / HOME"

    Write-Host "  Instalando pacote para uso domestico..." -ForegroundColor White
    Write-Host ""

    Install-WithWinget -PackageId "Google.Chrome"       -PackageName "Google Chrome"
    Install-WithWinget -PackageId "7zip.7zip"           -PackageName "7-Zip"
    Install-WithWinget -PackageId "VideoLAN.VLC"        -PackageName "VLC Media Player"
    Install-WithWinget -PackageId "Spotify.Spotify"     -PackageName "Spotify"
    Install-WithWinget -PackageId "9NKSQGP7F2NH"        -PackageName "WhatsApp (Microsoft Store)"

    Write-Host ""
    Write-Host "  [CONCLUIDO] Perfil Basico/Home instalado!" -ForegroundColor Green
}

# ============================================================
#  OPCAO [5] - PERFIL GAMER
# ============================================================
function Install-ProfileGamer {
    Show-Section "PERFIL GAMER"

    Write-Host "  Instalando pacote Gamer..." -ForegroundColor White
    Write-Host ""

    # Redistribuiveis essenciais para jogos
    Install-WithWinget -PackageId "Microsoft.DirectX"                         -PackageName "DirectX Runtime"
    Install-WithWinget -PackageId "Microsoft.VCRedist.2015+.x64"              -PackageName "VC++ Redist 2015-2022 x64"
    Install-WithWinget -PackageId "Microsoft.VCRedist.2015+.x86"              -PackageName "VC++ Redist 2015-2022 x86"
    Install-WithWinget -PackageId "Valve.Steam"                               -PackageName "Steam"
    Install-WithWinget -PackageId "Discord.Discord"                           -PackageName "Discord"
    Install-WithWinget -PackageId "EpicGames.EpicGamesLauncher"               -PackageName "Epic Games Launcher"
    Install-WithWinget -PackageId "MSI.Afterburner"                           -PackageName "MSI Afterburner"

    Write-Host ""
    Write-Host "  [CONCLUIDO] Perfil Gamer instalado!" -ForegroundColor Green
}

# ============================================================
#  OPCAO [6] - PERFIL DESENVOLVEDOR / TECH
# ============================================================
function Install-ProfileDev {
    Show-Section "PERFIL DESENVOLVEDOR / TECH"

    Write-Host "  Instalando pacote Desenvolvedor..." -ForegroundColor White
    Write-Host ""

    Install-WithWinget -PackageId "Microsoft.VisualStudioCode"  -PackageName "Visual Studio Code"
    Install-WithWinget -PackageId "Git.Git"                     -PackageName "Git"
    Install-WithWinget -PackageId "OpenJS.NodeJS.LTS"           -PackageName "Node.js LTS"
    Install-WithWinget -PackageId "Docker.DockerDesktop"        -PackageName "Docker Desktop"
    Install-WithWinget -PackageId "Microsoft.PowerShell"        -PackageName "PowerShell 7"

    Write-Host ""
    Write-Host "  [CONCLUIDO] Perfil Desenvolvedor instalado!" -ForegroundColor Green
}

# ============================================================
#  OPCAO [7] - TWEAKS DE OTIMIZACAO E DESEMPENHO
# ============================================================
function Apply-PerformanceTweaks {
    Show-Section "TWEAKS DE OTIMIZACAO E DESEMPENHO"

    # --- Plano de Energia: Alto Desempenho ---
    Write-Host "  [1/4] Ativando plano de energia Alto Desempenho..." -ForegroundColor White
    try {
        powercfg -setactive SCHEME_MIN
        Write-Host "  [OK] Plano Alto Desempenho ativado." -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERRO] Falha ao alterar plano de energia: $($_.Exception.Message)" -ForegroundColor Red
    }

    # --- Desativar Telemetria ---
    Write-Host ""
    Write-Host "  [2/4] Desativando telemetria do Windows..." -ForegroundColor White
    try {
        # Desativa envio de dados de diagnostico
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
            -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction Stop

        # Para e desabilita o servico DiagTrack (Connected User Experiences and Telemetry)
        Stop-Service  -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
        Set-Service   -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue

        # Para e desabilita o dmwappushsvc (WAP Push Message Routing Service)
        Stop-Service  -Name "dmwappushsvc" -Force -ErrorAction SilentlyContinue
        Set-Service   -Name "dmwappushsvc" -StartupType Disabled -ErrorAction SilentlyContinue

        Write-Host "  [OK] Telemetria desativada." -ForegroundColor Green
    }
    catch {
        Write-Host "  [AVISO] Alguns itens de telemetria nao puderam ser desativados: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }

    # --- Desativar Cortana ---
    Write-Host ""
    Write-Host "  [3/4] Desativando Cortana..." -ForegroundColor White
    try {
        $cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        if (-not (Test-Path $cortanaPath)) { New-Item -Path $cortanaPath -Force | Out-Null }
        Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0 -Type DWord -Force
        Write-Host "  [OK] Cortana desativada via politica." -ForegroundColor Green
    }
    catch {
        Write-Host "  [AVISO] Nao foi possivel desativar Cortana: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }

    # --- Ajustes Visuais para Desempenho ---
    Write-Host ""
    Write-Host "  [4/4] Ajustando efeitos visuais para melhor desempenho..." -ForegroundColor White
    try {
        # Configura para melhor desempenho (reduz animacoes)
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
            -Name "VisualFXSetting" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Host "  [OK] Efeitos visuais ajustados." -ForegroundColor Green
    }
    catch {
        Write-Host "  [AVISO] Nao foi possivel ajustar efeitos visuais." -ForegroundColor DarkYellow
    }

    Write-Host ""
    Write-Host "  [CONCLUIDO] Tweaks de otimizacao aplicados!" -ForegroundColor Green
}

# ============================================================
#  OPCAO [8] - DEBLOAT
# ============================================================
function Remove-Bloatware {
    Show-Section "DEBLOAT - REMOCAO DE BLOATWARE"

    Write-Host "  Lista de apps para remover:" -ForegroundColor White
    Write-Host ""

    # Lista de bloatware a remover (AppxPackage wildcard names)
    $bloatwareList = @(
        # Cortana
        "*Microsoft.549981C3F5F10*"         # Cortana
        # Xbox
        "*Microsoft.XboxApp*"
        "*Microsoft.XboxGameCallableUI*"
        "*Microsoft.XboxGameOverlay*"
        "*Microsoft.XboxGamingOverlay*"
        "*Microsoft.XboxIdentityProvider*"
        "*Microsoft.XboxSpeechToTextOverlay*"
        # Jogos
        "*Microsoft.MicrosoftSolitaireCollection*"
        "*Microsoft.MicrosoftMahjong*"
        "*Microsoft.MicrosoftJigsaw*"
        "*Microsoft.ZuneMusic*"             # Groove Music
        "*Microsoft.ZuneVideo*"             # Movies & TV
        # Apps nativos desnecessarios
        "*Microsoft.BingWeather*"           # Clima
        "*Microsoft.BingNews*"              # Noticias (MSN News)
        "*Microsoft.BingFinance*"
        "*Microsoft.BingSports*"
        "*Microsoft.GetHelp*"
        "*Microsoft.Getstarted*"
        "*Microsoft.MicrosoftOfficeHub*"    # Office Hub
        "*Microsoft.Office.OneNote*"        # OneNote (Store)
        "*Microsoft.OneConnect*"
        "*Microsoft.People*"
        "*Microsoft.Print3D*"
        "*Microsoft.SkypeApp*"
        "*Microsoft.Todos*"                 # Microsoft To Do (opcional)
        "*Microsoft.WindowsFeedbackHub*"
        "*Microsoft.WindowsMaps*"
        "*Microsoft.WindowsSoundRecorder*"
        "*Microsoft.YourPhone*"             # Link to Windows
        "*Microsoft.549981C3F5F10*"
        # Extras
        "*king.com.CandyCrush*"
        "*king.com.BubbleWitch*"
        "*Facebook.Facebook*"
        "*Clipchamp.Clipchamp*"             # Editor de video
        "*MicrosoftTeams*"                  # Teams (consumer, nao o corporativo)
        "*Microsoft.Messaging*"
        "*Microsoft.MixedReality.Portal*"
    )

    $removedCount = 0
    $skippedCount = 0

    foreach ($app in $bloatwareList) {
        # Remove para todos os usuarios
        $packages = Get-AppxPackage -AllUsers -Name $app -ErrorAction SilentlyContinue
        if ($packages) {
            foreach ($pkg in $packages) {
                Write-Host "  Removendo: $($pkg.Name)" -ForegroundColor Yellow
                try {
                    Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
                    $removedCount++
                }
                catch {
                    Write-Host "  [AVISO] Nao foi possivel remover $($pkg.Name)" -ForegroundColor DarkYellow
                    $skippedCount++
                }
            }
        }

        # Remove do provisionamento (novos usuarios)
        $provPkg = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
                   Where-Object { $_.DisplayName -like $app }
        if ($provPkg) {
            try {
                Remove-AppxProvisionedPackage -Online -PackageName $provPkg.PackageName -ErrorAction Stop | Out-Null
            }
            catch {
                # Silencia erros de provisionamento ja removidos
            }
        }
    }

    Write-Host ""
    Write-Host "  Resultado:" -ForegroundColor White
    Write-Host "  - Removidos : $removedCount pacotes" -ForegroundColor Green
    Write-Host "  - Ignorados : $skippedCount pacotes (ja removidos ou protegidos)" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  [CONCLUIDO] Debloat finalizado!" -ForegroundColor Green
}

# ============================================================
#  OPCAO [9] - OTIMIZACAO DE REDE
# ============================================================
function Optimize-Network {
    Show-Section "OTIMIZACAO DE REDE - DNS CLOUDFLARE"

    Write-Host "  [1/2] Configurando DNS Cloudflare (1.1.1.1 / 1.0.0.1)..." -ForegroundColor White
    Write-Host ""

    try {
        # Pega todas as interfaces de rede ativas (Ethernet e Wi-Fi)
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

        if ($adapters.Count -eq 0) {
            Write-Host "  [AVISO] Nenhuma interface de rede ativa encontrada." -ForegroundColor DarkYellow
        }
        else {
            foreach ($adapter in $adapters) {
                Write-Host "  Configurando interface: $($adapter.Name) ($($adapter.InterfaceDescription))" -ForegroundColor White

                # Remove DNS atual e define Cloudflare
                Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex `
                    -ServerAddresses ("1.1.1.1", "1.0.0.1") -ErrorAction Stop

                Write-Host "  [OK] DNS configurado para $($adapter.Name)" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "  [ERRO] Nao foi possivel configurar o DNS: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Flush DNS
    Write-Host ""
    Write-Host "  [2/2] Limpando cache DNS (ipconfig /flushdns)..." -ForegroundColor White
    try {
        ipconfig /flushdns | Out-Null
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        Write-Host "  [OK] Cache DNS limpo com sucesso." -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERRO] Falha ao limpar cache DNS: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "  [CONCLUIDO] Rede otimizada com DNS Cloudflare!" -ForegroundColor Green
}

# ============================================================
#  OPCAO [10] - EXTRAS
# ============================================================
function Apply-Extras {
    Show-Section "EXTRAS - AJUSTES DE REGISTRO"

    # --- Mostrar Extensoes de Arquivos ---
    Write-Host "  [1/3] Habilitando exibicao de extensoes de arquivos..." -ForegroundColor White
    try {
        Set-ItemProperty `
            -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
            -Name "HideFileExt" -Value 0 -Type DWord -Force
        Write-Host "  [OK] Extensoes de arquivos serao exibidas." -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERRO] $($_.Exception.Message)" -ForegroundColor Red
    }

    # --- Mostrar Arquivos Ocultos ---
    Write-Host ""
    Write-Host "  [2/3] Habilitando exibicao de arquivos ocultos..." -ForegroundColor White
    try {
        Set-ItemProperty `
            -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
            -Name "Hidden" -Value 1 -Type DWord -Force
        Write-Host "  [OK] Arquivos ocultos serao exibidos." -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERRO] $($_.Exception.Message)" -ForegroundColor Red
    }

    # --- Menu Classico do Windows 11 ---
    Write-Host ""
    Write-Host "  [3/3] Restaurando menu classico (botao direito) no Windows 11..." -ForegroundColor White
    $win11Version = [System.Environment]::OSVersion.Version
    if ($win11Version.Build -ge 22000) {
        try {
            $regPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            Set-ItemProperty -Path $regPath -Name "(Default)" -Value "" -Type String -Force
            Write-Host "  [OK] Menu classico restaurado. Reinicie o Explorer para aplicar." -ForegroundColor Green

            # Reinicia o Explorer automaticamente
            Write-Host "  Reiniciando o Explorer..." -ForegroundColor DarkGray
            Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            Start-Process explorer
            Write-Host "  [OK] Explorer reiniciado." -ForegroundColor Green
        }
        catch {
            Write-Host "  [ERRO] $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  [INFO] Windows 10 detectado. Menu classico nao se aplica." -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "  [CONCLUIDO] Extras aplicados!" -ForegroundColor Green
}

# ============================================================
#  OPCAO [11] - DESINSTALAR PROGRAMAS
# ============================================================
function Uninstall-AnyProgram {

    # Coleta todos os programas instalados via registro (muito mais rapido que winget list)
    function Get-InstalledApps {
        # --- Cache de Prefetch: monta hashtable nome_exe -> LastWriteTime ---
        $prefetchCache = @{}
        $pfDir = 'C:\Windows\Prefetch'
        if (Test-Path $pfDir) {
            Get-ChildItem $pfDir -Filter '*.pf' -ErrorAction SilentlyContinue | ForEach-Object {
                $exeKey = ($_.Name -split '-')[0].ToUpper()
                if (-not $prefetchCache.ContainsKey($exeKey) -or
                    $_.LastWriteTime -gt $prefetchCache[$exeKey]) {
                    $prefetchCache[$exeKey] = $_.LastWriteTime
                }
            }
        }

        $paths = @(
            'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
            'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
        )

        $apps = foreach ($path in $paths) {
            Get-ItemProperty $path -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -and $_.DisplayName.Trim() -ne '' } |
                ForEach-Object {
                    $reg = $_

                    # --- Data de instalacao (registro: formato YYYYMMDD) ---
                    $instLabel = '--/--/----'
                    $instRaw   = [datetime]::MinValue
                    if ($reg.InstallDate -match '^\d{8}$') {
                        $d = $reg.InstallDate
                        $instLabel = "$($d.Substring(6,2))/$($d.Substring(4,2))/$($d.Substring(0,4))"
                        try {
                            $instRaw = [datetime]::ParseExact($reg.InstallDate, 'yyyyMMdd', $null)
                        } catch { }
                    }

                    # --- Ultima vez usado (Prefetch) ---
                    $lastLabel = '--/--/----'
                    $lastRaw   = [datetime]::MinValue
                    $exeGuess  = ''

                    if ($reg.DisplayIcon) {
                        $iconPath = ($reg.DisplayIcon -split ',')[0].Trim('"')
                        $exeGuess = [System.IO.Path]::GetFileNameWithoutExtension($iconPath).ToUpper()
                    }
                    if (-not $exeGuess -and $reg.InstallLocation) {
                        $exe = Get-ChildItem $reg.InstallLocation -Filter '*.exe' `
                               -ErrorAction SilentlyContinue | Select-Object -First 1
                        if ($exe) { $exeGuess = $exe.BaseName.ToUpper() }
                    }

                    if ($exeGuess -and $prefetchCache.ContainsKey($exeGuess)) {
                        $dt = $prefetchCache[$exeGuess]
                        $lastLabel = $dt.ToString('dd/MM/yyyy')
                        $lastRaw   = $dt
                    }

                    # --- Tamanho Estimado (KB) ---
                    $sizeKB = 0
                    if ($reg.EstimatedSize) {
                        try { $sizeKB = [long]$reg.EstimatedSize } catch { }
                    }

                    # Formata tamanho para exibicao
                    $sizeLabel = if ($sizeKB -ge 1048576) {
                        "{0:N1} GB" -f ($sizeKB / 1048576)
                    } elseif ($sizeKB -ge 1024) {
                        "{0:N0} MB" -f ($sizeKB / 1024)
                    } elseif ($sizeKB -gt 0) {
                        "{0:N0} KB" -f $sizeKB
                    } else {
                        '--'
                    }

                    [PSCustomObject]@{
                        DisplayName          = $reg.DisplayName
                        DisplayVersion       = $reg.DisplayVersion
                        Publisher            = $reg.Publisher
                        InstallDate          = $instLabel
                        InstallDateRaw       = $instRaw
                        LastUsed             = $lastLabel
                        LastUsedRaw          = $lastRaw
                        EstimatedSizeKB      = $sizeKB
                        SizeLabel            = $sizeLabel
                        InstallLocation      = $reg.InstallLocation
                        UninstallString      = $reg.UninstallString
                        QuietUninstallString = $reg.QuietUninstallString
                    }
                }
        }

        # Remove duplicatas pelo nome
        $apps | Sort-Object DisplayName -Unique
    }

    # Desenha a tabela de resultados com ordenacao dinamica
    function Show-AppList {
        param(
            [array]$Apps,
            [string]$Filter,
            [string]$SortMode
        )
        Show-Header
        Write-Host ""
        Write-Host "  DESINSTALAR PROGRAMAS" -ForegroundColor Red
        Write-Host "  =======================================================================================" -ForegroundColor DarkGray
        Write-Host "  Filtro : " -NoNewline -ForegroundColor DarkGray
        if ($Filter) {
            Write-Host "'$Filter'" -NoNewline -ForegroundColor Yellow
        } else {
            Write-Host "(todos)" -NoNewline -ForegroundColor DarkGray
        }

        $sortTitle = switch ($SortMode) {
            'DATA'    { 'Data (Mais recentes)' }
            'TAMANHO' { 'Tamanho (Maiores)' }
            'USO'     { 'Ultimo Uso (Mais recentes)' }
            default   { 'Nome (A-Z)' }
        }
        Write-Host "  |  Ordenacao: " -NoNewline -ForegroundColor DarkGray
        Write-Host "[$sortTitle]" -ForegroundColor Cyan
        Write-Host ""

        $idx = 1
        foreach ($app in $Apps) {
            $numLabel  = "[$idx]".PadRight(5)
            $nameShort = $app.DisplayName
            if ($nameShort.Length -gt 28) { $nameShort = $nameShort.Substring(0,25) + '...' }
            $nameCol   = $nameShort.PadRight(28)
            $ver       = if ($app.DisplayVersion) { $app.DisplayVersion.PadRight(10) } else { ''.PadRight(10) }

            $sizeCol   = ("Tam: " + $app.SizeLabel).PadRight(12)
            $instColor = if ($app.InstallDate -ne '--/--/----') { 'Yellow' } else { 'DarkGray' }
            $useColor  = if ($app.LastUsed    -ne '--/--/----') { 'Cyan'   } else { 'DarkGray' }

            Write-Host "  $numLabel " -NoNewline -ForegroundColor Cyan
            Write-Host $nameCol     -NoNewline -ForegroundColor White
            Write-Host $ver         -NoNewline -ForegroundColor DarkGray
            $sizeColor = if ($app.SizeLabel -ne '--') { 'Yellow' } else { 'DarkGray' }
            Write-Host $sizeCol     -NoNewline -ForegroundColor $sizeColor
            Write-Host ' Inst:' -NoNewline -ForegroundColor DarkGray
            Write-Host $app.InstallDate -NoNewline -ForegroundColor $instColor
            Write-Host '  Uso:' -NoNewline -ForegroundColor DarkGray
            Write-Host $app.LastUsed   -ForegroundColor $useColor
            $idx++
        }

        Write-Host ""
        Write-Host "  =======================================================================================" -ForegroundColor DarkGray
        Write-Host "  Total: $($Apps.Count) programa(s) encontrado(s)" -ForegroundColor White
        Write-Host ""

        # ---- Barra de navegacao colorida (com opcao de ordenacao) ----
        Write-Host "  " -NoNewline
        Write-Host " NUM " -NoNewline -BackgroundColor DarkCyan    -ForegroundColor Black
        Write-Host " Selecionar  " -NoNewline -ForegroundColor Cyan
        Write-Host " F " -NoNewline -BackgroundColor DarkYellow  -ForegroundColor Black
        Write-Host " Filtrar  " -NoNewline -ForegroundColor Yellow
        Write-Host " O " -NoNewline -BackgroundColor DarkMagenta -ForegroundColor White
        Write-Host " Ordenar  " -NoNewline -ForegroundColor Magenta
        Write-Host " L " -NoNewline -BackgroundColor DarkGreen   -ForegroundColor Black
        Write-Host " Limpar  " -NoNewline -ForegroundColor Green
        Write-Host " 0 " -NoNewline -BackgroundColor DarkRed     -ForegroundColor White
        Write-Host " Voltar ao Menu" -ForegroundColor Red
        Write-Host ""
    }

    # Remove pastas residuais do app nos locais mais comuns
    function Remove-Leftovers {
        param([string]$AppName)

        # Tira caracteres invalidos do nome para usar como nome de pasta
        $safeName = ($AppName -replace '[^\w\s]', '').Trim()
        $words    = ($safeName -split '\s+') | Where-Object { $_.Length -gt 3 }

        $baseDirs = @(
            $env:APPDATA
            $env:LOCALAPPDATA
            $env:ProgramFiles
            ${env:ProgramFiles(x86)}
            $env:ProgramData
            (Join-Path $env:LOCALAPPDATA 'Programs')
        ) | Where-Object { $_ -and (Test-Path $_) }

        $removed = 0
        foreach ($base in $baseDirs) {
            # Tenta o nome completo e as primeiras palavras
            foreach ($name in (@($safeName) + $words)) {
                $target = Join-Path $base $name
                if (Test-Path $target) {
                    try {
                        Remove-Item $target -Recurse -Force -ErrorAction Stop
                        Write-Host "  [LIMPO] $target" -ForegroundColor DarkYellow
                        $removed++
                    } catch {
                        Write-Host "  [SKIP]  $target (em uso ou sem permissao)" -ForegroundColor DarkGray
                    }
                }
            }
        }
        return $removed
    }

    # ---- Estado do loop ----
    $filter   = ''
    $sortMode = 'NOME' # NOME | DATA | TAMANHO | USO
    $allApps  = @()

    Write-Host ""
    Write-Host "  Carregando lista de programas instalados..." -ForegroundColor DarkGray
    $allApps = @(Get-InstalledApps)

    while ($true) {
        # Aplica filtro
        $filtered = if ($filter) {
            @($allApps | Where-Object { $_.DisplayName -match [regex]::Escape($filter) })
        } else {
            $allApps
        }

        # Aplica ordenacao
        $sorted = switch ($sortMode) {
            'DATA'    { @($filtered | Sort-Object { $_.InstallDateRaw } -Descending) }
            'TAMANHO' { @($filtered | Sort-Object { $_.EstimatedSizeKB } -Descending) }
            'USO'     { @($filtered | Sort-Object { $_.LastUsedRaw } -Descending) }
            default   { @($filtered | Sort-Object DisplayName) }
        }

        Show-AppList -Apps $sorted -Filter $filter -SortMode $sortMode

        $input = (Read-Host '  Opcao').Trim().ToUpper()

        switch ($input) {
            '0' { return }

            'F' {
                Write-Host '  Digite parte do nome para filtrar: ' -NoNewline -ForegroundColor Yellow
                $filter = (Read-Host '').Trim()
            }

            'O' {
                Write-Host ""
                Write-Host "  Ordenar por: [1] Nome (A-Z) | [2] Data de Instalacao | [3] Tamanho | [4] Ultimo Uso" -ForegroundColor Magenta
                $sOpt = (Read-Host '  Escolha o criterio (1-4)').Trim()
                switch ($sOpt) {
                    '1' { $sortMode = 'NOME' }
                    '2' { $sortMode = 'DATA' }
                    '3' { $sortMode = 'TAMANHO' }
                    '4' { $sortMode = 'USO' }
                    default { Write-Host "  Opcao invalida." -ForegroundColor Red; Start-Sleep -Seconds 1 }
                }
            }

            'L' { $filter = ''; $sortMode = 'NOME' }

            default {
                $num = 0
                if ([int]::TryParse($input, [ref]$num) -and $num -ge 1 -and $num -le $filtered.Count) {
                    $chosen = $filtered[$num - 1]

                    # --- Tela de confirmacao ---
                    Show-Header
                    Write-Host ""
                    Write-Host "  CONFIRMAR DESINSTALACAO" -ForegroundColor Red
                    Write-Host "  ----------------------------------------------------------------------" -ForegroundColor DarkGray
                    Write-Host ""
                    Write-Host "  Programa : " -NoNewline -ForegroundColor White
                    Write-Host $chosen.DisplayName -ForegroundColor Yellow
                    Write-Host "  Versao   : " -NoNewline -ForegroundColor White
                    $verLabel = if ($chosen.DisplayVersion) { $chosen.DisplayVersion } else { 'desconhecida' }
                    $pubLabel = if ($chosen.Publisher)      { $chosen.Publisher }      else { 'desconhecido'  }
                    Write-Host $verLabel -ForegroundColor DarkGray
                    Write-Host "  Editor   : " -NoNewline -ForegroundColor White
                    Write-Host $pubLabel -ForegroundColor DarkGray
                    # --- Local de instalacao ---
                    $locLabel = if ($chosen.InstallLocation -and (Test-Path $chosen.InstallLocation)) {
                        $chosen.InstallLocation
                    } elseif ($chosen.InstallLocation) {
                        $chosen.InstallLocation
                    } else {
                        'nao identificado'
                    }
                    Write-Host "  Local    : " -NoNewline -ForegroundColor White
                    Write-Host $locLabel -ForegroundColor DarkGray

                    Write-Host "  Instalado: " -NoNewline -ForegroundColor White
                    if ($chosen.InstallDate -ne '--/--/----') {
                        Write-Host $chosen.InstallDate -ForegroundColor Yellow
                    } else {
                        Write-Host 'data nao disponivel' -ForegroundColor DarkGray
                    }
                    Write-Host "  Ult. uso : " -NoNewline -ForegroundColor White
                    if ($chosen.LastUsed -ne '--/--/----') {
                        Write-Host $chosen.LastUsed -ForegroundColor Cyan
                    } else {
                        Write-Host 'sem registro de uso' -ForegroundColor DarkGray
                    }

                    # ---- Opcoes de remocao ----
                    Write-Host ""
                    Write-Host "  " -NoNewline
                    Write-Host " 1 " -NoNewline -BackgroundColor DarkYellow -ForegroundColor Black
                    Write-Host "  Remover somente o programa" -ForegroundColor Yellow
                    Write-Host "  " -NoNewline
                    Write-Host " 2 " -NoNewline -BackgroundColor DarkRed    -ForegroundColor White
                    Write-Host "  Remover programa + limpar todos os arquivos residuais" -ForegroundColor Red
                    Write-Host "  " -NoNewline
                    Write-Host " 0 " -NoNewline -BackgroundColor DarkGray   -ForegroundColor White
                    Write-Host "  Cancelar" -ForegroundColor DarkGray
                    Write-Host ""

                    $confirmOpt = (Read-Host '  Escolha').Trim()

                    if ($confirmOpt -eq '0' -or $confirmOpt -eq '') {
                        Write-Host "  Operacao cancelada." -ForegroundColor DarkGray
                        Start-Sleep -Seconds 1
                        continue
                    }
                    if ($confirmOpt -ne '1' -and $confirmOpt -ne '2') {
                        Write-Host "  [!] Opcao invalida." -ForegroundColor Red
                        Start-Sleep -Seconds 1
                        continue
                    }
                    $doCleanup = ($confirmOpt -eq '2')

                    # --- Desinstalacao ---
                    Show-Header
                    Write-Host ""
                    Write-Host "  DESINSTALANDO: $($chosen.DisplayName)" -ForegroundColor Red
                    Write-Host "  ----------------------------------------------------------------------" -ForegroundColor DarkGray
                    Write-Host ""

                    $uninstallOk = $false

                    # Tentativa 1: winget uninstall (mais limpo)
                    Write-Host "  [1/3] Tentando desinstalar via winget..." -ForegroundColor White
                    $wingetProc = Start-Process winget -ArgumentList (
                        "uninstall --name `"$($chosen.DisplayName)`" " +
                        "--silent --accept-source-agreements --purge --force"
                    ) -PassThru -WindowStyle Hidden -ErrorAction SilentlyContinue

                    if ($wingetProc) {
                        # Barra de progresso durante desinstalacao
                        $bar30 = [string]::new([char]0x2591, 30)
                        $filled = [char]0x2588
                        $empty  = [char]0x2591
                        $sp = @('|','/','-','\')
                        $si = 0; $pct = 0
                        while (-not $wingetProc.HasExited -and $pct -lt 98) {
                            $pct = [math]::Min($pct + (Get-Random -Min 1 -Max 3), 98)
                            $fc  = [math]::Round($pct / 100 * 30)
                            $barStr = [string]::new($filled,$fc) + [string]::new($empty,(30-$fc))
                            Write-Host "`r  $($sp[$si%4]) [" -NoNewline -ForegroundColor DarkGray
                            Write-Host $barStr -NoNewline -ForegroundColor Red
                            Write-Host "] $($pct.ToString().PadLeft(3))%  Desinstalando..." -NoNewline -ForegroundColor White
                            Start-Sleep -Milliseconds 120
                            $si++
                        }
                        $wingetProc.WaitForExit()
                        $fullBar = [string]::new($filled, 30)
                        Write-Host "`r  $([char]0x2714) [" -NoNewline -ForegroundColor DarkGray
                        Write-Host $fullBar -NoNewline -ForegroundColor Green
                        Write-Host "] 100%  Desinstalado!          " -ForegroundColor Green
                        $uninstallOk = ($wingetProc.ExitCode -eq 0)
                    }

                    # Tentativa 2: UninstallString nativo (fallback)
                    if (-not $uninstallOk) {
                        Write-Host ""
                        Write-Host "  [2/3] Tentando via desinstalador nativo..." -ForegroundColor White
                        $uStr = if ($chosen.QuietUninstallString) { $chosen.QuietUninstallString } else { $chosen.UninstallString }
                        if ($uStr) {
                            try {
                                if ($uStr -match '^msiexec') {
                                    $msiArgs = ($uStr -replace 'msiexec.exe','').Trim() + ' /quiet /norestart'
                                    Start-Process msiexec -ArgumentList $msiArgs -Wait -WindowStyle Hidden
                                } else {
                                    Start-Process cmd -ArgumentList "/c `"$uStr`"" -Wait -WindowStyle Hidden
                                }
                                Write-Host "  [OK] Desinstalador nativo executado." -ForegroundColor Green
                                $uninstallOk = $true
                            } catch {
                                Write-Host "  [AVISO] Nao foi possivel executar o desinstalador nativo." -ForegroundColor DarkYellow
                            }
                        } else {
                            Write-Host "  [AVISO] Nenhum desinstalador encontrado no registro." -ForegroundColor DarkYellow
                        }
                    }

                    # Passo 3: Limpeza de arquivos residuais (apenas se opcao 2 for escolhida)
                    if ($doCleanup) {
                        Write-Host ""
                        Write-Host "  [3/3] Limpando arquivos residuais..." -ForegroundColor White
                        $removed = Remove-Leftovers -AppName $chosen.DisplayName
                        if ($removed -gt 0) {
                            Write-Host "  [OK] $removed pasta(s) residual(is) removida(s)." -ForegroundColor Green
                        } else {
                            Write-Host "  [OK] Nenhum arquivo residual encontrado." -ForegroundColor DarkGray
                        }
                    } else {
                        Write-Host ""
                        Write-Host "  [INFO] Limpeza de arquivos residuais ignorada a pedido." -ForegroundColor DarkGray
                    }

                    Write-Host ""
                    Write-Host "  ============================================================" -ForegroundColor Cyan
                    Write-Host "  [CONCLUIDO] $($chosen.DisplayName) removido!" -ForegroundColor Green
                    Write-Host "  ============================================================" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host "  Pressione qualquer tecla para voltar a lista..." -ForegroundColor DarkGray
                    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

                    # Recarrega a lista (app foi removido)
                    Write-Host "  Atualizando lista..." -ForegroundColor DarkGray
                    $allApps = @(Get-InstalledApps)

                } else {
                    Write-Host "  [!] Numero invalido." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            }
        }
    }
}

# ============================================================
#  OPCAO [12] - CRIAR ATALHO NA AREA DE TRABALHO
# ============================================================
function Create-DesktopShortcut {
    Show-Section "CRIAR ATALHO NA AREA DE TRABALHO"

    $targetDir = "$env:ProgramData\WinForge"
    if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }

    # Copia o script atual para o diretorio permanente
    $scriptSource = $MyInvocation.MyCommand.Path
    if ($scriptSource -and (Test-Path $scriptSource)) {
        Copy-Item -Path $scriptSource -Destination "$targetDir\WinForge.ps1" -Force
        Write-Host "  [OK] Script copiado para $targetDir\WinForge.ps1" -ForegroundColor Green
    } else {
        # Se executado via iex/irm, baixa a versao mais recente do GitHub
        Write-Host "  Baixando versao permanente do GitHub..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/glaycon/WinForge/main/WinForge.ps1" `
                -OutFile "$targetDir\WinForge.ps1" -UseBasicParsing -ErrorAction Stop
            Write-Host "  [OK] Script baixado para $targetDir\WinForge.ps1" -ForegroundColor Green
        } catch {
            Write-Host "  [AVISO] Nao foi possivel baixar o script permanente: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
    }

    # Cria o atalho no Desktop
    $desktopPath  = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = "$desktopPath\WinForge.lnk"

    try {
        $wshShell = New-Object -ComObject WScript.Shell
        $shortcut = $wshShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath       = "powershell.exe"
        $shortcut.Arguments        = "-ExecutionPolicy Bypass -NoProfile -File `"$targetDir\WinForge.ps1`""
        $shortcut.WorkingDirectory = $targetDir
        $shortcut.Description      = "WinForge - Pos-Formatacao Automatica para Windows 10/11"
        $shortcut.IconLocation     = "$env:SystemRoot\System32\shell32.dll,15"
        $shortcut.Save()

        # Define flag para rodar como Administrador (Byte 21 = 0x20)
        $bytes = [System.IO.File]::ReadAllBytes($shortcutPath)
        $bytes[21] = $bytes[21] -bor 0x20
        [System.IO.File]::WriteAllBytes($shortcutPath, $bytes)

        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor Cyan
        Write-Host "  [CONCLUIDO] Atalho 'WinForge' criado na Area de Trabalho!" -ForegroundColor Green
        Write-Host "  [PATH] $shortcutPath" -ForegroundColor DarkGray
        Write-Host "  ============================================================" -ForegroundColor Cyan
    }
    catch {
        Write-Host "  [ERRO] Nao foi possivel criar o atalho: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ============================================================
#  OPCAO [88] - ABRIR GITHUB
# ============================================================
function Open-GitHub {
    Show-Section "ABRINDO GITHUB"
    Write-Host "  Abrindo https://glaycon.github.io no navegador padrao..." -ForegroundColor White
    try {
        Start-Process "https://glaycon.github.io"
        Write-Host "  [OK] Pagina aberta com sucesso!" -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERRO] Nao foi possivel abrir o navegador: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ============================================================
#  LOOP PRINCIPAL DO MENU
# ============================================================
function Start-MainMenu {
    while ($true) {
        Show-Menu
        $choice = Read-Host "  Digite o numero da opcao desejada"

        switch ($choice.Trim()) {
            "1"  { Install-EssentialPrograms }
            "2"  { Update-DriversWindowsUpdate; Pause-AndReturn }
            "3"  { Install-DriverBooster;        Pause-AndReturn }
            "4"  { Install-ProfileBasic;         Pause-AndReturn }
            "5"  { Install-ProfileGamer;         Pause-AndReturn }
            "6"  { Install-ProfileDev;           Pause-AndReturn }
            "7"  { Apply-PerformanceTweaks;      Pause-AndReturn }
            "8"  { Remove-Bloatware;             Pause-AndReturn }
            "9"  { Optimize-Network;             Pause-AndReturn }
            "10" { Apply-Extras;                 Pause-AndReturn }
            "11" { Uninstall-AnyProgram }
            "12" { Create-DesktopShortcut;       Pause-AndReturn }
            "88" { Open-GitHub;                  Pause-AndReturn }
            "0"  {
                Show-Header
                Write-Host ""
                Write-Host "  Ate logo! Script encerrado por $env:USERNAME." -ForegroundColor Cyan
                Write-Host "  Desenvolvido por Glaycon Oliveira | https://glaycon.github.io" -ForegroundColor DarkYellow
                Write-Host ""
                exit 0
            }
            default {
                Write-Host ""
                Write-Host "  [!] Opcao invalida. Digite um numero do menu acima." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    }
}

# ============================================================
#  PONTO DE ENTRADA
# ============================================================
Start-MainMenu
