# Game Brief: Zack Reddman (título provisório)

## In your words
plataforma 2d estilo katana zero sobre um mercenario
1. Combate: corpo a corpo porem pode pegar armas no meio
2. Morte: um golpe mata o player e os inimigos
3. Tempo lento: nao
4. Sensação: rapido e preciso bewm fluido varios parkours
5. Visual: pixel art
6. Missão: uns 4 contratos q vao levando ao plot e desfeixo final do jogo
7. Recorte: so um teste rapido

After play: faz mais estilo katana zero usando o mouse e deixa os graficos melhoreszinhos parecidos com o d katana zero msm
After play: achei mto pouco fluido ainda faz mais dash tipo pra cima diagonal etc
After play: tira a camera lenta bota dashes no shift
After play: mano bota dash pra cima dash pro lado essas coisas, e quando ele golpeia ele ta indo mto pra frente da tipo pra voar
After play: faz os dashs serem por mira igual os ataques e os ataques tao mto parecidos com uma katana, faz parecer mais com um soco pfv
After play: double jump, a resolução ta meio baixa
After play: ficou maneirao
After play: Quem é o mercenário? Zack Reddman, 21 anos queimadura na cara · Onde se passa? São Paulo 2026 · O que move a história? No começo dinheiro no final salvar alguem? · Como termina? final trágico
After play: sem neon pfv
After play: curti mto a vibe

**Pitch:** Zack Reddman, 21 anos, rosto queimado e um olho cego, cumpre contratos de madrugada numa São Paulo de garoa e concreto, matando no soco e morrendo com um golpe, até descobrir que quem paga é quem pôs fogo na vida dele.

**Genre:** plataforma 2D de ação de um golpe (plataforma + ação estilosa)

**Controls:** A D para mover · W/Espaço para pular (no ar, pulo duplo; na parede, pulo na parede) · S no chão rola (invencível), no ar cai rápido · mouse mira · clique esquerdo dá um soco na direção do mouse · Shift dá um dash invencível na direção do mouse · clique direito/E pega, arremessa e atira · R recomeça a sala.

**Question:** uma fase inteira (o Contrato 1, Galeria) segura o ritmo do começo ao alvo? *(guessed: o loop de uma sala já foi aprovado no teste)*

**Hooks:** soco e dash mirados no mouse, com um golpe que mata qualquer um · parkour fluido (pulo duplo, pulo na parede, 2 dashes no ar) · a São Paulo real de madrugada, sem neon · Zack, com a queimadura e o olho cego, num final trágico.

**Intent:**

## Look and references
- Look: pixel art 2D com personagens contornados. São Paulo de madrugada: garoa, concreto molhado, pichação de letras altas e retas, poste de sódio alaranjado, lâmpada fluorescente, luz vermelha de aviso no alto das torres, caixa d'água nos telhados. Paleta de cinzas e marrons. Laranja do poste e branco da fluorescente são a luz. Vermelho só para sangue, mira e alerta. Cor forte só onde a história pede: as lanternas da Liberdade e o fogo do final. Detalhe de assinatura: a pichação paulistana em cada parede. Sem neon. Todo personagem desenhado, nunca emoji ou forma simples.
- References: Katana Zero (o estilo de ação de um golpe com mouse, salas como quebra-cabeça de quem matar primeiro) · `references/zack-reddman.png` (o rosto do Zack: cabelo preto bagunçado, olho direito verde, olho esquerdo branco e cego, queimadura no lado esquerdo do rosto) · `design/narrative/historia.md` (história e clima de cada fase).
- View: 2D · Camera: lateral, seguindo o Zack, mostrando um pouco à frente de onde ele vai e para onde o mouse aponta.

## First minute
O celular descartável vibra: o Despachante manda o primeiro contrato. Zack entra num corredor da galeria da Santa Ifigênia, com fiação exposta e lâmpada piscando. Um capanga de faca patrulha de costas, e o primeiro soco o derruba. Uma garrafa pisca no chão: Zack pega e arremessa no próximo. Um atirador acende o laser na sala seguinte, e Zack dá um dash por cima da linha de tiro e cai socando. Quando a sala fica limpa, o tempo aparece na tela e a porta para o escritório do receptador se abre. *(guessed)*

## Challenge
O primeiro aperto é na segunda sala: dois atiradores cobrindo um corredor, a parede para escalar e um capanga embaixo. Um golpe ou um tiro mata, e a sala recomeça na hora, só com segundos perdidos. Cada contrato traz um tipo de inimigo novo. O Último Prédio troca a luta por uma subida contra o fogo e termina no Bené. *(guessed)*

## Core loop
- Entrar numa sala, ler onde estão os inimigos e planejar a ordem.
- Executar em segundos com parkour, soco, dash e armas do chão. Um erro reinicia a sala na hora.
- Sala limpa abre a próxima. A última sala tem o alvo do contrato.
- Entre contratos, uma mensagem do Despachante avança a história e leva ao próximo bairro.

## Goal & fail state
- Cumprir os 4 contratos e sobreviver ao Último Prédio para tirar Lia do fogo.
- Um golpe ou um tiro mata o Zack, e a sala recomeça na hora.

## Features
- [x] Movimento: corrida, pulo e pulo duplo, pulo na parede, rolamento invencível e 2 dashes no ar mirados no mouse
- [x] Combate de um golpe: soco mirado no mouse que rebate balas; pegar, arremessar e atirar com garrafa, faca e pistola
- [x] 2 tipos de inimigo: capanga de faca e atirador com laser de mira
- [ ] Contrato 1 completo (Galeria, Santa Ifigênia): várias salas e o alvo no fim
- [ ] Mensagens do Despachante no celular entre os contratos
- [ ] Contratos 2 a 4 (Minhocão, Liberdade, Faria Lima), com um tipo de inimigo novo por contrato
- [ ] O Último Prédio: subida pelo prédio em chamas e luta contra o Bené

## Your systems
- movimento e parkour · in the slice
- combate de um golpe · in the slice
- armas pegas no meio · in the slice
- dash no Shift · in the slice
- contratos que levam à história e ao final · later
- final trágico · later

## Keep
- o movimento e o combate como estão *(you said: "ficou maneirao")* · pins: run_speed 190, jump_height 64, air_jumps 1, dash_speed 480, air_dashes 2, attack_dash 170
- a vibe de São Paulo sem neon *(you said: "curti mto a vibe")*

## Avoid
- câmera lenta ("tira a camera lenta")
- golpe que faz o personagem voar ("quando ele golpeia ele ta indo mto pra frente da tipo pra voar")
- golpe com cara de katana: é soco ("faz parecer mais com um soco")
- neon ("sem neon pfv")
- o nome, a arte, os personagens e a interface de Katana Zero: ele é referência de estilo, não algo a copiar

## Out of scope
- os contratos 2 a 4, o Último Prédio e as mensagens do Despachante: grow it
- câmera lenta: removida a pedido
- multiplayer e controles de celular
- dublagem; os diálogos são em texto

## Build order
1. Sala de teste: movimento, soco, dash e 2 inimigos. Limpar a sala é a vitória e um golpe é a derrota. **Feito e aprovado.**
2. Contrato 1 (Galeria): uma fase completa, do primeiro corredor ao receptador.
3. Mensagens do Despachante entre fases.
4. Contratos 2 a 4, com um inimigo novo em cada.
5. O Último Prédio: subida com fogo e chefe Bené.
6. Polimento: sons, telas, final e epílogo.

---
**Kill condition:** se o Contrato 1 completo ficar repetitivo antes de chegar ao alvo, depois de duas rodadas de ajuste. *(guessed)*

**Who it's for / what they feel:** quem gosta de ação rápida e difícil. A sensação é de executar uma sala perfeita em segundos, numa história pesada. *(guessed)*

**Games you love / don't:** curtem Katana Zero (o estilo, o mouse, o um-golpe-mata).
