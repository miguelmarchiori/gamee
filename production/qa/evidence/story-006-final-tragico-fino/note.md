# Story 006 — thin tragic ending (2026-11-23)

Run: `godot --path . --write-movie <frames>/f.png --quit-after 560 res://src/ui/ending_screen.tscn -- --demo=ending`
(Godot 4.7.2, cloud session, Xvfb + lavapipe).

| Image | Seen |
|---|---|
| `final.png` | The last occupied building burning in the rain, the fire the only strong light; the three ending lines in (Zack gets Lia out and stays behind, the same fire, Lia publishes, the Vértice falls) |
| `epilogo.png` | The burner phone on the wet ground in a puddle, a street light smeared in the water, rain hitting it; the screen lights up "novo contrato disponível", notification light blinking |

Texts come from `assets/data/dispatcher_messages.json` ("ending", "epilogue"). Click or Enter shows
all the lines at once, then moves on; after the epilogue `EndingScreen.finished` returns the game to
the title (`src/flow/game.gd`). That last hand-off was not captured in a run here: play it once.
