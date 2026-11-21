# Story 006: Final trágico (fino)

> **Epic**: Zack Reddman
> **Status**: Ready
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: S
> **Build step**: thin — final trágico
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: —

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Your systems: final trágico`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Goal & fail state, Your systems) and `design/narrative/historia.md` (Final e Epílogo), scoped to this story. Versão fina: no lugar do Último Prédio entra uma tela.*

- [ ] Depois do contrato 4, uma tela de final conta o desfecho em texto provisório: Zack tira a Lia do prédio e fica para trás.
- [ ] O epílogo mostra o celular descartável no chão molhado recebendo "novo contrato disponível".
- [ ] Depois do epílogo, o jogo volta para a tela de título.
- [ ] Os textos vêm do arquivo de dados das mensagens, nunca do código.
- [ ] O clima é o do brief: São Paulo de madrugada, garoa, sem neon.

---

## Implementation Notes

- Fino de propósito: a fase do prédio em chamas e a luta contra o Bené são da Story 008.
- Godot 4.7: confira `docs/engine-reference/godot/` antes de usar qualquer API.

---

## Out of Scope

- Story 008: O Último Prédio jogável e o final completo.

---

## Files

- `src/ui/ending_screen.tscn`
- `src/ui/ending_screen.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: UI
**Required evidence**: a retained screenshot of each screen touched (the ending and the epilogue) in `production/qa/evidence/`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/zack-reddman/story-005-fluxo-de-contratos-despachante.md`
- Unlocks: `production/epics/zack-reddman/story-008-ultimo-predio-e-final.md`
