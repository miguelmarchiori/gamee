# Story 001: Movimento no Godot

> **Epic**: Zack Reddman
> **Status**: Ready
> **Layer**: Core
> **Type**: Visual/Feel
> **Estimate**: L
> **Build step**: core
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: —

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 1`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Controls, Features 1, Keep), scoped to this story. Números: os valores aprovados em `prototypes/mercenario-spike-2026-11-20/config.js`.*

- [ ] A/D movem o Zack até 190 px/s, com aceleração de 2400 px/s² no chão e 1400 no ar, e freio de 2600 px/s² ao soltar no chão.
- [ ] W/Espaço pula 64 px segurando (topo em 0,28 s). Soltar cedo dá um pulinho. O pulo vale até 0,1 s depois de sair da borda e até 0,12 s antes de pousar.
- [ ] Apertar o pulo no ar faz o pulo duplo (1 extra, 90% da força) com cambalhota. Recarrega ao tocar o chão ou uma parede.
- [ ] Empurrando contra a parede no ar, o Zack escorrega no máximo a 60 px/s. Pular ali empurra para longe da parede (240 px/s) e recarrega pulo duplo e dashes.
- [ ] S no chão rola por 0,32 s (300 px/s) com o corpo baixo e marcado como invencível. S no ar cai rápido.
- [ ] Shift dá um dash para onde o mouse aponta: 480 px/s por 0,13 s, invencível, ficando com 55% da velocidade no fim. São 2 no ar, recarregam no chão ou na parede, com 0,3 s entre dashes.
- [ ] A câmera segue o Zack mostrando 50 px à frente para onde ele olha, puxada levemente na direção do mouse.
- [ ] Todo número acima vive num arquivo de ajuste externo, nunca no código (padrão de código do projeto).
- [ ] O Zack é desenhado em pixel art com contorno, como `references/zack-reddman.png`: cabelo preto bagunçado, olho direito verde, olho esquerdo branco e cego com a queimadura, moletom escuro e faixas nas mãos. Pode ser provisório, desde que se reconheça.
- [ ] Uma sala de teste em cinza deixa experimentar todos os movimentos.

---

## Implementation Notes

- Referência de comportamento: `prototypes/mercenario-spike-2026-11-20/index.html` (`updatePlayer`). É a especificação, não código para copiar: o protótipo é JavaScript e é reescrito em GDScript.
- Valores: crie um recurso de ajuste em `assets/data/` com os números do `config.js` do teste.
- Godot 4.7 é posterior ao treinamento do modelo: confira `docs/engine-reference/godot/` antes de usar qualquer API.

---

## Out of Scope

- Story 002: soco, rebater balas, pegar, arremessar e atirar, morte e reinício da sala.
- Story 003: inimigos.

---

## Files

- `src/player/zack.gd`
- `src/player/zack.tscn`
- `assets/data/player_tuning.tres`
- `tests/unit/player/player_movement_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: a retained screenshot in `production/qa/evidence/` + sign-off in `production/qa/evidence/story-001-movimento-no-godot-evidence.md` (tests waived at `qa.level: minimal`; the screenshot is not).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/zack-reddman/story-002-combate-de-um-golpe.md`, `production/epics/zack-reddman/story-003-dois-tipos-de-inimigo.md`
