# RefiPDV — Comanda Eletrônica + KDS

Sistema de comanda eletrônica e painel de cozinha (KDS) que roda no **GitHub Pages** (telas) + **Supabase** (banco de dados e tempo real). Sem servidor próprio e com plano gratuito suficiente para um restaurante.

---

## Como funciona

- **Telas (front-end):** arquivos HTML/JS hospedados no GitHub Pages. Abrem no navegador de qualquer tablet ou celular, sem instalar nada.
- **Banco + tempo real (back-end):** Supabase (PostgreSQL). O garçom lança o pedido, a cozinha recebe na hora.
- **Cardápio:** a base fica no arquivo `cardapio.yaml` (versionado aqui). A disponibilidade do dia (esgotar/repor) é controlada pelo gerente dentro do sistema.

### Papéis

| Papel | Pode | Não pode |
|---|---|---|
| **Mesa** (cliente) | só pedir, da própria mesa | ver outras mesas, mexer no cardápio |
| **Garçom** | lançar pedido em qualquer mesa, ver o salão | esgotar item |
| **Cozinha (KDS)** | ver pedidos e mudar status (preparo/pronto) | criar/editar pedido |
| **Gerente** | tudo + editar cardápio, preço e disponibilidade | — |

As regras são aplicadas no banco (RLS), não só na tela — o cliente não consegue burlar.

---

## Estrutura do repositório

```
refipdv/
├── index.html            → o aplicativo (telas: cliente, garçom, cozinha, gerente)
├── cardapio.yaml         → cardápio base (edite aqui para mudar itens/preços)
├── js/
│   └── config.example.js → modelo de configuração (copie para config.js)
├── sql/
│   ├── 01_schema.sql     → cria as tabelas
│   ├── 02_rls.sql        → permissões por papel
│   └── 03_seed.sql       → dados iniciais (mesas + cardápio)
└── .gitignore
```

---

## Configuração (passo a passo)

### 1. Crie o projeto no Supabase
Acesse [supabase.com](https://supabase.com) → **New project**. Anote a senha do banco.

### 2. Rode os SQL
No painel do Supabase, vá em **SQL Editor** e rode, **nesta ordem**:
1. `sql/01_schema.sql`
2. `sql/02_rls.sql`
3. `sql/03_seed.sql`

### 3. Crie os usuários e ligue aos papéis
Em **Authentication → Users → Add user**, crie um usuário (e-mail + senha) para cada acesso, por exemplo:

| E-mail | Papel |
|---|---|
| gerente@refipdv.local | gerente |
| joao@refipdv.local | garçom |
| cozinha@refipdv.local | cozinha |
| mesa05@refipdv.local | mesa (mesa 05) |

Depois, em **SQL Editor**, copie o UUID de cada usuário (coluna `id` da tabela de usuários) e rode os inserts comentados no fim do `03_seed.sql`, trocando os `UUID-...` pelos reais.

### 4. Conecte o front-end
Copie `js/config.example.js` para `js/config.js` e preencha com a **Project URL** e a **anon key** (Supabase → **Project Settings → API**).

### 5. Publique no GitHub Pages
Suba a pasta para um repositório no GitHub e ative **Settings → Pages → Branch: main**. Em alguns minutos o sistema fica no ar em `https://SEU-USUARIO.github.io/refipdv/`.

---

## Atualizar o cardápio

- **Mudança definitiva** (novo item, preço novo): edite `cardapio.yaml`, faça commit (fica o histórico) e reimporte no Supabase atualizando o `03_seed.sql` ou editando pela tela do Gerente.
- **Esgotou no dia:** o gerente liga/desliga o item pela tela — reflete na hora em todas as telas, sem mexer em arquivo.

---

## Status atual

- ✅ **Banco (SQL):** tabelas, permissões por papel e tempo real — prontos.
- ✅ **Cardápio (`cardapio.yaml`):** pronto e versionado.
- ✅ **Telas (`index.html`):** interface completa das 4 visões, **em modo demonstração** (dados em memória, login fixo de teste).
- ⏳ **Próximo passo:** ligar o `index.html` ao Supabase (login real, pedidos gravando no banco e KDS recebendo em tempo real). É a etapa que falta para virar produção.

### Logins de teste (modo demonstração)
| Acesso | Usuário | Senha |
|---|---|---|
| Mesa | mesa05 (mesa07, mesa10) | 1234 |
| Garçom | joao | 1234 |
| Cozinha | cozinha | 1234 |
| Gerente | gerente | 1234 |
