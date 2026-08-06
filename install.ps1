#
# LAUNCHER REMOTO - POS-FORMATACAO AUTOMATICA
# Autor: Glaycon Oliveira | https://glaycon.github.io
#
# Como usar (CMD ou PowerShell como Administrador):
#
#   PowerShell:
#   irm https://raw.githubusercontent.com/glaycon/PosFormatacao/main/install.ps1 | iex
#
#   CMD (via PowerShell inline):
#   powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/glaycon/PosFormatacao/main/install.ps1 | iex"
#

# Define a politica de execucao para a sessao atual
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# URL do script principal no GitHub (branch main)
$ScriptUrl = "https://raw.githubusercontent.com/glaycon/PosFormatacao/main/PosFormatacao.ps1"

# Diretorio temporario de destino
$TempDir    = "$env:TEMP\PosFormatacao"
$ScriptPath = "$TempDir\PosFormatacao.ps1"

Write-Host ""
Write-Host "  ======================================================================" -ForegroundColor Cyan
Write-Host "             POS-FORMATACAO AUTOMATICA  -  Iniciando..." -ForegroundColor Yellow
Write-Host "              Desenvolvido por Glaycon Oliveira" -ForegroundColor DarkYellow
Write-Host "  ======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Baixando o script de: $ScriptUrl" -ForegroundColor White
Write-Host ""

# Cria o diretorio temporario se necessario
if (-not (Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
}

# Baixa o script principal
try {
    Invoke-WebRequest -Uri $ScriptUrl -OutFile $ScriptPath -UseBasicParsing -ErrorAction Stop
    Write-Host "  [OK] Script baixado com sucesso!" -ForegroundColor Green
}
catch {
    Write-Host "  [ERRO] Nao foi possivel baixar o script." -ForegroundColor Red
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
    Write-Host "  [AVISO] Este script precisa de privilegios de Administrador!" -ForegroundColor Red
    Write-Host "  Tentando reiniciar como Administrador..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2

    # Re-executa o launcher como administrador
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$ScriptPath`"" -Verb RunAs
    exit 0
}

# Executa diretamente se ja for admin
& $ScriptPath
