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
--  Crie os usuários em Authentication > Users (só e-mail + senha).
--  A tela do Supabase NÃO tem campo de papel — quem define o papel
--  é a tabela 'perfis', com os comandos abaixo.
--
--  Forma fácil: o comando acha o usuário PELO E-MAIL e já marca o papel.
--  Troque os e-mails pelos que você cadastrou e rode no SQL Editor.
-- ------------------------------------------------------------
insert into perfis (id, papel, nome)
select id, 'gerente', 'Carlos'
from auth.users where email = 'carlos.arquitetocg@gmail.com';

-- insert into perfis (id, papel, nome)
-- select id, 'garcom', 'João'
-- from auth.users where email = 'joao@pulitzer.com';

-- insert into perfis (id, papel, nome)
-- select id, 'cozinha', 'Cozinha'
-- from auth.users where email = 'cozinha@pulitzer.com';

-- insert into perfis (id, papel, nome, mesa_id)
-- select id, 'mesa', 'Mesa 05', (select id from mesas where numero = '05')
-- from auth.users where email = 'mesa05@pulitzer.com';
