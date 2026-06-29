-- ============================================================
--  RefiPDV — Dados iniciais (seed)
--  Rode DEPOIS do schema. Reflete o cardapio.yaml.
-- ============================================================

-- Mesas
insert into mesas (numero, nome) values
  ('01','Mesa 01'),
  ('02','Mesa 02'),
  ('05','Mesa 05'),
  ('07','Mesa 07'),
  ('10','Mesa 10')
on conflict (numero) do nothing;

-- Cardápio (mesmo conteúdo do cardapio.yaml)
insert into itens_cardapio (nome, categoria, preco, emoji, disponivel) values
  ('X-Salada',     'Hambúrgueres', 28.00, '🍔', true),
  ('X-Bacon',      'Hambúrgueres', 32.00, '🥓', true),
  ('X-Tudo',       'Hambúrgueres', 39.00, '🍔', true),
  ('Batata frita', 'Porções',      22.00, '🍟', true),
  ('Onion rings',  'Porções',      26.00, '🧅', false),
  ('Refri lata',   'Bebidas',       7.00, '🥤', true),
  ('Suco natural', 'Bebidas',      12.00, '🧃', true),
  ('Milk-shake',   'Sobremesas',   18.00, '🍦', true);

-- ------------------------------------------------------------
--  USUÁRIOS E PAPÉIS
--  Crie os usuários em Authentication > Users (e-mail + senha),
--  copie o UUID de cada um e rode os inserts abaixo trocando
--  'UUID-...' pelos IDs reais. Veja o README, passo 3.
-- ------------------------------------------------------------
-- Exemplo (descomente e ajuste os UUIDs):
--
-- insert into perfis (id, papel, nome, mesa_id) values
--   ('UUID-DO-GERENTE',  'gerente', 'Samária', null),
--   ('UUID-DO-GARCOM',   'garcom',  'João',    null),
--   ('UUID-DA-COZINHA',  'cozinha', 'Cozinha', null),
--   ('UUID-DA-MESA-05',  'mesa',    'Mesa 05', (select id from mesas where numero = '05'));
