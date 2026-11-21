# Story 007: Contratos 2 a 4 completos

> **Epic**: Zack Reddman
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Build step**: deepen — contratos que levam à história e ao final
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: —

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 6`, `Brief Your systems: contratos que levam à história e ao final`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [ ] Contratos 2 a 4 built out as `design/gdd/contratos-que-levam-à-história-e-ao-final.md` describes.

---

## Implementation Notes

- **Antes de construir:** rode `/design-system contratos que levam à história e ao final`. Esse documento ainda não existe, e é ele que dá os critérios desta história.
- Material para o documento: `design/narrative/historia.md` (Minhocão, Liberdade e Faria Lima: clima, alvo e virada de cada um) e o brief (um tipo de inimigo novo por contrato).

---

## Out of Scope

- Story 008: O Último Prédio e o final.

---

## Files

- `src/levels/contract_2_minhocao.tscn`
- `src/levels/contract_3_liberdade.tscn`
- `src/levels/contract_4_faria_lima.tscn`
- `tests/integration/levels/levels_contracts_2_to_4_test.gd`

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

- Depends on: `production/epics/zack-reddman/story-005-fluxo-de-contratos-despachante.md`
- Unlocks: `production/epics/zack-reddman/story-008-ultimo-predio-e-final.md`
