# Story 008: O Último Prédio e o final completos

> **Epic**: Zack Reddman
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Build step**: deepen — final trágico
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: —

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 7`, `Brief Your systems: final trágico`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [ ] O Último Prédio e o final trágico built out as `design/gdd/final-trágico.md` describes.

---

## Implementation Notes

- **Antes de construir:** rode `/design-system final trágico`. Esse documento ainda não existe, e é ele que dá os critérios desta história.
- Material para o documento: `design/narrative/historia.md` (Final: O Último Prédio, subida com o fogo atrás, luta contra o Bené no telhado, desfecho e epílogo) e o brief (o fogo é a única luz forte do jogo).

---

## Out of Scope

- Polimento geral de som e telas (Build order 6 do brief).

---

## Files

- `src/levels/last_building.tscn`
- `src/enemies/bene_boss.gd`
- `tests/integration/levels/levels_last_building_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: Test: waived at qa.level minimal (advisory).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/zack-reddman/story-006-final-tragico-fino.md`, `production/epics/zack-reddman/story-007-contratos-2-a-4.md`
- Unlocks: None
