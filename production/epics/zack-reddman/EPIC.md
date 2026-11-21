# Epic: Zack Reddman

> **Status**: Active
> **Tier**: minimal (built from `design/game-brief.md`, no GDDs or ADRs)
> **Engine**: Godot 4.7.2 (GDScript)

## Goal

Zack Reddman, 21 anos, rosto queimado e um olho cego, cumpre contratos de madrugada numa São
Paulo de garoa e concreto, matando no soco e morrendo com um golpe, até descobrir que quem paga
é quem pôs fogo na vida dele. *(Pitch do brief)*

## Scope

As funcionalidades do brief (`design/game-brief.md` § Features):

1. Movimento: corrida, pulo e pulo duplo, pulo na parede, rolamento invencível e 2 dashes no ar mirados no mouse
2. Combate de um golpe: soco mirado no mouse que rebate balas; pegar, arremessar e atirar com garrafa, faca e pistola
3. 2 tipos de inimigo: capanga de faca e atirador com laser de mira
4. Contrato 1 completo (Galeria, Santa Ifigênia): várias salas e o alvo no fim
5. Mensagens do Despachante no celular entre os contratos
6. Contratos 2 a 4 (Minhocão, Liberdade, Faria Lima), com um tipo de inimigo novo por contrato
7. O Último Prédio: subida pelo prédio em chamas e luta contra o Bené

Os itens 1 a 3 existem só no teste do navegador (`prototypes/mercenario-spike-2026-11-20/`). No
Godot eles são reescritos, com o teste e o `config.js` dele como especificação.

## Order

A ordem segue o esqueleto do brief ("Your systems"):
1. **Core:** movimento, combate, inimigos e o Contrato 1.
2. **Every system thin:** o fluxo de contratos com o Despachante e o final, em versão fina.
3. **Deepen:** contratos 2 a 4, depois o Último Prédio e o final.

História e clima: `design/narrative/historia.md`.

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Movimento no Godot | Visual/Feel | Ready | N/A |
| 002 | Combate de um golpe no Godot | Integration | Ready | N/A |
| 003 | Dois tipos de inimigo no Godot | Logic | Ready | N/A |
| 004 | Contrato 1: Galeria (Santa Ifigênia) | Integration | Ready | N/A |
| 005 | Fluxo de contratos com o Despachante (fino) | Integration | Ready | N/A |
| 006 | Final trágico (fino) | UI | Ready | N/A |
| 007 | Contratos 2 a 4 completos | Integration | Ready | N/A |
| 008 | O Último Prédio e o final completos | Integration | Ready | N/A |
