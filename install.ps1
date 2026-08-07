#
# LAUNCHER REMOTO - WINFORGE
# Autor: Glaycon Oliveira | https://glaycon.github.io
#
# Como usar no PowerShell (como Administrador):
#   irm bit.ly/winforge | iex
#
# ou URL direta:
#   irm https://raw.githubusercontent.com/glaycon/WinForge/main/install.ps1 | iex
#

# Define a politica de execucao para a sessao atual
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Forca fundo PRETO no console
try {
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.UI.RawUI.ForegroundColor = "White"
    Clear-Host
} catch { }

# URL do script principal no GitHub (branch main)
$ScriptUrl = "https://raw.githubusercontent.com/glaycon/WinForge/main/WinForge.ps1"

# Diretorio temporario de destino
$TempDir    = "$env:TEMP\WinForge"
$ScriptPath = "$TempDir\WinForge.ps1"

Write-Host ""
Write-Host "  ======================================================================" -ForegroundColor Cyan
Write-Host "                WINFORGE  -  POS-FORMATACAO AUTOMATICA" -ForegroundColor Yellow
Write-Host "                   Desenvolvido por Glaycon Oliveira" -ForegroundColor DarkYellow
Write-Host "  ======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Baixando o WinForge de: $ScriptUrl" -ForegroundColor White
Write-Host ""

# Cria o diretorio temporario se necessario
if (-not (Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
}

# Baixa o script principal
try {
    Invoke-WebRequest -Uri $ScriptUrl -OutFile $ScriptPath -UseBasicParsing -ErrorAction Stop
    Write-Host "  [OK] WinForge baixado com sucesso!" -ForegroundColor Green
}
catch {
    Write-Host "  [ERRO] Nao foi possivel baixar o WinForge." -ForegroundColor Red
    Write-Host "  Verifique sua conexao e tente novamente." -ForegroundColor DarkYellow
    Write-Host "  Detalhe: $($_.Exception.Message)" -ForegroundColor DarkGray
    Write-Host ""
    Read-Host "  Pressione ENTER para sair"
    exit 1
}

# Executa o script principal baixado
Write-Host "  Iniciando o menu principal..." -ForegroundColor Cyan
Write-Host ""
Start-Sleep -Seconds 1

# Verifica se esta sendo executado como Administrador antes de prosseguir
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "  [AVISO] O WinForge precisa de privilegios de Administrador!" -ForegroundColor Red
    Write-Host "  Solicitando permissoes de Administrador..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1

    # Re-executa o launcher como administrador
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$ScriptPath`"" -Verb RunAs
    exit 0
}

# Executa diretamente se ja for admin
& $ScriptPath
