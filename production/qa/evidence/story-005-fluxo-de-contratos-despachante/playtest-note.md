# Story 005 — contract flow, scripted run (2026-11-23)

Run: `godot --path . --write-movie <frames>/f.png --quit-after 1300 res://src/flow/game.tscn -- --demo=flow --demo=contract`
(Godot 4.7.2, cloud session, Xvfb + lavapipe). Sheet: `fluxo-contato.png`.

Seen in order: the title screen → Contract 1's message → its four rooms → "contrato cumprido" →
Contract 2's message (pagamento, o resolvedor debaixo do Minhocão, os papéis) → its gray stand-in room →
Contract 3's message (o mapa, a hacker na Liberdade) → Contract 4's message (a menina viva, a torre na
Faria Lima) → the final message (a traição, o último prédio, o fogo) → back to the title, and a new start
from Contract 1.

All texts come from `assets/data/dispatcher_messages.json` (canon: Provisional), with the named
placeholder `{zack}`; every line is under 120 characters. Nothing is saved between sessions.
