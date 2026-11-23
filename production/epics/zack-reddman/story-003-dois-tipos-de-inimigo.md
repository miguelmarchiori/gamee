# Story 003: Dois tipos de inimigo no Godot

> **Epic**: Zack Reddman
> **Status**: In Progress
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Build step**: core
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 3`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Features 3, Challenge, Look), scoped to this story.*

- [ ] O capanga patrulha a plataforma dele a 35 px/s, vira nas paredes e nas bordas e nunca cai.
- [ ] O capanga vê o Zack a até 150 px na horizontal, no mesmo nível e sem parede no meio. Aí ele persegue a 115 px/s e para na borda.
- [ ] Ao alcance (18 px), o capanga prepara a facada por 0,32 s com um aviso visível e depois ataca. A facada mata o Zack se ele estiver nela.
- [ ] O atirador vê o Zack a até 230 px, sem parede no meio, e mira por 0,65 s com um laser. Nos últimos 0,15 s a mira trava. Ele atira a 290 px/s no ponto travado e espera 1,1 s até o próximo tiro.
- [ ] Se o atirador perde o Zack de vista por 0,3 s antes de a mira travar, ele desiste da mira.
- [ ] As balas param nas paredes.
- [ ] Os dois morrem com um golpe e o corpo fica no chão até a sala recomeçar.
- [ ] O comportamento de cada inimigo é uma máquina de estados explícita (capanga: patrulha, persegue, prepara, ataca, recupera; atirador: parado, mira), com os números no arquivo de ajuste externo.
- [ ] Visual como no brief: capanga de boné e jaqueta marrom, atirador de terno e óculos escuros, em pixel art com contorno.

---

## Implementation Notes

- Referência de comportamento: `prototypes/mercenario-spike-2026-11-20/index.html` (`updateEnemies`).
- A pistola que o atirador deixa ao morrer é da Story 002.
- Godot 4.7: confira `docs/engine-reference/godot/` antes de usar qualquer API.

---

## Out of Scope

- Story 007: os inimigos novos dos contratos 2 a 4.

---

## Files

- `src/enemies/thug.gd`
- `src/enemies/gunner.gd`
- `src/enemies/enemy.gd`
- `src/levels/room.gd`
- `src/levels/room_session.gd`
- `src/levels/test_room.gd`
- `assets/data/tuning.json`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: Test: waived at qa.level minimal (advisory). A unit test of the state machines is recommended.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/zack-reddman/story-001-movimento-no-godot.md`, `production/epics/zack-reddman/story-002-combate-de-um-golpe.md`
- Unlocks: `production/epics/zack-reddman/story-004-contrato-1-galeria.md`
