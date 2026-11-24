# PSX / PS1 RPG 3D Asset Pack — Godot 4 (705 Assets Prontos!)

Este pacote já está **100% configurado para Godot 4.3+**, contendo todos os **705 modelos `.glb`**, texturas `128×128` RGB555 Bayer-dithered (e `512×512` no `Jogador Teste PS2`), **6 shaders `.gdshader`** e **5 scripts `.gd` plug-and-play**.

---

## Como começar em 10 segundos

### Opção A — Abrir direto como projeto novo no Godot 4
1. Abra o **Godot 4** → clique em **Importar (Import)**.
2. Selecione o arquivo `project.godot` dentro desta pasta (`godot_export_pack/project.godot`).
3. Pressione **F5** para rodar a cena de exemplo `scenes/mundo_inicial.tscn`!
   - A variável global `player_world_pos` (para o mato alto dobrar quando o jogador passa) já vem configurada!

### Opção B — Importar em um projeto Godot 4 já existente
1. Copie as pastas **`assets/`**, **`shaders/`** e **`scripts/`** para a raiz (`res://`) do seu projeto.
2. Em **Project → Project Settings → Globals → Shader Globals**, adicione:
   - Nome: `player_world_pos` | Tipo: `vec3`
3. Anexe `res://scripts/psx_auto_effects.gd` ao nó raiz da sua cena para aplicar automaticamente:
   - Filtragem **Nearest-Neighbor (PS1)** em todas as texturas `128×128`
   - Shader de **Líquidos** (`psx_water.gdshader`) em `Liquid_Water`, `Liquid_Lava`, `Liquid_Waterfall` e `Liquid_Mud`
   - Shader de **Mato Interativo** (`psx_foliage_sway.gdshader`) em `mato_alto_*`, `grama_baixa_*` e `samambaia_*`
   - Shader translúcido **Slime** (`psx_slime.gdshader`) em `Slime_Outer`

---

## Scripts Plug-and-Play (`scripts/`)

| Script | Função |
| :--- | :--- |
| `psx_auto_effects.gd` | Aplica automaticamente filtragem PS1, líquidos, mato interativo e slimes em toda a cena (`@tool`) |
| `psx_roof_cutout.gd` | Anexe a um `Area3D` dentro de qualquer prédio (**Taverna, Ferraria, Igreja, Escola de Magia, Delegacia, 4 Torres, Boticário, Enfermaria**) para ocultar ou deixar transparente automaticamente todos os nós `Roof_*` quando o jogador entrar! |
| `psx_foliage_interactor.gd` | Anexe ao nó do Jogador para dobrar o mato alto e a grama em tempo real ao caminhar |
| `psx_fruit_tree.gd` | Troca a cor das frutas em `arvore_frutifera_base_tintavel.glb` e controla colheita (`harvest()` / `regrow()`) |
| `psx_spell_caster.gd` | Dispara as 5 magias animadas com `OmniLight3D` + `GPUParticles3D` sincronizados com `Cast_Spell` |

---

## Escala Métrica Real 1:1 (Godot 4 `Scale = 1, 1, 1`)
- **Tiles de Bioma e Paredes**: grade modular `2.0m × 2.0m` (prontos para `GridMap`!)
- **Jogador / NPCs**: `~1.75m` com `WeaponSocket_R`, `WeaponSocket_L`, `Cloth_Cape` e **11 animações** (`Idle`, `Walk`, `Attack_Sword/Dagger/Axe/Spear/Bow/Staff`, `Cast_Spell`, `Chop_Tree`, `Mine_Ore`)
- **Estabelecimentos da Vila**: Taverna (`16m×12m` p/ 40 jogadores), Ferraria (`12m×10m`), Igreja (`14m×18m`), Escola de Magia (`16m×16m`), Feira (`20m×20m`), Delegacia (`16m×12m` com 4 celas), 4 Torres (`8m×8m`), Boticário (`12m×10m`) e Enfermaria (`14m×12m`).
