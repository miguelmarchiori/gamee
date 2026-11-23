# Story 003 — enemies, scripted run (2026-11-23)

Run: `godot --path . --write-movie <frames>/f.png --quit-after 230 res://src/levels/test_room.tscn -- --demo=enemies`
(Godot 4.7.2, cloud session, Xvfb + lavapipe). Sheet: `inimigos-contato.png`.

| Frame | Seen |
|---|---|
| 30 | Thugs patrolling; the one on the walkway turns at its edges and never falls |
| 72 | The ground thug sees Zack on his level: red dot, chasing |
| 84 | In reach he stops and winds up: yellow "!" and the raised knife |
| 93 | The stab; Zack dies (HUD "Mortes 1" at 110) and the room restarts |
| 145 | A gunner sees Zack: thin, blinking red laser on him |
| 166 | Last part of the aim: the laser goes solid and thick (locked) |
| 178 | The shot flies to the locked point |
| 200 | The bullet kills Zack (HUD "Mortes 2") |

Not covered by the run: a gunner losing sight before the lock (cancels the aim). Tests waived at
`qa.level: minimal`; the states are explicit enums (`Thug.State`, `Gunner.State`) for when tests come.
