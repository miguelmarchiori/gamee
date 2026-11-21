# Story 002: Combate de um golpe no Godot

> **Epic**: Zack Reddman
> **Status**: Ready
> **Layer**: Core
> **Type**: Integration
> **Estimate**: L
> **Build step**: core
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: —

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 2`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Controls, Features 2, Goal & fail state, Avoid), scoped to this story.*

- [ ] Clique esquerdo dá um soco para onde o mouse aponta. O braço estica com o punho na ponta (nunca um corte de katana), com um passo curto de 170 px/s, alcance de 22 px e 0,22 s entre socos. No ar, só um impulso por pulo, e o Zack não sai voando.
- [ ] Um soco mata qualquer inimigo que acerta, com uma pausa de 0,05 s e uma tremida de 3 px na tela.
- [ ] Um soco que pega uma bala inimiga devolve a bala para onde o mouse aponta, 1,6 vez mais rápida. A bala rebatida mata inimigos.
- [ ] Clique direito/E pega o item mais perto (até 22 px). Com item na mão, arremessa para onde o mouse aponta a 430 px/s. O item mata o primeiro inimigo que acerta, e a garrafa quebra.
- [ ] O atirador morto deixa uma pistola com 3 tiros. Clique direito atira para onde o mouse aponta, e a pistola vazia é arremessada.
- [ ] Um golpe ou um tiro mata o Zack, exceto rolando ou no dash. A sala recomeça 0,45 s depois, com Zack, inimigos e itens de volta ao início.
- [ ] R recomeça a sala a qualquer momento.
- [ ] Quando todos os inimigos da sala morrem, a sala fica "limpa" e avisa isso (a Story 004 usa para abrir a próxima sala).
- [ ] Todo número acima vive no arquivo de ajuste externo.

---

## Implementation Notes

- Referência de comportamento: `prototypes/mercenario-spike-2026-11-20/index.html` (golpe, `drawPunches`, `updateItems`, `updateBullets`, `killPlayer`, `restartRoom`).
- Godot 4.7: confira `docs/engine-reference/godot/` antes de usar qualquer API.

---

## Out of Scope

- Story 003: comportamento dos inimigos (patrulha, perseguição, mira).
- Story 004: a sequência de salas do contrato.

---

## Files

- `src/combat/punch.gd`
- `src/combat/bullet.gd`
- `src/combat/pickup_item.gd`
- `src/rooms/room.gd`
- `assets/data/combat_tuning.tres`
- `tests/integration/combat/combat_one_hit_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: Test: waived at qa.level minimal (advisory). An integration test or a short playtest note is welcome but not required.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/zack-reddman/story-001-movimento-no-godot.md`
- Unlocks: `production/epics/zack-reddman/story-003-dois-tipos-de-inimigo.md`
