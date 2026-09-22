// Dados do projeto Supabase (Project Settings > API Keys). A chave "publishable" é pública — pode ficar aqui.
window.SUPABASE_CONFIG = {
  url: 'https://vosvitemqktjhwatkgab.supabase.co',
  anonKey: 'sb_publishable_9_HAgtmMxxJ0o1kiRsj44w_L0BJofS4',

  // Pagamento: depois de reservar, o convidado vê a chave Pix e o botão para mandar o comprovante.
  // Chave Pix: celular no formato '+5562999990000' · CPF/CNPJ só números · e-mail · ou chave aleatória
  pixChave: '',
  pixTitular: '',           // nome do dono da conta, como está no banco (ex.: 'Karollina Oliveira Bitencourt')
  pixCidade: 'Goiania',     // cidade do recebedor (sem acento)
  whatsappComprovante: ''   // ex.: '5562999990000' (com DDI 55 + DDD)
};
