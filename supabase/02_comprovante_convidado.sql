-- =====================================================================
-- Convidado envia o comprovante do Pix pelo próprio site
-- Cole no SQL Editor do Supabase e clique em RUN (pode rodar de novo sem problema).
-- =====================================================================

-- Limites do bucket privado de comprovantes: até 10 MB, só imagem ou PDF
update storage.buckets
   set file_size_limit = 10485760,
       allowed_mime_types = array['image/jpeg','image/png','image/webp','image/heic','image/heif','application/pdf']
 where id = 'comprovantes';

-- A pasta do arquivo precisa ser o id de uma reserva que ainda está "reservado"
create or replace function public.reserva_aberta(p_id text)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.presenteadores
    where id::text = p_id and status = 'reservado'
  );
$$;
grant execute on function public.reserva_aberta(text) to anon, authenticated;

drop policy if exists "convidado envia comprovante" on storage.objects;
create policy "convidado envia comprovante" on storage.objects for insert to anon, authenticated
  with check (
    bucket_id = 'comprovantes'
    and public.reserva_aberta((storage.foldername(name))[1])
  );

-- Liga o arquivo à reserva (só com o token que ficou no aparelho de quem reservou)
create or replace function public.anexar_comprovante(p_id uuid, p_token uuid, p_path text)
returns boolean
language plpgsql security definer set search_path = public
as $$
begin
  if p_path is null or p_path not like p_id::text || '/%' then
    return false;
  end if;
  update public.presenteadores
     set comprovante_path = p_path
   where id = p_id and token = p_token and status = 'reservado';
  return found;
end $$;

revoke all on function public.anexar_comprovante(uuid, uuid, text) from public;
grant execute on function public.anexar_comprovante(uuid, uuid, text) to anon, authenticated;
