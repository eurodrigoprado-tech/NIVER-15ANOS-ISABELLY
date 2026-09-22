# Handoff: Lista de Presentes — 15 anos da Isabelly

## Overview
Página única em português (pt-BR) para os convidados da festa de 15 anos da Isabelly Bitencourt.
Reúne, em ordem: contagem regressiva para a festa, capa com foto da debutante, vale-presente de
R$ 1.000 (bilhete destacável com efeito de tilt 3D), lista de presentes com reserva por convidado
(persistida em localStorage), convite completo em "papel" com monograma, dados do evento, botão
para o mapa e carrossel de referências de traje, e rodapé de agradecimento.

Evento: 03 de outubro de 2026, 21h — Tropical Village, Rua Caracas - Setor Andreia, Goiânia - GO, 74354-540.

## About the Design Files
Os arquivos deste pacote são **referências de design feitas em HTML** — protótipos que mostram
aparência e comportamento pretendidos, **não** código de produção para copiar direto.
A tarefa é **recriar estes designs no ambiente já existente do codebase** (React, Vue, SwiftUI,
nativo etc.), usando seus padrões e bibliotecas. Se ainda não houver ambiente, escolher o framework
mais adequado e implementar ali.

Os arquivos `.dc.html` usam um runtime próprio de componentes (template + classe de lógica).
Ignore o runtime: interessam o markup, os valores de estilo (todos inline) e a lógica descrita abaixo.

## Fidelity
**High-fidelity.** Cores, tipografia, espaçamentos e interações são finais. Recriar com fidelidade
de pixel usando as bibliotecas do codebase.

## Screens / Views

### 1. Página única — "Lista de Presentes - Isabelly.dc.html"
Fundo de toda a página: `radial-gradient(120% 80% at 50% 0%, #8A1C26 0%, #6B131C 45%, #4A0C13 100%)`,
`background-attachment: fixed`. Padding lateral 16px.

#### 1.1 Contagem regressiva (topo)
- Container: max-width 720px, centralizado, padding 40px 0 8px, texto centralizado.
- Eyebrow "FALTAM": Cinzel 11px, letter-spacing .3em, cor #E0C484.
- Quatro anéis (DIAS / HORAS / MINUTOS / SEGUNDOS), flex wrap, gap 18px, margin-top 20px.
- Cada anel: 104×104px. Progresso via `conic-gradient(#E0C484 0deg Xdeg, rgba(224,196,132,0.2) Xdeg 360deg)`
  recortado em anel com `mask: radial-gradient(farthest-side, transparent calc(100% - 5px), #000 calc(100% - 5px))`.
- Número: Cormorant Garamond 32px, #FBEFD3. Rótulo: Cinzel 9px, letter-spacing .18em, #E0C484, margin-top 5px.
- Frações do anel: dias = min(1, dias/60); horas = horas/24; minutos = min/60; segundos = seg/60.

#### 1.2 Capa (cartão creme com topo em arco)
- Cartão: max-width 720px, `linear-gradient(176deg,#FBF6EA,#F4EBD9)`,
  `border-radius: 50% 50% 3px 3px / 13% 13% 0 0`, padding 52px 30px 40px,
  `box-shadow: 0 40px 90px rgba(28,4,8,.55), 0 2px 0 rgba(255,255,255,.5) inset`.
- Ornamento de topo: duas linhas `linear-gradient(to right/left, transparent, #C19A4B)` com losango
  7×7px `rotate(45deg)` #C19A4B no centro.
- "LISTA DE PRESENTES": Cinzel 500, clamp(15px,3.4vw,21px), letter-spacing .18em, #3A2320.
- "Isabelly": Pinyon Script 400, clamp(54px,13vw,96px), line-height 1.15, #8C1F2C.
- "quinze anos": Cormorant Garamond itálico, clamp(18px,4vw,23px), #5A413C.
- Foto: max-width 460px, moldura `1px solid #C9A863` + padding 6px sobre #FFFBF1;
  img `aspect-ratio:4/3; object-fit:cover; object-position:52% 24%` (uploads/BAN001.jpg).
- Parágrafo de abertura: max-width 430px, clamp(17px,3.6vw,19px), line-height 1.6, #4A322E, centralizado.

#### 1.3 Vale-presente (dentro do cartão creme)
- Eyebrow "O MAIOR PRESENTE": Cinzel 13px, letter-spacing .24em, #7B5A2E.
- Texto: Cormorant Garamond 19px, line-height 1.6, #4A322E, max-width 410px.
- Bilhete: 741×425px, escalado por JS para caber (`transform: scale(min(1, (larguraDisponível)/741))`,
  origem top center; o container tem padding 26px 34px 34px e `overflow: visible` para não cortar o tilt).
- Recorte do bilhete (clip-path path, coordenadas em px sobre 741×425):
  `M 25 0 L 541 0 A 21 21 0 0 0 583 0 L 716 0 A 25 25 0 0 1 741 25 L 741 400 A 25 25 0 0 1 716 425
   L 583 425 A 21 21 0 0 0 541 425 L 25 425 A 25 25 0 0 1 0 400 L 0 25 A 25 25 0 0 1 25 0 Z`
  (cantos convexos r=25, entalhes côncavos r=21 no picote x=562).
- Camadas de fundo do bilhete: `linear-gradient(150deg,#FDF8EC,#F6EDDA 42%,#EFE2C8)`;
  textura `repeating-linear-gradient(45deg, rgba(193,154,75,.055) 0 2px, transparent 2px 6px)`;
  brilho `radial-gradient(70% 90% at 78% 18%, rgba(255,255,255,.75), transparent 60%)`.
- Picote: x=562, largura 2px, `repeating-linear-gradient(to bottom, rgba(140,31,44,.4) 0 9px, transparent 9px 18px)`.
- Canhoto: x 562→741, fundo `linear-gradient(180deg, rgba(140,31,44,.07), rgba(140,31,44,.02))`;
  "CANHOTO" (Cinzel 11px, .22em, #7B5A2E) no topo; "PRESENTE" vertical (`writing-mode: vertical-rl`,
  Cinzel 600 40px, .18em, #8C1F2C) no centro entre dois losangos; "R$ 1.000" na base.
- Molduras internas: retângulo 498×377 em (32,24) `1px solid rgba(193,154,75,.75)` e
  488×367 em (37,29) `1px solid rgba(193,154,75,.35)`.
- Textos (posição absoluta, origem no canto do bilhete):
  - ornamento em (64,52), largura 434;
  - "VALE-PRESENTE" em y=76: Cinzel 500 17px, letter-spacing .3em, #7B5A2E;
  - valor "R$ 1.000,00" em y=112 (left 52, width 458): Cinzel 700 56px, line-height 1, #8C1F2C, `white-space:nowrap`;
  - "mil reais" em y=180: Cormorant itálico 22px, #5A4030;
  - ornamento em y=216 (left 150, width 262);
  - "ISABELLY" em y=244: Cinzel 600 26px, letter-spacing .12em, #2B1A18;
  - "FESTA DE 15 ANOS" em y=284: Cormorant 19px, letter-spacing .1em, #6B534E;
  - rodapé em y=350: Cinzel 11px, letter-spacing .16em, #7B5A2E — "Nº 001" à esquerda, "VÁLIDO ATÉ A FESTA" à direita.
- Legenda abaixo do bilhete: "Leve o vale impresso no dia da festa." Cormorant 17px, #6B534E.

#### 1.4 Lista de presentes
- Título "SUGESTÕES": Cinzel 500, clamp(17px,3.8vw,23px), letter-spacing .2em, #F6E7C6, sobre o vinho.
- Filtros (TODOS / DISPONÍVEIS / JÁ RESERVADOS): Cinzel 500 11px, letter-spacing .18em, padding 11px 22px,
  borda 1px. Ativo: borda #E0C484, fundo #F6E7C6, texto #5E1018. Inativo: borda rgba(224,196,132,.55),
  fundo transparente, texto #F1DDB9.
- Grid: max-width 760px, `repeat(auto-fit, minmax(215px,1fr))`, gap 22px, align-items stretch.
- Card: `linear-gradient(176deg,#FBF6EA,#F4EBD9)`, `border-radius: 50% 50% 2px 2px / 7% 7% 0 0`,
  padding 14px 14px 20px, `box-shadow: 0 14px 34px rgba(28,4,8,.42)`.
  - Placeholder de foto: moldura `1px solid #D8BC85` + padding 4px sobre #FFFBF1; interior
    `aspect-ratio:4/3` com `repeating-linear-gradient(135deg,#F0E4CB 0 8px,#F8F0DF 8px 16px)` e
    rótulo monoespaçado 9.5px "FOTO DO PRESENTE" em #A9915F. **Substituir por foto real quando houver.**
  - Categoria: Cinzel 9.5px, letter-spacing .2em, #7B5A2E.
  - Nome: Cormorant 600 21px, `min-height: 50px` (flex center) para alinhar preços entre colunas.
  - Preço: 18px, #8C1F2C.
  - Botão "RESERVAR": largura total, Cinzel 500 11px, letter-spacing .18em, padding 12px 8px,
    borda #C9A863, texto #5C5149; hover: fundo/borda #8C1F2C, texto #FBF6EA.
  - Estado reservado: separador `1px solid #E0CDA4`, texto "Reservado por {nome}" em Cormorant itálico
    17px #8C1F2C e link "cancelar reserva" (14px, #9A8163, sublinhado).

#### 1.5 Modal de reserva
- Overlay `rgba(30,5,9,.66)`, centralizado, z-index 50; clique no overlay fecha, clique no cartão não propaga.
- Cartão: mesmo gradiente creme, `border-radius: 50% 50% 3px 3px / 10% 10% 0 0`, max-width 400px,
  padding 40px 32px 34px, `box-shadow: 0 30px 70px rgba(20,2,6,.6)`.
- Ornamento, "RESERVAR PRESENTE" (Cinzel 11px, .22em, #7B5A2E), nome do presente (Cormorant 600 27px),
  input de nome (Cormorant 19px, borda #C9A863, fundo #FFFBF1, texto centralizado),
  botões "VOLTAR" (contorno #C9A863) e "CONFIRMAR" (#8C1F2C sólido, texto #FBF6EA).

#### 1.6 Convite (bloco "papel")
- Caixa fixa 600×1324px, escalada por JS (`min(1,(largura-40)/600)`), `linear-gradient(176deg,#FDF9EF,#F7EFDD 52%,#F1E6CE)`,
  `box-shadow: 0 34px 76px rgba(18,2,6,.5)`, `overflow:hidden`.
- Textura `repeating-linear-gradient(45deg, rgba(193,154,75,.05) 0 2px, transparent 2px 7px)`.
- Duas molduras: `inset:18px` `1px solid rgba(193,154,75,.7)` e `inset:24px` `1px solid rgba(193,154,75,.3)`,
  ambas com `z-index:3` para passarem **por cima** do carrossel full-bleed.
- Posições absolutas (y em px):
  - 56: monograma IB (imagem PNG transparente), 128×133, centralizado;
  - 252: "OS PAIS" — Cinzel 12px, .3em, #7B5A2E;
  - 284 (left 50, width 500): nomes dos pais e irmã — Cinzel 13px, line-height 1.55, #2B1A18;
  - 388: "CONVIDAM PARA O ANIVERSÁRIO DE 15 ANOS" — Cinzel 12.5px, .1em, #5A4030;
  - 438: "Isabelly Bitencourt" — Pinyon Script 70px, #8C1F2C;
  - 604 (left 52, width 496): grid `1fr 1.9fr 1fr`, `align-items: stretch`, colunas DATA / LOCAL / HORÁRIO,
    divisórias `border-left/right: 1px solid rgba(193,154,75,.65)` na coluna do meio.
    Rótulos: Cinzel 10px, .26em, #7B5A2E. Valores "03" e "21": Cormorant 38px, `min-height:38px` (flex center).
    Detalhes ("outubro / 2026", endereço, "horas"): Cormorant 15–17px, #5A4030.
    Botão "VER NO MAPA": Cinzel 500 10.5px, .18em, padding 10px 20px, borda #8C1F2C, texto #8C1F2C,
    hover fundo #8C1F2C / texto #FDF9EF; href para Google Maps com o endereço.
  - 812: "TRAJE" — Cinzel 10px, .26em, #7B5A2E;
  - 836: "All Black" — Cormorant 23px, #2B1A18;
  - 876: carrossel full-bleed (left 0, width 600, `overflow:hidden`);
  - 1226 (left 70, width 460): R.S.V.P. — Cormorant 15px, line-height 1.55, #5A4030.

#### 1.7 Rodapé
- Ornamento dourado; "OBRIGADA POR FAZER PARTE / DESSE DIA COMIGO" em Cinzel, clamp(15px,3.4vw,19px),
  letter-spacing .14em, #F6E7C6; nota "As reservas ficam salvas neste aparelho." em Cormorant itálico 16px, #E4BFBF.

## Interactions & Behavior

- **Contagem regressiva**: `setInterval` de 1s atualizando o estado; alvo `2026-10-03T21:00:00-03:00`;
  trava em zero (`Math.max(0, alvo - agora)`). Limpar o intervalo ao desmontar.
- **Reserva**: clicar em "RESERVAR" abre o modal; "CONFIRMAR" só grava com nome não vazio (trim);
  grava `{ [idPresente]: nome }` em `localStorage["isabelly15_reservas_v1"]`; "cancelar reserva" remove a chave.
  Leitura no mount dentro de try/catch.
- **Filtros**: todos / apenas não reservados / apenas reservados.
- **Tilt 3D do vale** (desktop, mouse): loop em `requestAnimationFrame` com interpolação exponencial
  (fator .12 para posição, .09 para intensidade), aplicando
  `perspective(1400px) rotateX(-y*15deg) rotateY(x*15deg) scale(1 + .018*k)`, onde x,y ∈ [-.5,.5] são a
  posição do cursor no cartão e k ∈ [0,1] é a intensidade (1 com o mouse dentro, 0 fora).
  O loop encerra quando a diferença para o alvo fica abaixo de .0008 (posição) / .004 (intensidade).
  Duas camadas acompanham o cursor: brilho radial (`mix-blend-mode: soft-light`, opacidade = k,
  `translate(x*34%, y*34%)`) e faixa diagonal dourada (`rotate(18deg) translateX(150% + x*240%)`, opacidade .85k).
  Transições CSS são desligadas durante o loop e religadas (500ms ease-out) no repouso.
- **Carrossel de trajes**: marquee CSS infinito da direita para a esquerda —
  `@keyframes desfileLooks { from { translateX(0) } to { translateX(-768px) } }`, 22s linear infinite.
  3 looks (240px cada, gap 16px) duplicados → track 1520px. Regra do loop sem falhas:
  `larguraDoTrack >= deslocamento + larguraDaViewport` e o deslocamento deve ser múltiplo exato da
  unidade que se repete (3 × (240+16) = 768px).
- **Escala responsiva** do vale e do convite: `ResizeObserver` nos containers recalcula o `scale`;
  a margem inferior é compensada com `margin-bottom: (escala - 1) * altura`.
- **Hovers**: botões invertem fundo/texto em 180ms.

## State Management
- `reservas: Record<idPresente, nomeConvidado>` — espelhado em localStorage.
- `filtro: 'todos' | 'disponiveis' | 'reservados'`.
- `modal: idPresente | null` e `nome: string` (campo do modal).
- `agora: number` (timestamp, 1 Hz) — alimenta a contagem regressiva.
- `escala`, `escalaConvite`: números 0–1 vindos do ResizeObserver.
- Tilt: fora do React/estado — mutação direta de `style.transform` via refs no rAF (evita re-render por frame).
- Sem data fetching. Os presentes são um array constante no módulo; trocar por API/CMS se necessário.

## Design Tokens

Cores
- Vinho principal: #8C1F2C · escuro: #5E1018 · gradiente de fundo: #8A1C26 / #6B131C / #4A0C13
- Creme: #FBF6EA, #F4EBD9, #FDF9EF, #F7EFDD, #F1E6CE, #FFFBF1
- Tinta: #2B1A18 (títulos) · #4A322E, #5A4030, #6B534E (corpo)
- Dourado: #C19A4B (filetes) · #C9A863, #D8BC85, #E0CDA4 (bordas) · #7B5A2E (rótulos, contraste AA)
- Dourado claro sobre vinho: #F6E7C6, #FBEFD3, #E0C484, #F1DDB9 · rosa claro: #E4BFBF

Tipografia
- Cinzel (400/500/600/700): rótulos, botões, nomes em caixa alta. Tracking .1em–.3em.
- Cormorant Garamond (400/500/600, itálico): corpo, números, textos longos.
- Pinyon Script (400): nome da debutante.
- Escala usada: 9.5, 10, 11, 12, 13, 15, 16, 17, 19, 21, 23, 26, 32, 38, 40, 56, 70 px + clamps citados.

Espaçamento: múltiplos de 2/4 px; gaps de 10, 12, 14, 16, 18, 22, 26, 34 px; seções separadas por 28–78 px.

Raios: 2–4px nos cartões retangulares; arcos via `border-radius: 50% 50% x x / y y 0 0` (13% capa, 7% cards, 10% modal).

Sombras
- Capa: `0 40px 90px rgba(28,4,8,.55)` + `0 2px 0 rgba(255,255,255,.5) inset`
- Cards: `0 14px 34px rgba(28,4,8,.42)`
- Convite: `0 34px 76px rgba(18,2,6,.5)`
- Vale: `drop-shadow(0 18px 38px rgba(20,2,6,.3))` (no clip-path, não `box-shadow`)
- Modal: `0 30px 70px rgba(20,2,6,.6)`

## Assets
Todos enviados pelo usuário, na pasta `uploads/` deste pacote:
- `BAN001.jpg` — foto da debutante na decoração da festa (capa).
- `14f68b9c-7857-4e9f-a5da-ad3603157541.png` — monograma IB com flor, metálico, fundo transparente (convite).
- `pasted-1790045891063-0.png`, `pasted-1790046113325-0.png`, `pasted-1790046457980-0.png` — três referências de traje all black (carrossel).
Fontes: Google Fonts (Cinzel, Cormorant Garamond, Pinyon Script).
Os placeholders listrados dos presentes devem ser substituídos por fotos reais dos itens.

## Files
- `Lista de Presentes - Isabelly.dc.html` — página principal (tudo descrito acima).
- `Cartao Presente R$1000.dc.html` — o vale-presente isolado, em página própria, com o mesmo
  bilhete 741×425 e o tilt 3D. Útil para imprimir/enviar o vale sozinho.
- `uploads/` — imagens originais.

Observação: nos dois arquivos, o markup fica entre `<x-dc>...</x-dc>` e a lógica em
`class Component extends DCLogic` dentro de `<script data-dc-script>`; `renderVals()` devolve os valores
que o template consome. Traduzir para o padrão do codebase alvo (ex.: um componente React com hooks).
