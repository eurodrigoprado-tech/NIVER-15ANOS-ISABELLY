-- =====================================================================
-- Lista de Presentes · 15 anos da Isabelly — banco no Supabase
-- Cole este arquivo inteiro no SQL Editor do Supabase e clique em RUN.
-- Pode rodar de novo sem problema (é idempotente).
-- =====================================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------
-- Quem pode entrar no painel /admin (e-mails dos usuários do Supabase Auth)
-- ---------------------------------------------------------------------
create table if not exists public.admins (
  email text primary key
);

create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.admins
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

-- ---------------------------------------------------------------------
-- Presentes (cadastrados no painel)
-- ---------------------------------------------------------------------
create table if not exists public.presentes (
  id         uuid primary key default gen_random_uuid(),
  nome       text not null check (length(trim(nome)) between 1 and 120),
  categoria  text not null default '',
  preco      numeric(10,2),
  foto_url   text,
  link       text,
  ordem      int  not null default 0,
  ativo      boolean not null default true,
  criado_em  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- Presenteadores: quem reservou / deu presente (site ou lançamento manual)
-- ---------------------------------------------------------------------
create table if not exists public.presenteadores (
  id            uuid primary key default gen_random_uuid(),
  presente_id   uuid references public.presentes(id) on delete set null,
  nome          text not null check (length(trim(nome)) between 1 and 80),
  telefone      text,
  descricao     text,            -- quando não é item da lista: "Vale R$ 1.000", "Pix", "Perfume"...
  valor         numeric(10,2),
  status        text not null default 'reservado',
  origem        text not null default 'site' check (origem in ('site', 'manual')),
  observacao    text,
  token         uuid not null default gen_random_uuid(),  -- permite ao convidado cancelar a própria reserva
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- Comprovante do Pix / aprovação (também serve para quem já rodou a versão anterior do script)
alter table public.presenteadores add column if not exists comprovante_path text;
alter table public.presenteadores add column if not exists aprovado_em timestamptz;
alter table public.presenteadores drop constraint if exists presenteadores_status_check;
update public.presenteadores set status = 'comprado' where status = 'recebido';
alter table public.presenteadores add constraint presenteadores_status_check
  check (status in ('reservado', 'comprado', 'agradecido'));
-- reservado  = convidado reservou pelo site (ou lançado no painel), aguardando pagamento
-- comprado   = comprovante conferido e aprovado no painel → aparece como "já comprado" no site
-- agradecido = já mandou o agradecimento

-- Cada item da lista só pode ser reservado uma vez pelo site
create unique index if not exists presenteadores_um_por_presente
  on public.presenteadores (presente_id)
  where presente_id is not null and origem = 'site';

create or replace function public.tocar_atualizado_em()
returns trigger language plpgsql as $$
begin new.atualizado_em := now(); return new; end $$;

drop trigger if exists presenteadores_atualizado on public.presenteadores;
create trigger presenteadores_atualizado before update on public.presenteadores
  for each row execute function public.tocar_atualizado_em();

-- ---------------------------------------------------------------------
-- Segurança (RLS): convidados NÃO acessam as tabelas direto;
-- só o admin. O site público usa as funções abaixo.
-- ---------------------------------------------------------------------
alter table public.admins          enable row level security;
alter table public.presentes       enable row level security;
alter table public.presenteadores  enable row level security;

drop policy if exists "admin le admins" on public.admins;
create policy "admin le admins" on public.admins
  for select to authenticated using (public.is_admin());

drop policy if exists "admin gerencia presentes" on public.presentes;
create policy "admin gerencia presentes" on public.presentes
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin gerencia presenteadores" on public.presenteadores;
create policy "admin gerencia presenteadores" on public.presenteadores
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- ---------------------------------------------------------------------
-- Funções públicas usadas pela página
-- ---------------------------------------------------------------------

-- Lista dos presentes ativos + nome de quem reservou e se já foi comprado (sem telefone/obs/comprovante)
drop function if exists public.lista_publica();
create function public.lista_publica()
returns table (
  id uuid, nome text, categoria text, preco numeric, foto_url text, link text,
  ordem int, reservado_por text, comprado boolean
)
language sql stable security definer set search_path = public
as $$
  select p.id, p.nome, p.categoria, p.preco, p.foto_url, p.link, p.ordem,
         r.nome, coalesce(r.status in ('comprado', 'agradecido'), false)
  from public.presentes p
  left join lateral (
    select x.nome, x.status from public.presenteadores x
     where x.presente_id = p.id
     order by (x.status <> 'reservado') desc, x.criado_em
     limit 1
  ) r on true
  where p.ativo
  order by p.ordem, p.criado_em;
$$;

-- Reserva um presente. Retorna id + token (guardado no aparelho para cancelar).
create or replace function public.reservar(p_presente uuid, p_nome text, p_telefone text default null)
returns table (id uuid, token uuid)
language plpgsql security definer set search_path = public
as $$
#variable_conflict use_column
declare
  v_nome text := left(trim(coalesce(p_nome, '')), 80);
  v_tel  text := nullif(left(trim(coalesce(p_telefone, '')), 30), '');
begin
  if v_nome = '' then raise exception 'nome_obrigatorio'; end if;
  if not exists (select 1 from public.presentes where presentes.id = p_presente and ativo) then
    raise exception 'presente_invalido';
  end if;
  if exists (select 1 from public.presenteadores r where r.presente_id = p_presente) then
    raise exception 'ja_reservado';
  end if;
  return query
    insert into public.presenteadores (presente_id, nome, telefone, origem, status)
    values (p_presente, v_nome, v_tel, 'site', 'reservado')
    returning presenteadores.id, presenteadores.token;
exception when unique_violation then
  raise exception 'ja_reservado';
end $$;

-- Cancela a própria reserva (só com o token que ficou no aparelho, e só se ainda não foi recebida)
create or replace function public.cancelar_reserva(p_id uuid, p_token uuid)
returns boolean
language plpgsql security definer set search_path = public
as $$
begin
  delete from public.presenteadores
   where id = p_id and token = p_token and origem = 'site' and status = 'reservado';
  return found;
end $$;

revoke all on function public.lista_publica()                   from public;
revoke all on function public.reservar(uuid, text, text)        from public;
revoke all on function public.cancelar_reserva(uuid, uuid)      from public;
grant execute on function public.lista_publica()                to anon, authenticated;
grant execute on function public.reservar(uuid, text, text)     to anon, authenticated;
grant execute on function public.cancelar_reserva(uuid, uuid)   to anon, authenticated;

-- ---------------------------------------------------------------------
-- Fotos dos presentes (Storage). Leitura pública, envio só pelo admin.
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('presentes', 'presentes', true)
on conflict (id) do update set public = true;

drop policy if exists "admin envia fotos"   on storage.objects;
drop policy if exists "admin altera fotos"  on storage.objects;
drop policy if exists "admin apaga fotos"   on storage.objects;
create policy "admin envia fotos"  on storage.objects for insert to authenticated
  with check (bucket_id = 'presentes' and public.is_admin());
create policy "admin altera fotos" on storage.objects for update to authenticated
  using (bucket_id = 'presentes' and public.is_admin());
create policy "admin apaga fotos"  on storage.objects for delete to authenticated
  using (bucket_id = 'presentes' and public.is_admin());

-- Comprovantes do Pix (PRIVADO: só o admin vê, por link temporário)
insert into storage.buckets (id, name, public)
values ('comprovantes', 'comprovantes', false)
on conflict (id) do update set public = false;

drop policy if exists "admin ve comprovantes"     on storage.objects;
drop policy if exists "admin envia comprovantes"  on storage.objects;
drop policy if exists "admin altera comprovantes" on storage.objects;
drop policy if exists "admin apaga comprovantes"  on storage.objects;
create policy "admin ve comprovantes"     on storage.objects for select to authenticated
  using (bucket_id = 'comprovantes' and public.is_admin());
create policy "admin envia comprovantes"  on storage.objects for insert to authenticated
  with check (bucket_id = 'comprovantes' and public.is_admin());
create policy "admin altera comprovantes" on storage.objects for update to authenticated
  using (bucket_id = 'comprovantes' and public.is_admin());
create policy "admin apaga comprovantes"  on storage.objects for delete to authenticated
  using (bucket_id = 'comprovantes' and public.is_admin());

-- ---------------------------------------------------------------------
-- >>> TROQUE PELO SEU E-MAIL (o mesmo que você vai criar em Authentication > Users)
-- ---------------------------------------------------------------------
insert into public.admins (email) values ('eurodrigoprado@gmail.com')
on conflict do nothing;
