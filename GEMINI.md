# GEMINI.md — Instruções para Gemini (ASC Dungeon 3D)

> Este arquivo orienta o **Gemini** (CLI / Antigravity) ao trabalhar neste repositório.

## 1. Contexto Obrigatório (Leia Primeiro)
- Antes de executar qualquer tarefa, leia [`SESSION.md`](./SESSION.md) para carregar o contexto das últimas sessões, decisões e pendências abertas.

## 2. Regra de Assets (Fonte Única de Verdade)
- **Leia, crie e atualize todos os assets diretamente em `C:\Users\lucas\joguinhos\ascdungeon3d\assets\`** (e `scenes/`, `scripts/`, `shaders/`).
- **Não** volte a gravar ou consumir assets da pasta legada `C:\Users\lucas\.gemini\antigravity\scratch\psx_assets_godot`. Caso execute geradores Python no futuro, direcione a saída diretamente para `C:\Users\lucas\joguinhos\ascdungeon3d\assets\`.

## 3. Godot 4.7.2 — Reimportação e Validação
- Binário Console: `C:\Users\lucas\tools\Godot\Godot_v4.7.2-stable_win64_console.exe`
- Sempre que modificar `.glb`, texturas, shaders ou cenas, reimporte e valide via Godot headless:
  ```powershell
  & "C:\Users\lucas\tools\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path "C:\Users\lucas\joguinhos\ascdungeon3d" --import
  ```
- Evite editar manualmente o cache `.godot/`.
- Os 15 personagens em `res://assets/characters/*.glb` contêm **22 animações** verificadas no `AnimationPlayer` (detalhes em `SESSION.md`).

## 4. Handoff Obrigatório ao Final da Sessão
- Antes de finalizar a resposta ao usuário, **registre suas atividades no topo de `## 5. Histórico de Sessões` em [`SESSION.md`](./SESSION.md)** usando o template padronizado para garantir continuidade imediata para Codex, Claude ou a próxima sessão do Gemini.
