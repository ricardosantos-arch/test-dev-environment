# =============================================================================
# Proffer — Setup do Ambiente de Desenvolvimento Local (Windows)
# =============================================================================
# Compatível com: Windows 10/11 com Docker Desktop
#
# Uso: .\setup.ps1  (executar no PowerShell)
# =============================================================================

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "  ║        Proffer — Ambiente de Desenvolvimento        ║" -ForegroundColor Blue
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# --- Verificar Docker ---
try {
    $dockerVersion = docker --version
    Write-Host "  Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "  Docker nao encontrado." -ForegroundColor Red
    Write-Host "  Instale em: https://docs.docker.com/desktop/install/windows-install/"
    exit 1
}

try {
    docker compose version | Out-Null
} catch {
    Write-Host "  Docker Compose V2 nao encontrado. Atualize o Docker Desktop." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "  Selecione seu perfil de trabalho:" -ForegroundColor Yellow
Write-Host ""
Write-Host "    1) Backend Developer     - APIs Flask + PostgreSQL + MongoDB"
Write-Host "    2) Frontend Developer    - React/Vite + APIs"
Write-Host "    3) Full Stack            - Backend + Frontend"
Write-Host "    4) Engenheiro de Dados   - JupyterLab + Beam + PostgreSQL + MongoDB"
Write-Host "    5) Cientista de Dados    - JupyterLab + BigQuery + MongoDB"
Write-Host "    6) Analytics / P&D       - JupyterLab (somente leitura)"
Write-Host "    7) Platform Engineering  - Infra (so bancos, sem aplicacao)"
Write-Host "    8) CTO / Tech Lead       - Full Stack + JupyterLab"
Write-Host ""
$profile = Read-Host "  Perfil [1-8]"

# --- Configurar env files ---
if (-not (Test-Path ".env.backend")) {
    Copy-Item ".env.example" ".env.backend"
    Write-Host "  Criado .env.backend" -ForegroundColor Yellow
}
if (-not (Test-Path ".env.frontend")) {
    Copy-Item ".env.example" ".env.frontend"
    Write-Host "  Criado .env.frontend" -ForegroundColor Yellow
}

# --- Montar compose command ---
$base = "docker compose -f docker-compose.yml"

switch ($profile) {
    "1" {
        $compose = "$base -f docker-compose.backend.yml"
        $profileName = "Backend Developer"
        $urls = "  API Principal: http://localhost:5000`n  API Parceiros: http://localhost:5001"
    }
    "2" {
        $compose = "$base -f docker-compose.frontend.yml"
        $profileName = "Frontend Developer"
        $urls = "  Frontend: http://localhost:3000"
    }
    "3" {
        $compose = "$base -f docker-compose.backend.yml -f docker-compose.frontend.yml"
        $profileName = "Full Stack"
        $urls = "  Frontend: http://localhost:3000`n  API Principal: http://localhost:5000`n  API Parceiros: http://localhost:5001"
    }
    { $_ -in "4","5","6" } {
        $compose = "$base -f docker-compose.data.yml"
        $profileName = "Data / Analytics"
        $urls = "  JupyterLab: http://localhost:8888 (token: proffer)"
    }
    "7" {
        $compose = "$base"
        $profileName = "Platform Engineering"
        $urls = "  PostgreSQL: localhost:5432`n  MongoDB: localhost:27017"
    }
    "8" {
        $compose = "$base -f docker-compose.backend.yml -f docker-compose.frontend.yml -f docker-compose.data.yml"
        $profileName = "CTO / Tech Lead"
        $urls = "  Frontend: http://localhost:3000`n  API Principal: http://localhost:5000`n  API Parceiros: http://localhost:5001`n  JupyterLab: http://localhost:8888 (token: proffer)"
    }
    default {
        Write-Host "  Perfil invalido." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "  Perfil: $profileName" -ForegroundColor Blue

# --- Ferramentas visuais ---
$tools = Read-Host "  Incluir ferramentas visuais (pgAdmin + Mongo Express)? [y/N]"
if ($tools -eq "y" -or $tools -eq "Y") {
    $compose = "$compose --profile tools"
}

# --- Subir containers ---
Write-Host ""
Write-Host "  Subindo containers..." -ForegroundColor Yellow
Invoke-Expression "$compose up -d --build"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║              Ambiente pronto!                        ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Perfil: $profileName" -ForegroundColor Blue
Write-Host $urls
Write-Host ""
Write-Host "  PostgreSQL: localhost:5432 (proffer_dev / proffer_dev_2026)"
Write-Host "  MongoDB:    localhost:27017 (proffer_dev / proffer_dev_2026)"

if ($tools -eq "y" -or $tools -eq "Y") {
    Write-Host ""
    Write-Host "  pgAdmin:       http://localhost:5050 (dev@proffer.com.br / proffer_dev_2026)"
    Write-Host "  Mongo Express: http://localhost:8081"
}

Write-Host ""
Write-Host "  Para parar:  $compose down" -ForegroundColor Yellow
Write-Host "  Para resetar: $compose down -v (apaga dados)" -ForegroundColor Yellow
Write-Host ""
