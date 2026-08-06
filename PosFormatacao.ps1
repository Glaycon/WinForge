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
    1.0.0
#>

# ============================================================
#  CONFIGURACAO INICIAL
# ============================================================

# Garante que o script usa UTF-8 para exibir acentos corretamente
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

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
    Clear-Host
    Write-Host ""
    Write-Host "  ======================================================================" -ForegroundColor Cyan
    Write-Host "                      POS-FORMATACAO AUTOMATICA" -ForegroundColor Yellow
    Write-Host "                   Desenvolvido por Glaycon Oliveira" -ForegroundColor DarkYellow
    Write-Host "                    https://glaycon.github.io" -ForegroundColor DarkCyan
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

    $barLen   = 32
    $spinners = [char[]]@(0x2596, 0x2598, 0x259D, 0x2597)  # blocos unicode
    $alt      = @('|', '/', '-', '\')                        # fallback ASCII
    $i        = 0

    # Inicia winget em segundo plano (janela oculta)
    try {
        $proc = Start-Process winget -ArgumentList (
            "install --id $PackageId " +
            "--silent --accept-source-agreements " +
            "--accept-package-agreements --disable-interactivity"
        ) -PassThru -WindowStyle Hidden -ErrorAction Stop
    }
    catch {
        Write-Host "  [ERRO] Nao foi possivel iniciar o instalador de $PackageName" -ForegroundColor Red
        return
    }

    # Animacao enquanto o processo roda
    while (-not $proc.HasExited) {
        $spin    = $alt[$i % 4]
        # Barra "bounce": preenchimento que vai e volta
        $phase   = $i % ($barLen * 2)
        $filled  = if ($phase -lt $barLen) { $phase } else { $barLen * 2 - $phase }
        $bar     = [string]::new([char]0x2588, $filled) + [string]::new([char]0x2591, ($barLen - $filled))

        Write-Host "`r  $spin [" -NoNewline -ForegroundColor DarkGray
        Write-Host $bar -NoNewline -ForegroundColor Cyan
        Write-Host "]  $PackageName " -NoNewline -ForegroundColor Yellow
        Start-Sleep -Milliseconds 80
        $i++
    }

    # Limpa a linha e mostra resultado final
    $emptyLine = " " * ($barLen + $PackageName.Length + 20)
    Write-Host "`r$emptyLine" -NoNewline

    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq -1978335189) {
        $okBar = [string]::new([char]0x2588, $barLen)
        Write-Host "`r  [OK] [" -NoNewline -ForegroundColor DarkGray
        Write-Host $okBar -NoNewline -ForegroundColor Green
        Write-Host "]  $PackageName" -ForegroundColor Green
    }
    else {
        $errBar = [string]::new([char]0x2591, $barLen)
        Write-Host "`r  [!!] [" -NoNewline -ForegroundColor DarkGray
        Write-Host $errBar -NoNewline -ForegroundColor Red
        Write-Host "]  $PackageName (cod: $($proc.ExitCode))" -ForegroundColor Red
    }
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
    [PSCustomObject]@{ Id=1;  Category="NAVEGADORES";      Name="Google Chrome";      WingetId="Google.Chrome"                }
    [PSCustomObject]@{ Id=2;  Category="NAVEGADORES";      Name="Mozilla Firefox";    WingetId="Mozilla.Firefox"              }
    [PSCustomObject]@{ Id=3;  Category="NAVEGADORES";      Name="Brave Browser";      WingetId="Brave.Brave"                  }
    [PSCustomObject]@{ Id=4;  Category="NAVEGADORES";      Name="Opera GX";           WingetId="Opera.OperaGX"                }
    # --- PDF & LEITURA ---
    [PSCustomObject]@{ Id=5;  Category="PDF & LEITURA";    Name="Foxit PDF Reader";   WingetId="Foxit.FoxitReader"            }
    [PSCustomObject]@{ Id=6;  Category="PDF & LEITURA";    Name="Adobe Acrobat Rdr";  WingetId="Adobe.Acrobat.Reader.64-bit" }
    [PSCustomObject]@{ Id=7;  Category="PDF & LEITURA";    Name="Sumatra PDF";        WingetId="SumatraPDF.SumatraPDF"       }
    # --- COMPACTADORES ---
    [PSCustomObject]@{ Id=8;  Category="COMPACTADORES";    Name="7-Zip";              WingetId="7zip.7zip"                    }
    [PSCustomObject]@{ Id=9;  Category="COMPACTADORES";    Name="WinRAR";             WingetId="RARLab.WinRAR"                }
    [PSCustomObject]@{ Id=10; Category="COMPACTADORES";    Name="PeaZip";             WingetId="Giorgiotani.Peazip"           }
    # --- MIDIA ---
    [PSCustomObject]@{ Id=11; Category="MIDIA";            Name="VLC Media Player";   WingetId="VideoLAN.VLC"                 }
    [PSCustomObject]@{ Id=12; Category="MIDIA";            Name="MPC-HC";             WingetId="clsid2.mpc-hc"               }
    [PSCustomObject]@{ Id=13; Category="MIDIA";            Name="Spotify";            WingetId="Spotify.Spotify"              }
    # --- COMUNICACAO ---
    [PSCustomObject]@{ Id=14; Category="COMUNICACAO";      Name="Discord";            WingetId="Discord.Discord"              }
    [PSCustomObject]@{ Id=15; Category="COMUNICACAO";      Name="Telegram";           WingetId="Telegram.TelegramDesktop"     }
    [PSCustomObject]@{ Id=16; Category="COMUNICACAO";      Name="Zoom";               WingetId="Zoom.Zoom"                    }
    [PSCustomObject]@{ Id=17; Category="COMUNICACAO";      Name="WhatsApp";           WingetId="9NKSQGP7F2NH"                 }
    # --- UTILITARIOS ---
    [PSCustomObject]@{ Id=18; Category="UTILITARIOS";      Name="Notepad++";          WingetId="Notepad++.Notepad++"          }
    [PSCustomObject]@{ Id=19; Category="UTILITARIOS";      Name="Everything (busca)"; WingetId="voidtools.Everything"         }
    [PSCustomObject]@{ Id=20; Category="UTILITARIOS";      Name="PowerToys";          WingetId="Microsoft.PowerToys"          }
    [PSCustomObject]@{ Id=21; Category="UTILITARIOS";      Name="CPU-Z";              WingetId="CPUID.CPU-Z"                  }
    [PSCustomObject]@{ Id=22; Category="UTILITARIOS";      Name="TreeSize Free";      WingetId="JAMSoftware.TreeSize.Free"    }
)

# Exibe o menu de selecao de programas por categoria
function Show-ProgramSelectionMenu {
    param([System.Collections.Generic.HashSet[int]]$Selected)

    Show-Header
    Write-Host ""
    Write-Host "  PROGRAMAS ESSENCIAIS  -  Selecione o que deseja instalar" -ForegroundColor Cyan
    Write-Host "  ----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Digite o numero para (marcar/desmarcar) | [A] Todos | [D] Limpar | [I] Instalar | [0] Voltar" -ForegroundColor DarkGray
    Write-Host ""

    $currentCategory = ""
    foreach ($prog in $Script:ProgramCatalog) {
        # Cabecalho de categoria
        if ($prog.Category -ne $currentCategory) {
            $currentCategory = $prog.Category
            Write-Host "    --- $currentCategory ---" -ForegroundColor Magenta
        }

        $isSelected = $Selected.Contains($prog.Id)
        $checkbox   = if ($isSelected) { "[X]" } else { "[ ]" }
        $color      = if ($isSelected) { "Green" } else { "White" }
        $idPadded   = $prog.Id.ToString().PadLeft(2)

        Write-Host "    $checkbox " -NoNewline -ForegroundColor $color
        Write-Host "($idPadded)" -NoNewline -ForegroundColor DarkGray
        Write-Host " $($prog.Name)" -ForegroundColor $color
    }

    Write-Host ""
    Write-Host "  ----------------------------------------------------------------------" -ForegroundColor DarkGray

    $selCount = $Selected.Count
    if ($selCount -gt 0) {
        Write-Host "  $selCount programa(s) selecionado(s). Digite [I] para instalar." -ForegroundColor Yellow
    } else {
        Write-Host "  Nenhum programa selecionado." -ForegroundColor DarkGray
    }
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
