# Story 004: Contrato 1: Galeria (Santa Ifigênia)

> **Epic**: Zack Reddman
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Build step**: core
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: —

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 4`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (First minute, Challenge, Core loop, Goal & fail state, Look) and `design/narrative/historia.md` (Contrato 1), scoped to this story.*

- [ ] A fase abre com uma mensagem do Despachante no celular com o contrato. O texto pode ser provisório até a Story 005.
- [ ] O cenário é uma galeria de eletrônicos da Santa Ifigênia: corredores apertados, fiação exposta, lâmpada fluorescente piscando, pichação, poste de sódio pela janela. Sem neon.
- [ ] São pelo menos 4 salas em sequência. Cada sala fica limpa quando todos os inimigos morrem, e aí a próxima abre.
- [ ] A primeira sala ensina sozinha: um capanga de costas e uma garrafa para arremessar.
- [ ] A segunda sala é o primeiro aperto: dois atiradores cobrindo um corredor, uma parede para escalar e um capanga embaixo.
- [ ] A última sala tem o receptador (o alvo). Matar o receptador cumpre o contrato.
- [ ] No escritório do receptador aparece o logo da Construtora Vértice em caixas de documentos (a pista).
- [ ] Morrer recomeça só a sala atual, na hora.
- [ ] O tempo de cada sala e o total aparecem na tela, e o fim do contrato mostra a tela de "contrato cumprido".

---

## Implementation Notes

- Junta as Stories 001 a 003 numa fase de verdade.
- O receptador pode ser um inimigo comum com outro visual, desde que seja o alvo marcado.
- Godot 4.7: confira `docs/engine-reference/godot/` antes de usar qualquer API.

---

## Out of Scope

- Story 005: o fluxo entre contratos e as mensagens definitivas do Despachante.
- Story 007: os contratos 2 a 4.

---

## Files

- `src/levels/contract_1_galeria.tscn`
- `src/levels/contract_level.gd`
- `src/ui/hud.gd`
- `tests/integration/levels/levels_contract_1_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: Test: waived at qa.level minimal (advisory). A playtest note of the full contract is recommended.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/zack-reddman/story-001-movimento-no-godot.md`, `production/epics/zack-reddman/story-002-combate-de-um-golpe.md`, `production/epics/zack-reddman/story-003-dois-tipos-de-inimigo.md`
- Unlocks: `production/epics/zack-reddman/story-005-fluxo-de-contratos-despachante.md`
