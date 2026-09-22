// Dados do projeto Supabase (Project Settings > API Keys). A chave "publishable" é pública — pode ficar aqui.
window.SUPABASE_CONFIG = {
  url: 'https://vosvitemqktjhwatkgab.supabase.co',
  anonKey: 'sb_publishable_9_HAgtmMxxJ0o1kiRsj44w_L0BJofS4',

  // Pagamento: depois de reservar, o convidado vê a chave Pix e o botão para mandar o comprovante.
  // Chave Pix: celular no formato '+5562999990000' · CPF/CNPJ só números · e-mail · ou chave aleatória
  pixChave: '51bef32a-24a1-4cb4-a7e8-34ed2eab72a8',   // chave aleatória (Nubank)
  pixTitular: 'Rodrigo Pereira dos Santos Prado',           // nome do dono da conta, como está no banco (ex.: 'Karollina Oliveira Bitencourt')
  pixCidade: 'Sao Paulo',     // cidade do recebedor (sem acento)
  whatsappComprovante: ''   // ex.: '5562999990000' (com DDI 55 + DDD)
};
