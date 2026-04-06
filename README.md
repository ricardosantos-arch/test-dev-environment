# Proffer — Ambiente de Desenvolvimento Local

## Requisitos

- **Docker Desktop** (Windows/macOS) ou **Docker Engine** (Linux)
- Docker Compose V2 (incluso no Docker Desktop)

| Sistema | Instalação |
|---|---|
| Windows 10/11 | [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/) |
| macOS | [Docker Desktop](https://docs.docker.com/desktop/install/mac-install/) |
| Linux (Ubuntu/Debian) | `sudo apt install docker.io docker-compose-v2` |

## Setup Rápido

### Linux / macOS

```bash
cd scripts/dev-environment
./setup.sh
```

### Windows (PowerShell)

```powershell
cd scripts\dev-environment
.\setup.ps1
```

O script vai:
1. Verificar se Docker está instalado
2. Perguntar seu perfil de trabalho
3. Subir os containers corretos
4. Mostrar as URLs de acesso

## Perfis Disponíveis

| # | Perfil | O que sobe | Portas |
|---|---|---|---|
| 1 | Backend Developer | PostgreSQL + MongoDB + ProfferAPI + ParceirosAPI | 5000, 5001 |
| 2 | Frontend Developer | PostgreSQL + MongoDB + React/Vite (hot reload) | 3000 |
| 3 | Full Stack | PostgreSQL + MongoDB + APIs + Frontend | 3000, 5000, 5001 |
| 4-6 | Data (Eng/Ciência/Analytics) | PostgreSQL + MongoDB + JupyterLab | 8888 |
| 7 | Platform Engineering | PostgreSQL + MongoDB (só infra) | 5432, 27017 |
| 8 | CTO / Tech Lead | Tudo | 3000, 5000, 5001, 8888 |

## Ferramentas Visuais (opcional)

Durante o setup, responda `y` para incluir:

| Ferramenta | URL | Credenciais |
|---|---|---|
| pgAdmin | http://localhost:5050 | `dev@proffer.com.br` / `proffer_dev_2026` |
| Mongo Express | http://localhost:8081 | Sem autenticação |

## Dados Seed

Ao subir pela primeira vez, os bancos são populados automaticamente com:

- **3 clientes fictícios** (Farmácia Alpha, Rede Beta, Drogaria Gamma)
- **4 produtos** (Posicionamento, Otimização, Monitoramento Black, Monitoramento IA)
- **3 databases PostgreSQL** (proffer, db_central_apis, db_coleta_de_preco)
- **8 estados** de coleta SEFAZ

## Comandos Úteis

```bash
# Parar containers (mantém dados)
docker compose down

# Parar e apagar dados (reset completo)
docker compose down -v

# Ver logs de um serviço
docker compose logs -f proffer-api

# Entrar no container PostgreSQL
docker compose exec postgres psql -U proffer_dev -d proffer

# Entrar no container MongoDB
docker compose exec mongodb mongosh -u proffer_dev -p proffer_dev_2026

# Rebuild após mudança no Dockerfile
docker compose up -d --build
```

## Estrutura de Arquivos

```
scripts/dev-environment/
├── docker-compose.yml              ← Infraestrutura base (PostgreSQL + MongoDB)
├── docker-compose.backend.yml      ← APIs Flask (backend devs)
├── docker-compose.frontend.yml     ← React/Vite (frontend devs)
├── docker-compose.data.yml         ← JupyterLab (data team)
├── .env.example                    ← Template de variáveis de ambiente
├── setup.sh                        ← Setup automático (Linux/macOS)
├── setup.ps1                       ← Setup automático (Windows)
├── init-scripts/
│   ├── postgres/
│   │   └── 01-create-databases.sql ← Seed PostgreSQL (3 clientes, 3 databases)
│   └── mongodb/
│       └── 01-seed.js              ← Seed MongoDB (3 clientes, 4 produtos)
├── notebooks/                      ← Notebooks compartilhados (JupyterLab)
└── README.md                       ← Este arquivo
```
