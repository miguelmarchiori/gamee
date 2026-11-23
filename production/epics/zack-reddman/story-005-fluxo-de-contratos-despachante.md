# Story 005: Fluxo de contratos com o Despachante (fino)

> **Epic**: Zack Reddman
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Build step**: thin — contratos que levam à história e ao final
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 5`, `Brief Your systems: contratos que levam à história e ao final`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Core loop, Features 5, Build order) and `design/narrative/historia.md`, scoped to this story. Este é o sistema em versão fina: existe e está ligado ao resto, no mais simples.*

- [ ] Os contratos vêm em ordem: Contrato 1, 2, 3, 4 e o Último Prédio.
- [ ] Entre contratos, uma tela de celular mostra a mensagem do Despachante, e clique ou Enter avança.
- [ ] Os contratos 2, 3 e 4 existem como versão fina: uma sala cinza cada, com o nome (Minhocão, Liberdade, Faria Lima). Limpar a sala avança.
- [ ] Terminar o contrato 4 leva ao final (Story 006).
- [ ] Os textos das mensagens ficam num arquivo de dados, nunca no código, prontos para tradução, com marcadores nomeados e no máximo 120 caracteres por linha.
- [ ] As mensagens seguem os pontos da história, marcadas como provisórias: a pista da Vértice, o mapa do Centro, o contrato da Lia e a traição.
- [ ] Uma tela de título começa a sequência do zero.

---

## Implementation Notes

- Fino de propósito: as fases completas dos contratos 2 a 4 são da Story 007.
- Canon dos textos: Provisional (`design/narrative/historia.md`).
- Godot 4.7: confira `docs/engine-reference/godot/` antes de usar qualquer API.

---

## Out of Scope

- Story 006: a tela do final.
- Story 007: os contratos 2 a 4 completos.
- Salvar o progresso entre sessões.

---

## Files

- `src/flow/game.gd`
- `src/flow/game.tscn`
- `src/ui/title_screen.gd`
- `src/ui/phone_message.gd`
- `src/core/messages.gd`
- `src/levels/contract_level.gd`
- `assets/data/dispatcher_messages.json`
- `assets/data/campaign.json`
- `assets/data/contracts/contract_1.json`
- `assets/data/contracts/contract_2.json`
- `assets/data/contracts/contract_3.json`
- `assets/data/contracts/contract_4.json`
- `assets/data/rooms/thin/contract_2.json`
- `assets/data/rooms/thin/contract_3.json`
- `assets/data/rooms/thin/contract_4.json`
- `project.godot`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: Test: waived at qa.level minimal (advisory). A screenshot of the phone message screen is recommended.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/zack-reddman/story-004-contrato-1-galeria.md`
- Unlocks: `production/epics/zack-reddman/story-006-final-tragico-fino.md`, `production/epics/zack-reddman/story-007-contratos-2-a-4.md`
