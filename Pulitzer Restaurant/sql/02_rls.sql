-- ============================================================
--  RefiPDV — Permissões (Row Level Security)
--  Rode este arquivo DEPOIS do 01_schema.sql.
--
--  Regra do negócio:
--   - mesa    : só cria/vê pedidos da PRÓPRIA mesa. Nada de cardápio.
--   - garcom  : cria pedido em qualquer mesa e vê o salão.
--   - cozinha : vê pedidos e muda o status (preparo/pronto).
--   - gerente : tudo, inclusive editar o cardápio.
-- ============================================================

-- Funções auxiliares: descobrem o papel e a mesa do usuário logado.
create or replace function auth_papel() returns text
  language sql stable as $$ select papel   from perfis where id = auth.uid() $$;

create or replace function auth_mesa_id() returns bigint
  language sql stable as $$ select mesa_id from perfis where id = auth.uid() $$;

-- Liga o RLS em todas as tabelas.
alter table perfis         enable row level security;
alter table mesas          enable row level security;
alter table itens_cardapio enable row level security;
alter table pedidos        enable row level security;
alter table pedido_itens   enable row level security;

-- ---------- perfis ----------
create policy "perfil: ler o proprio"
  on perfis for select using (id = auth.uid());

-- ---------- mesas ----------
create policy "mesas: todos leem"
  on mesas for select using (auth.role() = 'authenticated');
create policy "mesas: so gerente edita"
  on mesas for all
  using (auth_papel() = 'gerente')
  with check (auth_papel() = 'gerente');

-- ---------- cardápio ----------
create policy "cardapio: todos leem"
  on itens_cardapio for select using (auth.role() = 'authenticated');
create policy "cardapio: so gerente edita"
  on itens_cardapio for all
  using (auth_papel() = 'gerente')
  with check (auth_papel() = 'gerente');

-- ---------- pedidos ----------
create policy "pedidos: leitura"
  on pedidos for select using (
    auth_papel() in ('garcom','cozinha','gerente')
    or (auth_papel() = 'mesa' and mesa_id = auth_mesa_id())
  );

create policy "pedidos: inserir"
  on pedidos for insert with check (
    (auth_papel() = 'mesa' and mesa_id = auth_mesa_id())
    or auth_papel() in ('garcom','gerente')
  );

create policy "pedidos: atualizar status"
  on pedidos for update using (
    auth_papel() in ('cozinha','garcom','gerente')
  );

-- ---------- pedido_itens (seguem o pedido) ----------
create policy "itens: leitura"
  on pedido_itens for select using (
    exists (
      select 1 from pedidos p
      where p.id = pedido_id and (
        auth_papel() in ('garcom','cozinha','gerente')
        or (auth_papel() = 'mesa' and p.mesa_id = auth_mesa_id())
      )
    )
  );

create policy "itens: inserir"
  on pedido_itens for insert with check (
    exists (
      select 1 from pedidos p
      where p.id = pedido_id and (
        (auth_papel() = 'mesa' and p.mesa_id = auth_mesa_id())
        or auth_papel() in ('garcom','gerente')
      )
    )
  );
