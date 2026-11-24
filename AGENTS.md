# AGENTS.md — Instruções para Codex (ASC Dungeon 3D)

> Este arquivo orienta o **Codex** (e agentes compatíveis com o padrão `AGENTS.md`) ao trabalhar neste repositório.

## 1. Contexto Obrigatório (Leia Primeiro)
- Antes de qualquer alteração, leia [`SESSION.md`](./SESSION.md) para ver o estado atual do projeto, o histórico recente e as pendências deixadas pelo agente anterior.

## 2. Regra de Assets (Fonte Única de Verdade)
- **Leia, edite e salve todos os assets diretamente em `C:\Users\lucas\joguinhos\ascdungeon3d\assets\`** (e cenas/scripts/shaders em `scenes/`, `scripts/`, `shaders/`).
- **Não** use nem sincronize de volta para a pasta legada `C:\Users\lucas\.gemini\antigravity\scratch\psx_assets_godot`. O projeto `ascdungeon3d` é agora a única fonte oficial.

## 3. Godot 4.7.2 — Reimportação e Validação
- Binário Console: `C:\Users\lucas\tools\Godot\Godot_v4.7.2-stable_win64_console.exe`
- Sempre que modificar `.glb`, texturas, shaders ou `.tscn`, rode o reimport headless e valide:
  ```powershell
  & "C:\Users\lucas\tools\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path "C:\Users\lucas\joguinhos\ascdungeon3d" --import
  ```
- Não edite manualmente arquivos gerados dentro de `.godot/`.
- Todos os 15 personagens em `res://assets/characters/*.glb` possuem **22 animações** prontas no `AnimationPlayer` (lista completa em `SESSION.md`).

## 4. Handoff Obrigatório ao Final da Sessão
- Antes de encerrar sua resposta, **atualize [`SESSION.md`](./SESSION.md)** adicionando uma nova entrada no **topo** da seção `## 5. Histórico de Sessões` seguindo o template definido no arquivo (Objetivo, Atividades realizadas, Arquivos alterados, Validação no Godot, Próximos passos).
