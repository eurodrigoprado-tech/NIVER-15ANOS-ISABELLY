-- =====================================================================
-- Cartões-presente com estoque (ex.: 50 unidades de R$ 100)
-- Cole no SQL Editor do Supabase e clique em RUN.
-- =====================================================================

-- quantidade disponível do item (null ou 1 = item único, como os presentes normais)
alter table public.presentes add column if not exists estoque int;

-- antes só cabia 1 reserva por item; agora o limite é o estoque (conferido na função reservar)
drop index if exists public.presenteadores_um_por_presente;

-- Lista pública agora informa estoque, vendidos e disponíveis
drop function if exists public.lista_publica();
create function public.lista_publica()
returns table (
  id uuid, nome text, categoria text, preco numeric, foto_url text, link text,
  ordem int, reservado_por text, comprado boolean,
  estoque int, vendidos int, disponiveis int
)
language sql stable security definer set search_path = public
as $$
  select p.id, p.nome, p.categoria, p.preco, p.foto_url, p.link, p.ordem,
         r.nome,
         coalesce(r.status in ('comprado', 'agradecido'), false),
         coalesce(p.estoque, 1),
         coalesce(v.qtd, 0)::int,
         greatest(coalesce(p.estoque, 1) - coalesce(v.qtd, 0), 0)::int
  from public.presentes p
  left join lateral (
    select x.nome, x.status from public.presenteadores x
     where x.presente_id = p.id
     order by (x.status <> 'reservado') desc, x.criado_em
     limit 1
  ) r on true
  left join lateral (
    select count(*) as qtd from public.presenteadores y where y.presente_id = p.id
  ) v on true
  where p.ativo
  order by p.ordem, p.criado_em;
$$;

-- Reserva respeitando o estoque (trava por item para dois cliques ao mesmo tempo não furarem o limite)
create or replace function public.reservar(p_presente uuid, p_nome text, p_telefone text default null)
returns table (id uuid, token uuid)
language plpgsql security definer set search_path = public
as $$
#variable_conflict use_column
declare
  v_nome    text := left(trim(coalesce(p_nome, '')), 80);
  v_tel     text := nullif(left(trim(coalesce(p_telefone, '')), 30), '');
  v_estoque int;
  v_usado   int;
begin
  if v_nome = '' then raise exception 'nome_obrigatorio'; end if;

  select coalesce(presentes.estoque, 1) into v_estoque
    from public.presentes where presentes.id = p_presente and ativo;
  if v_estoque is null then raise exception 'presente_invalido'; end if;

  perform pg_advisory_xact_lock(hashtext(p_presente::text));

  select count(*) into v_usado from public.presenteadores where presente_id = p_presente;
  if v_usado >= v_estoque then
    raise exception using message = case when v_estoque > 1 then 'esgotado' else 'ja_reservado' end;
  end if;

  return query
    insert into public.presenteadores (presente_id, nome, telefone, origem, status)
    values (p_presente, v_nome, v_tel, 'site', 'reservado')
    returning presenteadores.id, presenteadores.token;
end $$;

revoke all on function public.lista_publica()            from public;
revoke all on function public.reservar(uuid, text, text) from public;
grant execute on function public.lista_publica()         to anon, authenticated;
grant execute on function public.reservar(uuid, text, text) to anon, authenticated;

-- ---------------------------------------------------------------------
-- Cria os 6 cartões-presente, 50 unidades cada (não duplica se rodar de novo)
-- ---------------------------------------------------------------------
insert into public.presentes (nome, categoria, preco, ordem, estoque, ativo)
select 'Cartão-presente de R$ ' || to_char(v.valor, 'FM999G999'), 'CARTAO-PRESENTE', v.valor, 900 + v.ord, 50, true
from (values (100, 1), (150, 2), (300, 3), (600, 4), (800, 5), (900, 6)) as v(valor, ord)
where not exists (
  select 1 from public.presentes p
   where upper(p.categoria) = 'CARTAO-PRESENTE' and p.preco = v.valor
);
