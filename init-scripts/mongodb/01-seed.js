// =============================================================================
// Proffer — MongoDB Seed (Development)
// =============================================================================
// Popula collections mínimas para desenvolvimento local.
// Espelha a estrutura de produção (MongoDB Atlas).
// =============================================================================

db = db.getSiblingDB('Proffer');

// Collection de clientes (database-cliente)
db.createCollection('database-cliente');
db['database-cliente'].insertMany([
    {
        codrede: 9001,
        nome_fantasia: "Farmácia Alpha",
        cnpj: "11.111.111/0001-01",
        codcidade: 3550308,
        cidade: "São Paulo",
        uf: "SP",
        plano: 5,
        produtos: [2, 3, 4, 5],
        ativo: true,
        created_at: new Date()
    },
    {
        codrede: 9002,
        nome_fantasia: "Rede Beta",
        cnpj: "22.222.222/0001-02",
        codcidade: 2927408,
        cidade: "Salvador",
        uf: "BA",
        plano: 4,
        produtos: [2, 3, 5],
        ativo: true,
        created_at: new Date()
    },
    {
        codrede: 9003,
        nome_fantasia: "Drogaria Gamma",
        cnpj: "33.333.333/0001-03",
        codcidade: 5300108,
        cidade: "Brasília",
        uf: "DF",
        plano: 8,
        produtos: [5],
        ativo: true,
        created_at: new Date()
    }
]);

// Collection de produtos
db.createCollection('produtos');
db.produtos.insertMany([
    { key: 2, name: "Proffer Posicionamento", planos: [4, 5] },
    { key: 3, name: "Proffer Otimização", planos: [4, 5] },
    { key: 4, name: "Proffer Monitoramento Black", planos: [5] },
    { key: 5, name: "Monitoramento IA", planos: [4, 8, 9, 10] }
]);

print("Seed MongoDB concluído — 3 clientes + 4 produtos");
