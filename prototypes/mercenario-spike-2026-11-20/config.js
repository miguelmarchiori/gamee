// PROTOTYPE - NOT FOR PRODUCTION
// Question: O loop de parkour + combate corpo a corpo de um golpe é divertido?
// Date: 2026-11-20
// Every tuning value lives here, each with value, min, max and step. The game reads them live
// through tune.<name> (index.html); the tweak panel, an add-on, writes them back here.
window.CONFIG = {
  seed: 1, // every gameplay random call reads rng(), seeded from this (or ?seed= in the address)

  // ---- Movimento (px = pixels lógicos; 1 bloco = 16 px) ----
  run_speed: { value: 190, min: 80, max: 300, step: 5 },          // px/s, corrida máxima
  ground_accel: { value: 2400, min: 400, max: 4000, step: 50 },   // px/s², aceleração no chão
  air_accel: { value: 1400, min: 200, max: 3000, step: 50 },      // px/s², controle no ar
  air_drag: { value: 200, min: 0, max: 2000, step: 25 },          // px/s², freio no ar sem tecla: baixo = embalo dura
  ground_friction: { value: 2600, min: 400, max: 5000, step: 50 },// px/s², freio ao soltar
  jump_height: { value: 64, min: 30, max: 110, step: 2 },         // px, altura do pulo segurando
  jump_apex_time: { value: 0.28, min: 0.15, max: 0.6, step: 0.01 },// s até o topo do pulo
  fall_gravity_mult: { value: 1.7, min: 1, max: 3, step: 0.05 },  // queda mais rápida que a subida
  jump_cut_gravity_mult: { value: 2.6, min: 1, max: 5, step: 0.1 }, // soltar o pulo cedo = pulinho
  max_fall_speed: { value: 520, min: 200, max: 900, step: 10 },   // px/s
  coyote_time: { value: 0.1, min: 0, max: 0.25, step: 0.01 },     // s, pulo vale logo após sair da borda
  jump_buffer: { value: 0.12, min: 0, max: 0.3, step: 0.01 },     // s, pulo apertado antes de pousar vale

  // ---- Parkour ----
  wall_slide_speed: { value: 60, min: 0, max: 300, step: 5 },     // px/s, escorregar na parede
  wall_jump_push: { value: 240, min: 80, max: 400, step: 5 },     // px/s, empurrão lateral do pulo na parede
  wall_jump_up: { value: 0.95, min: 0.5, max: 1.3, step: 0.05 },  // fração do pulo normal
  wall_jump_lock: { value: 0.13, min: 0, max: 0.4, step: 0.01 },  // s sem controle após pulo na parede
  roll_speed: { value: 300, min: 120, max: 500, step: 5 },        // px/s no início do rolamento
  roll_time: { value: 0.32, min: 0.15, max: 1, step: 0.01 },      // s rolando (invencível)
  roll_friction: { value: 300, min: 0, max: 1500, step: 10 },     // px/s², quanto o rolamento freia

  // ---- Combate do jogador ----
  attack_reach: { value: 22, min: 8, max: 48, step: 1 },          // px, alcance do golpe na direção do mouse
  attack_dash: { value: 170, min: 0, max: 500, step: 5 },         // px/s, passo curto do golpe na direção do mouse
  attack_dash_time: { value: 0.06, min: 0, max: 0.4, step: 0.01 },       // s em que o avanço ignora o controle
  air_attacks: { value: 1, min: 0, max: 5, step: 1 },             // golpes com avanço no ar antes de tocar chão/parede
  attack_cooldown: { value: 0.22, min: 0.08, max: 0.8, step: 0.01 }, // s entre golpes
  deflect_speed_mult: { value: 1.6, min: 0.5, max: 3, step: 0.1 }, // bala rebatida volta mais rápida
  throw_speed: { value: 430, min: 150, max: 800, step: 10 },      // px/s, objeto arremessado
  pistol_ammo: { value: 3, min: 1, max: 12, step: 1 },            // tiros da pistola pega do chão
  player_bullet_speed: { value: 560, min: 200, max: 1000, step: 10 }, // px/s

  // ---- Capanga com faca ----
  thug_patrol_speed: { value: 35, min: 0, max: 120, step: 5 },    // px/s
  thug_chase_speed: { value: 115, min: 40, max: 250, step: 5 },   // px/s
  thug_sight: { value: 150, min: 40, max: 320, step: 5 },         // px, distância que enxerga
  thug_windup: { value: 0.32, min: 0.1, max: 0.8, step: 0.01 },   // s de aviso antes da facada
  thug_reach: { value: 18, min: 8, max: 40, step: 1 },            // px de alcance da facada

  // ---- Atirador ----
  gunner_sight: { value: 230, min: 80, max: 480, step: 5 },       // px
  gunner_aim_time: { value: 0.65, min: 0.2, max: 1.5, step: 0.05 }, // s mirando (laser) antes do tiro
  gunner_lock_time: { value: 0.15, min: 0, max: 0.5, step: 0.01 },  // s finais em que a mira trava
  gunner_cooldown: { value: 1.1, min: 0.3, max: 3, step: 0.05 },  // s entre tiros
  enemy_bullet_speed: { value: 290, min: 100, max: 700, step: 10 },// px/s

  // ---- Dash (SHIFT) ----
  dash_speed: { value: 480, min: 150, max: 900, step: 10 },       // px/s durante o dash
  dash_duration: { value: 0.13, min: 0.05, max: 0.4, step: 0.01 },// s de dash (invencível)
  dash_end_keep: { value: 0.55, min: 0, max: 1, step: 0.05 },     // fração da velocidade mantida ao fim do dash
  dash_cooldown: { value: 0.3, min: 0, max: 1.5, step: 0.05 },    // s entre dashes
  air_dashes: { value: 2, min: 0, max: 5, step: 1 },              // dashes no ar antes de tocar chão ou parede

  // ---- Sensação ----
  restart_delay: { value: 0.45, min: 0.1, max: 1.5, step: 0.05 }, // s entre morrer e a sala recomeçar
  hitstop: { value: 0.05, min: 0, max: 0.2, step: 0.01 },         // s de congelamento a cada abate
  shake: { value: 3, min: 0, max: 8, step: 0.5 },                 // px de tremida a cada abate
  camera_lookahead: { value: 50, min: 0, max: 120, step: 5 },     // px que a câmera mostra à frente

  volume: { value: 0.5, min: 0, max: 1, step: 0.05 },
};
