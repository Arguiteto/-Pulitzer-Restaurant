-- ============================================================
--  RefiPDV — Esquema do banco (Supabase / PostgreSQL)
--  Rode este arquivo PRIMEIRO, no SQL Editor do Supabase.
-- ============================================================

-- Perfis: liga cada usuário do Supabase Auth a um papel.
-- papel: 'mesa' | 'garcom' | 'cozinha' | 'gerente'
-- mesa_id: preenchido só para usuários do tipo 'mesa'.
create table if not exists perfis (
  id       uuid primary key references auth.users(id) on delete cascade,
  papel    text not null check (papel in ('mesa','garcom','cozinha','gerente')),
  nome     text,
  mesa_id  bigint
);

-- Mesas do salão.
create table if not exists mesas (
  id      bigint generated always as identity primary key,
  numero  text not null unique,
  nome    text,
  ativo   boolean not null default true
);

-- Itens do cardápio.
-- 'disponivel' é a flag do dia (esgotar/repor) controlada pelo Gerente.
create table if not exists itens_cardapio (
  id          bigint generated always as identity primary key,
  nome        text not null,
  categoria   text not null,
  preco       numeric(10,2) not null check (preco >= 0),
  emoji       text,
  disponivel  boolean not null default true,
  criado_em   timestamptz not null default now()
);

-- Pedidos (uma comanda enviada para a cozinha).
create table if not exists pedidos (
  id         bigint generated always as identity primary key,
  mesa_id    bigint not null references mesas(id),
  origem     text not null default 'cliente',   -- 'cliente' | 'garcom'
  atendente  text,                              -- nome do garçom, quando houver
  status     text not null default 'novo'
             check (status in ('novo','preparo','pronto','entregue','cancelado')),
  criado_em  timestamptz not null default now()
);

-- Itens de cada pedido (com preço "fotografado" no momento do pedido).
create table if not exists pedido_itens (
  id          bigint generated always as identity primary key,
  pedido_id   bigint not null references pedidos(id) on delete cascade,
  item_id     bigint not null references itens_cardapio(id),
  qtd         int not null default 1 check (qtd > 0),
  preco_unit  numeric(10,2) not null,
  obs         text
);

create index if not exists idx_pedidos_status on pedidos (status);
create index if not exists idx_pedido_itens_pedido on pedido_itens (pedido_id);

-- ------------------------------------------------------------
-- Tempo real: a Cozinha "escuta" mudanças nestas tabelas.
-- (Bloco seguro: só adiciona se ainda não estiver na publicação,
--  então pode rodar de novo sem dar erro 42710.)
-- ------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array['pedidos','pedido_itens','itens_cardapio'] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table %I', t);
    end if;
  end loop;
end $$;
