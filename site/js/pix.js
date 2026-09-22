// Gera o "Pix copia e cola" (BR Code estático, padrão EMV do Banco Central) com valor.
(function () {
  'use strict';
  function limpar(txt, max) {
    return String(txt || '')
      .normalize('NFD').replace(/[̀-ͯ]/g, '')   // sem acentos
      .replace(/[^A-Za-z0-9 .\-@]/g, '')
      .trim().slice(0, max);
  }
  function campo(id, valor) {
    var v = String(valor);
    return id + String(v.length).padStart(2, '0') + v;
  }
  function crc16(str) {
    var crc = 0xFFFF;
    for (var i = 0; i < str.length; i++) {
      crc ^= str.charCodeAt(i) << 8;
      for (var j = 0; j < 8; j++) crc = (crc & 0x8000) ? ((crc << 1) ^ 0x1021) & 0xFFFF : (crc << 1) & 0xFFFF;
    }
    return crc.toString(16).toUpperCase().padStart(4, '0');
  }
  // chave: CPF/CNPJ só números, e-mail, "+5562999990000" para celular, ou chave aleatória
  window.gerarPix = function (o) {
    var txid = String(o.txid || '***').replace(/[^A-Za-z0-9]/g, '').slice(0, 25) || '***';
    var conta = campo('00', 'br.gov.bcb.pix') + campo('01', String(o.chave).trim());
    if (o.descricao) conta += campo('02', limpar(o.descricao, 40));
    var p = campo('00', '01') +
      campo('26', conta) +
      campo('52', '0000') +
      campo('53', '986') +
      (o.valor ? campo('54', Number(o.valor).toFixed(2)) : '') +
      campo('58', 'BR') +
      campo('59', limpar(o.nome, 25).toUpperCase() || 'RECEBEDOR') +
      campo('60', limpar(o.cidade, 15).toUpperCase() || 'GOIANIA') +
      campo('62', campo('05', txid)) +
      '6304';
    return p + crc16(p);
  };
  window.__crc16Pix = crc16;
})();
