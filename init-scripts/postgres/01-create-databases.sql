-- =============================================================================
-- Proffer — PostgreSQL Seed (Development)
-- =============================================================================
-- Cria os databases e tabelas mínimas para desenvolvimento local.
-- Espelha a estrutura de produção (Cloud SQL 172.16.1.30).
-- =============================================================================

-- Database principal (ProfferAPI)
-- 'proffer' já é criado via POSTGRES_DB no docker-compose

-- Database de APIs centrais (ProfferParceirosAPI)
CREATE DATABASE db_central_apis OWNER proffer_dev;

-- Database de coleta de preços (Managers SEFAZ)
CREATE DATABASE db_coleta_de_preco OWNER proffer_dev;

-- Conectar ao banco principal e criar schema básico
\c proffer

-- Tabela de clientes (referência para todos os produtos)
CREATE TABLE IF NOT EXISTS clientes (
    codrede INTEGER PRIMARY KEY,
    nome_fantasia VARCHAR(255) NOT NULL,
    cnpj VARCHAR(20),
    codcidade INTEGER,
    plano INTEGER DEFAULT 4,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3 clientes fictícios de referência
INSERT INTO clientes (codrede, nome_fantasia, cnpj, codcidade, plano) VALUES
    (9001, 'Farmácia Alpha', '11.111.111/0001-01', 3550308, 5),   -- Plano Black
    (9002, 'Rede Beta', '22.222.222/0001-02', 2927408, 4),         -- Plano Green
    (9003, 'Drogaria Gamma', '33.333.333/0001-03', 5300108, 8)     -- Monitora IA
ON CONFLICT (codrede) DO NOTHING;

-- Conectar ao banco de APIs centrais
\c db_central_apis

CREATE TABLE IF NOT EXISTS parceiros (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    codrede INTEGER,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO parceiros (nome, email, codrede) VALUES
    ('Parceiro Alpha', 'alpha@mock.proffer.dev', 9001),
    ('Parceiro Beta', 'beta@mock.proffer.dev', 9002),
    ('Parceiro Gamma', 'gamma@mock.proffer.dev', 9003)
ON CONFLICT DO NOTHING;

-- Conectar ao banco de coleta
\c db_coleta_de_preco

CREATE TABLE IF NOT EXISTS estados (
    id SERIAL PRIMARY KEY,
    sigla CHAR(2) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

INSERT INTO estados (sigla, nome) VALUES
    ('AL', 'Alagoas'), ('AM', 'Amazonas'), ('BA', 'Bahia'),
    ('PR', 'Paraná'), ('PE', 'Pernambuco'), ('RN', 'Rio Grande do Norte'),
    ('RS', 'Rio Grande do Sul'), ('PB', 'Paraíba')
ON CONFLICT DO NOTHING;
