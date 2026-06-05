# Guardiões do Futuro - MVP GameMaker

Projeto jogável em GML para GameMaker, criado como MVP modular de estratégia, puzzle e simulação ecológica leve.

## Como abrir

Abra `GuardioesDoFuturo.yyp` na IDE GameMaker.

## Loop jogável

1. Escolha uma das 3 regiões.
2. Observe indicadores no HUD.
3. Clique em uma ação e depois em um tile.
4. Use o botão Turno ou a tecla Espaço/N para simular impactos.
5. Alcance as metas antes dos recursos críticos acabarem.

## Arquitetura

- `obj_game_controller`: fluxo de telas, seleção de fase e entrada principal.
- `obj_tile`: tiles do mapa e feedback visual local.
- `obj_hud`: indicadores, objetivos, alertas e tooltips.
- `obj_button_action`: barra de ações em até dois cliques.
- `obj_event_manager`: base para eventos dinâmicos.
- `obj_dialogue_manager`: tutorial e falas de personagens.
- `obj_resource_manager`: timers de HUD e recursos globais.
- `sounds/`: efeitos WAV procedurais leves para ação, evento, vitória e derrota.

## Assets

Todos os PNGs visuais foram gerados individualmente com a skill `imagegen`, salvos primeiro em `assets/imagegen_sources/`, convertidos para alpha em `tmp/imagegen_alpha/` e normalizados em `assets/generated/`.

## Testes

- `python tools/run_functional_tests.py`: valida projeto, assets, sons, salas, objetos e referencias GML.
- `build/igor_run_smoke.log`: log do teste de compilacao e entrada no loop principal.
- `build/runner_selftest.log`: log do autoteste interno ativado com `--selftest`.
