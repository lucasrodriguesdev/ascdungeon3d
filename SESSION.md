# SESSION.md — Session Spec & Handoff Log (ASC Dungeon 3D)

Este arquivo é a **fonte única de contexto e continuidade** entre todos os agentes (**Codex**, **Claude**, **Gemini**) que trabalharem no projeto **ASC Dungeon 3D**.

---

## 1. Regra de Ouro — Origem e Destino dos Assets

- **Diretório oficial do projeto:** `C:\Users\lucas\joguinhos\ascdungeon3d`
- **A partir de 2026-11-24, TODOS os assets devem ser lidos, criados e atualizados diretamente dentro de `C:\Users\lucas\joguinhos\ascdungeon3d\assets\`** (bem como `scenes/`, `scripts/` e `shaders/`).
- A pasta legada `C:\Users\lucas\.gemini\antigravity\scratch\psx_assets_godot` **não deve mais ser usada** como fonte ou destino de assets. Caso algum script gerador Python legado seja reutilizado, sua saída deve apontar diretamente para `C:\Users\lucas\joguinhos\ascdungeon3d\assets\`.

---

## 2. Ambiente e Ferramentas (Godot 4.7.2)

- **Projeto:** `C:\Users\lucas\joguinhos\ascdungeon3d\project.godot` (`Godot 4.7`, `Forward Plus`)
- **Cena principal:** `res://scenes/mundo_inicial.tscn`
- **Godot GUI:** `C:\Users\lucas\tools\Godot\Godot_v4.7.2-stable_win64.exe`
- **Godot Console (recomendado para CLI/automação com stdout):** `C:\Users\lucas\tools\Godot\Godot_v4.7.2-stable_win64_console.exe`

### Comandos úteis
```powershell
# Reimportar assets alterados (.glb, .png, .gdshader, etc.)
& "C:\Users\lucas\tools\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path "C:\Users\lucas\joguinhos\ascdungeon3d" --import

# Executar um script de validação headless
& "C:\Users\lucas\tools\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path "C:\Users\lucas\joguinhos\ascdungeon3d" --script "res://scripts/meu_check.gd"
```

---

## 3. Mapa Rápido do Projeto

- `assets/` — 705+ modelos `.glb`, texturas `128x128` RGB555 (e `512x512` em `jogador_teste_ps2.glb`) e `assets/manifest.json`.
  - `assets/characters/` — 15 personagens (`.glb`), todos com **22 animações** (`Idle`, `Walk`, `Jump_Heavy`, `Jump_Light`, `Crouch`, `Roll_F`, `Roll_B`, `Roll_L`, `Roll_R`, `Roll_FL`, `Roll_FR`, `Roll_BL`, `Roll_BR`, `Attack_Dagger`, `Attack_Sword`, `Attack_Axe`, `Attack_Spear`, `Attack_Bow`, `Attack_Staff`, `Cast_Spell`, `Chop_Tree`, `Mine_Ore`).
- `scenes/` — `mundo_inicial.tscn`, `psx_postprocess.tscn`.
- `scripts/` — `psx_auto_effects.gd`, `psx_foliage_interactor.gd`, `psx_fruit_tree.gd`, `psx_roof_cutout.gd`, `psx_spell_caster.gd`.
- `shaders/` — `psx_spatial.gdshader`, `psx_postprocess.gdshader`, `psx_water.gdshader`, `psx_foliage_sway.gdshader`, `psx_slime.gdshader`, `psx_magic_vfx.gdshader`.
- Instruções por agente: `AGENTS.md` (Codex), `CLAUDE.md` (Claude), `GEMINI.md` (Gemini).

---

## 4. Protocolo Obrigatório de Sessão (Spec)

Todo agente que atuar neste repositório **deve** seguir este ciclo:

1. **Ao iniciar a sessão:**
   - Ler este `SESSION.md` (especialmente as 3 últimas entradas do histórico) para recuperar contexto, decisões recentes e pendências.
2. **Durante a execução:**
   - Ler e gravar assets, cenas, scripts e shaders **direto em `C:\Users\lucas\joguinhos\ascdungeon3d`**.
   - Sempre que alterar `.glb`, texturas, shaders ou scripts, rodar `--headless --import` e validar no Godot Console que não há erros de importação/carregamento.
3. **Ao encerrar a sessão (OBRIGATÓRIO):**
   - Adicionar uma nova entrada **no topo** da seção `## 5. Histórico de Sessões` usando o template abaixo.
   - Registrar de forma objetiva o que foi feito, quais arquivos mudaram, como foi validado e o que ficou pendente para o próximo agente.

### Template de Entrada
```markdown
### [YYYY-MM-DD HH:MM] — <Agente (Codex / Claude / Gemini)>
- **Objetivo:** <resumo curto do pedido>
- **Atividades realizadas:**
  - <item 1>
  - <item 2>
- **Arquivos alterados/criados:** `<caminhos principais>`
- **Validação (Godot / testes):** <comando rodado e resultado>
- **Próximos passos / Pendências:** <o que o próximo agente precisa saber>
```

---

## 5. Histórico de Sessões

### [2026-11-24 19:37] — Gemini
- **Objetivo:** Commitar o projeto completo (assets PSX com 22 animações, cenas, scripts, shaders e docs de agentes) diretamente na branch `master`.
- **Atividades realizadas:**
  - Revisado `.gitignore` (`.godot/` e `*.translation` ignorados; `.import` e `.uid` mantidos versionados para estabilidade no Godot 4.7.2).
  - Realizado commit inicial completo do projeto diretamente na branch `master` em `C:\Users\lucas\joguinhos\ascdungeon3d`.
- **Arquivos alterados/criados:** Todos os arquivos do projeto versionados na `master` (`project.godot`, `assets/`, `scenes/`, `scripts/`, `shaders/`, `docs_README_GODOT.md`, `SESSION.md`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`).
- **Validação (Godot / testes):** `git status` limpo na `master`; assets já validados na sessão anterior (`15/15` personagens com 22 animações).
- **Próximos passos / Pendências:**
  - Trabalhar diretamente na branch `master` em `C:\Users\lucas\joguinhos\ascdungeon3d`.
  - Implementar controlador do jogador (`CharacterBody3D` + `AnimationPlayer`/`AnimationTree`) usando as 22 animações de `res://assets/characters/jogador.glb`.

### [2026-11-24 19:35] — Gemini
- **Objetivo:** Sincronizar animações e assets atualizados de `psx_assets_godot` para `ascdungeon3d`, reimportar/validar no Godot 4.7.2 e instituir fluxo unificado de sessão e instruções para Codex, Claude e Gemini.
- **Atividades realizadas:**
  - Copiados 103 arquivos atualizados de `C:\Users\lucas\.gemini\antigravity\scratch\psx_assets_godot\assets\` para `C:\Users\lucas\joguinhos\ascdungeon3d\assets\` (e espelhados na worktree ativa):
    - 15 personagens em `assets/characters/*.glb` atualizados de 11 para **22 animações** (adicionadas: `Jump_Heavy`, `Jump_Light`, `Crouch`, `Roll_F`, `Roll_B`, `Roll_L`, `Roll_R`, `Roll_FL`, `Roll_FR`, `Roll_BL`, `Roll_BR`).
    - Prédios/props atualizados em `apothecary_medical/`, `blacksmith/`, `chapel/`, `guardhouse/`, `magic_school/`, `tavern/` e `assets/manifest.json`.
  - Executado reimport completo no Godot 4.7.2 headless (`--import`).
  - Criados `SESSION.md`, `AGENTS.md` (Codex), `CLAUDE.md` (Claude) e `GEMINI.md` (Gemini) definindo `C:\Users\lucas\joguinhos\ascdungeon3d` como fonte única de assets e o protocolo de handoff.
- **Arquivos alterados/criados:** `assets/characters/*.glb` (15), `assets/{apothecary_medical,blacksmith,chapel,guardhouse,magic_school,tavern}/*`, `assets/manifest.json`, `SESSION.md`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`.
- **Validação (Godot / testes):**
  - `Godot_v4.7.2-stable_win64.exe --headless --path C:\Users\lucas\joguinhos\ascdungeon3d --import` -> reimport concluído sem erros.
  - Script GDScript via `Godot_v4.7.2-stable_win64_console.exe --headless` -> `SUMMARY: ok=15 fail=0` (todos os 15 `.glb` em `res://assets/characters/` carregados com `AnimationPlayer` contendo exatamente 22 animações).
- **Próximos passos / Pendências:**
  - Caso o Godot Editor já estivesse aberto antes da cópia, dar foco na janela do editor (ou recarregar a cena `mundo_inicial.tscn`) para refletir os `.scn` reimportados na viewport.
  - Implementar/conectar controlador do jogador (`CharacterBody3D` / `AnimationTree` ou `AnimationPlayer`) usando as 22 animações disponíveis em `res://assets/characters/jogador.glb`.
  - Se o repositório Git precisar versionar os arquivos atuais (hoje estão untracked em `master`), fazer commit inicial estruturado com `.gitignore` revisado.
