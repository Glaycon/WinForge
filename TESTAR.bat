@echo off
title POS-FORMATACAO - Launcher

:: -------------------------------------------------------
:: AUTO-ELEVACAO: relanca como Administrador se necessario
:: -------------------------------------------------------
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo  Solicitando permissoes de Administrador...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: -------------------------------------------------------
:: A partir daqui ja esta rodando como Admin
:: -------------------------------------------------------
color 0B
cls

echo.
echo  ======================================================================
echo               POS-FORMATACAO AUTOMATICA - LAUNCHER
echo               Desenvolvido por Glaycon Oliveira
echo  ======================================================================
echo.
echo  Iniciando o script PowerShell...
echo.

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0PosFormatacao.ps1"

echo.
echo  Script encerrado. Pressione qualquer tecla para fechar.
pause > nul
