# CLAUDE.md — Instruções para Claude (ASC Dungeon 3D)

> Este arquivo orienta o **Claude** ao trabalhar neste repositório.

## 1. Contexto Obrigatório (Leia Primeiro)
- No início de cada sessão, leia [`SESSION.md`](./SESSION.md) para entender o que foi feito por último, decisões técnicas ativas e próximos passos.

## 2. Regra de Assets (Fonte Única de Verdade)
- **Todos os assets devem ser lidos e atualizados diretamente em `C:\Users\lucas\joguinhos\ascdungeon3d\assets\`** (assim como `scenes/`, `scripts/` e `shaders/`).
- **Não** leia nem grave assets na pasta legada `C:\Users\lucas\.gemini\antigravity\scratch\psx_assets_godot`. Toda evolução de modelos, animações, texturas e cenas acontece direto neste projeto.

## 3. Godot 4.7.2 — Reimportação e Validação
- Binário Console: `C:\Users\lucas\tools\Godot\Godot_v4.7.2-stable_win64_console.exe`
- Ao atualizar `.glb`, texturas, shaders ou scripts GDScript, reimporte e verifique via Godot headless:
  ```powershell
  & "C:\Users\lucas\tools\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path "C:\Users\lucas\joguinhos\ascdungeon3d" --import
  ```
- Não altere manualmente o cache em `.godot/`.
- Os 15 personagens em `res://assets/characters/*.glb` possuem **22 animações** no `AnimationPlayer` (veja a lista completa em `SESSION.md`).

## 4. Handoff Obrigatório ao Final da Sessão
- Ao concluir qualquer tarefa no projeto, **adicione uma nova entrada no topo de `## 5. Histórico de Sessões` em [`SESSION.md`](./SESSION.md)** seguindo o template oficial, registrando alterações, validações e pendências para o próximo agente.
