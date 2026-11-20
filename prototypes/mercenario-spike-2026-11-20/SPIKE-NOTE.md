<!-- PROTOTYPE - NOT FOR PRODUCTION -->
<!-- Question: O loop de parkour + combate corpo a corpo de um golpe é divertido? -->
<!-- Date: 2026-11-20 -->
# Nota do teste: Mercenário

**Pergunta testada:** o loop de parkour + combate corpo a corpo de um golpe é divertido?

**Resultado:** SIM. A equipe jogou e aprovou ("ficou maneirão") depois de quatro rodadas de ajuste.

**O que mudou durante o teste, a partir do playtest da equipe:**
- Golpe e dash passaram a mirar com o mouse.
- O golpe virou um soco curto. O avanço longo fazia o personagem "voar".
- A câmera lenta saiu e o Shift virou dash invencível (2 no ar).
- Entraram o pulo duplo e o rolamento invencível no S.
- O visual ganhou contorno nos sprites, rastro, luzes de neon, scanlines e resolução nítida em tela cheia.

**Valores que funcionaram:** estão em `config.js` (corrida 190 px/s, pulo 64 px, dash 480 px/s, soco com passo de 170 px/s, 1 pulo extra, 2 dashes no ar).

**Próximo passo:** levar esse movimento e combate para o jogo de verdade. Passos:
1. Definir a história (4 contratos que levam ao plot e ao final).
2. Escrever o brief do jogo.
3. Escolher a engine.

O código do teste não vira código do jogo. Ele é reescrito, usando esta nota e o `config.js` como referência.
