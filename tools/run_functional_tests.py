from __future__ import annotations

import json
import re
import sys
import wave
from collections import Counter
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]

EXPECTED_SPRITE_SIZES = {
    (64, 64): 17,
    (128, 64): 8,
    (128, 128): 12,
    (320, 210): 3,
    (256, 256): 4,
    (1280, 720): 1,
}

REQUIRED_VISUAL_SPRITES = {
    "spr_menu_background",
    "spr_stage_forest_card",
    "spr_stage_industrial_card",
    "spr_stage_coast_card",
}

REQUIRED_OBJECTS = {
    "obj_game_controller",
    "obj_tile",
    "obj_hud",
    "obj_button_action",
    "obj_event_manager",
    "obj_dialogue_manager",
    "obj_resource_manager",
}

REQUIRED_SCRIPTS = {
    "scr_apply_action",
    "scr_update_resources",
    "scr_check_victory",
    "scr_check_defeat",
    "scr_next_turn",
    "scr_spawn_event",
    "scr_update_tile_state",
    "scr_show_tooltip",
    "scr_init_stage",
    "scr_make_report",
    "scr_run_self_tests",
}

REQUIRED_ROOMS = {
    "rm_menu",
    "rm_stage_select",
    "rm_game",
    "rm_victory",
    "rm_defeat",
    "rm_report",
}

REQUIRED_SOUNDS = {
    "snd_action",
    "snd_event",
    "snd_success",
    "snd_fail",
    "snd_music_ecochip",
}

LOCAL_FUNCTIONS = {
    "scr_action_def",
    "scr_can_pay",
    "scr_missing_cost_text",
    "scr_affect_neighbors",
    "scr_random_tile",
    "scr_pollution_sabotage",
    "scr_selftest_fail",
    "scr_selftest_find_tile",
    "scr_selftest_count_tiles",
    "scr_selftest_seed_resources",
    "scr_selftest_expect_action",
    "scr_selftest_expect_invalid",
    "scr_selftest_restore_stage",
    "scr_action_target_error",
    "scr_update_audio_state",
    "scr_action_cost_text",
    "scr_action_badge_text",
    "scr_action_type",
    "scr_register_action_play",
    "scr_neighbor_synergy",
    "scr_action_synergy",
    "scr_action_preview",
    "scr_select_action",
    "scr_log_event",
}


class TestFailure(RuntimeError):
    pass


def load_json(path: Path) -> dict:
    try:
        text = path.read_text(encoding="utf-8-sig")
        text = re.sub(r",\s*([}\]])", r"\1", text)
        return json.loads(text)
    except Exception as exc:
        raise TestFailure(f"JSON invalido: {path}: {exc}") from exc


def assert_true(condition: bool, message: str) -> None:
    if not condition:
        raise TestFailure(message)


def get_resources(project: dict) -> dict[str, str]:
    resources = {}
    for item in project.get("resources", []):
        rid = item.get("id", {})
        resources[rid.get("name", "")] = rid.get("path", "")
    return resources


def test_project_file() -> tuple[dict, dict[str, str]]:
    project_path = ROOT / "GuardioesDoFuturo.yyp"
    assert_true(project_path.exists(), "GuardioesDoFuturo.yyp nao existe")
    project = load_json(project_path)
    assert_true(project.get("%Name") == "GuardioesDoFuturo", "Nome do projeto incorreto")
    resources = get_resources(project)
    assert_true(len(resources) == 74, f"Esperado 74 recursos no .yyp, encontrado {len(resources)}")

    for name, rel_path in resources.items():
        assert_true((ROOT / rel_path).exists(), f"Recurso listado nao existe: {name} -> {rel_path}")

    assert_true(REQUIRED_OBJECTS <= resources.keys(), "Objetos obrigatorios ausentes do .yyp")
    assert_true(REQUIRED_SCRIPTS <= resources.keys(), "Scripts obrigatorios ausentes do .yyp")
    assert_true(REQUIRED_ROOMS <= resources.keys(), "Salas obrigatorias ausentes do .yyp")
    assert_true(REQUIRED_SOUNDS <= resources.keys(), "Sons obrigatorios ausentes do .yyp")

    room_order = [node["roomId"]["name"] for node in project.get("RoomOrderNodes", [])]
    assert_true(room_order[0] == "rm_menu", "rm_menu precisa ser a primeira sala")
    assert_true(room_order == ["rm_menu", "rm_stage_select", "rm_game", "rm_victory", "rm_defeat", "rm_report"], "Ordem de salas inesperada")
    return project, resources


def test_assets_and_sprites(resources: dict[str, str]) -> None:
    generated = sorted((ROOT / "assets" / "generated").glob("*.png"))
    assert_true(len(generated) == 45, f"Esperado 45 PNGs finais, encontrado {len(generated)}")

    sizes = Counter()
    for path in generated:
        img = Image.open(path).convert("RGBA")
        sizes[img.size] += 1
        w, h = img.size
        if path.name != "menu_background.png":
            corners = [
                img.getpixel((0, 0))[3],
                img.getpixel((w - 1, 0))[3],
                img.getpixel((0, h - 1))[3],
                img.getpixel((w - 1, h - 1))[3],
            ]
            assert_true(max(corners) == 0, f"Cantos nao transparentes: {path}")
        assert_true(img.getchannel("A").getbbox() is not None, f"Asset vazio: {path}")
    assert_true(dict(sizes) == EXPECTED_SPRITE_SIZES, f"Tamanhos de assets inesperados: {dict(sizes)}")

    sprite_resources = {name: rel for name, rel in resources.items() if name.startswith("spr_")}
    assert_true(len(sprite_resources) == 45, f"Esperado 45 sprites, encontrado {len(sprite_resources)}")
    assert_true(REQUIRED_VISUAL_SPRITES <= sprite_resources.keys(), "Sprites de menu/seleção de fases ausentes")
    for sprite_name, rel_path in sprite_resources.items():
        yy_path = ROOT / rel_path
        data = load_json(yy_path)
        width = data.get("width")
        height = data.get("height")
        sprite_png = yy_path.parent / f"{sprite_name}.png"
        assert_true(sprite_png.exists(), f"PNG principal ausente para {sprite_name}")
        img = Image.open(sprite_png).convert("RGBA")
        assert_true(img.size == (width, height), f"Dimensao incorreta em {sprite_png}: {img.size} != {(width, height)}")

        frames = data.get("frames", [])
        layers = data.get("layers", [])
        assert_true(len(frames) == 1, f"{sprite_name} deveria ter 1 frame")
        assert_true(len(layers) == 1, f"{sprite_name} deveria ter 1 layer")
        frame_id = frames[0]["name"]
        layer_id = layers[0]["name"]
        assert_true((yy_path.parent / f"{frame_id}.png").exists(), f"Frame PNG ausente: {sprite_name}")
        assert_true((yy_path.parent / "layers" / frame_id / f"{layer_id}.png").exists(), f"Layer PNG ausente: {sprite_name}")


def test_sounds(resources: dict[str, str]) -> None:
    sound_resources = {name: rel for name, rel in resources.items() if name.startswith("snd_")}
    assert_true(set(sound_resources) == REQUIRED_SOUNDS, f"Sons inesperados: {set(sound_resources)}")
    for sound_name, rel_path in sound_resources.items():
        yy_path = ROOT / rel_path
        data = load_json(yy_path)
        wav_path = yy_path.parent / data.get("soundFile", "")
        assert_true(wav_path.exists(), f"WAV ausente: {sound_name}")
        with wave.open(str(wav_path), "rb") as wav:
            assert_true(wav.getnchannels() == 1, f"{sound_name} nao esta em mono")
            assert_true(wav.getframerate() == 44100, f"{sound_name} nao esta em 44.1 kHz")
            assert_true(wav.getnframes() > 1000, f"{sound_name} curto demais")
            if sound_name == "snd_music_ecochip":
                assert_true(wav.getsampwidth() == 2, "Musica precisa estar em PCM 16 bits")
                assert_true(wav.getnframes() >= 44100 * 24, "Musica 16 bits curta demais")
                assert_true(data.get("bitDepth") == 2, "Metadata da musica precisa indicar 16 bits")
            else:
                assert_true(wav.getsampwidth() == 1, f"{sound_name} nao esta em 8 bits")
        assert_true(data.get("audioGroupId", {}).get("name") == "audiogroup_default", f"Audio group invalido: {sound_name}")


def test_rooms_and_objects(resources: dict[str, str]) -> None:
    object_names = {name for name in resources if name.startswith("obj_")}
    for room_name in REQUIRED_ROOMS:
        data = load_json(ROOT / resources[room_name])
        found_controller = False
        for layer in data.get("layers", []):
            for inst in layer.get("instances", []):
                obj_name = inst.get("objectId", {}).get("name")
                assert_true(obj_name in object_names, f"{room_name} instancia objeto inexistente: {obj_name}")
                if obj_name == "obj_game_controller":
                    found_controller = True
        assert_true(found_controller, f"{room_name} nao possui obj_game_controller")

    event_file_map = {
        (0, 0): "Create_0.gml",
        (3, 0): "Step_0.gml",
        (8, 0): "Draw_0.gml",
        (8, 64): "Draw_64.gml",
    }
    for object_name in REQUIRED_OBJECTS:
        yy_path = ROOT / resources[object_name]
        data = load_json(yy_path)
        for event in data.get("eventList", []):
            key = (event.get("eventType"), event.get("eventNum"))
            expected = event_file_map.get(key)
            assert_true(expected is not None, f"Evento nao mapeado em {object_name}: {key}")
            assert_true((yy_path.parent / expected).exists(), f"Arquivo de evento ausente: {object_name}/{expected}")


def test_gml_references(resources: dict[str, str]) -> None:
    defined = set(resources) | LOCAL_FUNCTIONS
    gml_text = ""
    for path in list((ROOT / "scripts").glob("**/*.gml")) + list((ROOT / "objects").glob("**/*.gml")):
        gml_text += "\n" + path.read_text(encoding="utf-8")

    tokens = set(re.findall(r"\b(?:spr|snd|obj|rm|scr)_[A-Za-z0-9_]+\b", gml_text))
    missing = sorted(token for token in tokens if token not in defined)
    assert_true(not missing, "Referencias GML sem recurso/funcao definida: " + ", ".join(missing))

    for action in ["plant", "clean", "solar", "recycle", "purify", "corridor", "scan", "repair"]:
        assert_true(f'case "{action}"' in gml_text or f'id: "{action}"' in gml_text, f"Acao ausente no GML: {action}")
    controller_draw = (ROOT / "objects" / "obj_game_controller" / "Draw_64.gml").read_text(encoding="utf-8")
    controller_step = (ROOT / "objects" / "obj_game_controller" / "Step_0.gml").read_text(encoding="utf-8")
    controller_create = (ROOT / "objects" / "obj_game_controller" / "Create_0.gml").read_text(encoding="utf-8")
    hud_draw = (ROOT / "objects" / "obj_hud" / "Draw_64.gml").read_text(encoding="utf-8")
    button_step = (ROOT / "objects" / "obj_button_action" / "Step_0.gml").read_text(encoding="utf-8")
    dialogue_draw = (ROOT / "objects" / "obj_dialogue_manager" / "Draw_64.gml").read_text(encoding="utf-8")
    assert_true('font_add("Arial", 20, false, false, 32, 255)' in controller_create, "Fonte da UI precisa incluir acentos Latin-1")
    for accent_text in ["Guardiões", "MISSÃO", "OPÇÕES", "CRÉDITOS", "Relatório", "Vitória", "Poluição", "Água"]:
        assert_true(accent_text in gml_text, f"Texto acentuado ausente ou sem revisão: {accent_text}")
    for broken_text in ["MISSO", "OPES", "CRDITOS", "Relatrio", "Vitria", "Poluio", "Agua restante"]:
        assert_true(broken_text not in gml_text, f"Texto sem acento encontrado: {broken_text}")
    assert_true("if (room == rm_game) exit;" in controller_draw, "Draw GUI do menu esta cobrindo a tela de gameplay")
    assert_true(
        controller_draw.index("if (room == rm_game) exit;") < controller_draw.index("draw_rectangle(0, 0, 1280, 720, false);"),
        "Guarda de gameplay precisa vir antes do fundo cheio do menu",
    )
    for menu_text in ["OPÇÕES DE SOM", "CRÉDITOS", "SOM: LIGADO", "VOLUME"]:
        assert_true(menu_text in controller_draw, f"Texto da tela inicial ausente: {menu_text}")
    for credit_name in ["Paulo Sergio", "Andrews", "Elias", "Luís Felipe", "Gerdson", "Claudio"]:
        assert_true(credit_name in controller_draw, f"Nome ausente nos créditos: {credit_name}")
    for visual_ref in ["spr_menu_background", "spr_stage_forest_card", "spr_stage_industrial_card", "spr_stage_coast_card"]:
        assert_true(visual_ref in controller_draw, f"Visual novo ausente na interface: {visual_ref}")
    assert_true(
        "var cards = [spr_stage_forest_card, spr_stage_industrial_card, spr_stage_coast_card]" in controller_draw,
        "Cards da seleção precisam seguir a mesma ordem dos mapas jogáveis",
    )
    assert_true("var risks" in controller_draw and "var key_actions" in controller_draw, "Cards de fase precisam usar textos curtos e separados")
    assert_true('"MENU"' in controller_draw and 'room_goto(rm_menu)' in controller_step, "Botão para sair da fase e voltar ao menu ausente")
    assert_true("draw_rectangle(0, 580, 1280, 638, false)" in hud_draw, "Faixa de instrução deve terminar antes dos botões")
    assert_true("draw_rectangle(0, 580, 1280, 720, false)" not in hud_draw, "HUD não pode cobrir a área dos botões de jogada")
    assert_true("modal_open" in hud_draw and "!modal_open && global.gdf.alert_timer" in hud_draw, "Alertas devem esperar tutorial/diálogo fechar")
    assert_true("dialogue_timer" in button_step, "Botões não devem aceitar clique enquanto o diálogo estiver aberto")
    assert_true("tutorial_active" in dialogue_draw and "draw_roundrect(58, 428, 760, 556" in dialogue_draw, "Diálogo precisa ficar separado da barra de ações e do tutorial")
    assert_true("event_log" in hud_draw and "Histórico" in hud_draw, "Log compacto de eventos ausente no HUD")
    assert_true("pollution_threat" in hud_draw and "Ameaça" in hud_draw, "Barra de ameaça da Poluição ausente")
    assert_true("global.gdf.paused" in gml_text and "pause_tab" in gml_text, "Tela de pausa ausente")
    assert_true('"PAUSA"' in hud_draw and "VOLTAR AO MENU" in hud_draw, "Botão de pausa/voltar ao menu ausente")
    assert_true("Enciclop" in hud_draw and "Reflorestamento" in hud_draw and "Energia solar" in hud_draw, "Enciclopédia educativa ausente")
    assert_true("Reciclagem" in hud_draw and "Purifica" in hud_draw and "Biodiversidade" in hud_draw, "Tópicos educativos incompletos")
    assert_true("draw_roundrect(300, 594, 882, 626" in hud_draw and "draw_roundrect(900, 594, 1108, 626" in hud_draw, "Status e fila de jogadas precisam ser áreas separadas")
    assert_true("draw_sprite_ext(icon_sprite, 0, x + 21" in gml_text and "draw_text_transformed(x + 76" in gml_text, "Botões de ação precisam separar ícone e texto")
    tile_draw = (ROOT / "objects" / "obj_tile" / "Draw_0.gml").read_text(encoding="utf-8")
    assert_true("draw_sprite_ext(building_sprite" in tile_draw and "var bs = 0.36" in tile_draw, "Construções precisam ser desenhadas em escala segura no tile 64x64")
    assert_true("draw_sprite(spr_building_solar_panel" not in tile_draw, "Construção não pode ser desenhada em tamanho cheio no mapa")
    assert_true("live_pulse" in tile_draw and "spr_effect_green_particles" in tile_draw and "spr_effect_toxic_smoke" in tile_draw, "Mapa vivo com efeitos ambientais ausente")
    assert_true("hover_sound_played" in gml_text and "audio_play_sound(snd_action" in button_step, "Feedback sonoro dos botões ausente")
    for menu_mode in ['"options"', '"credits"']:
        assert_true(menu_mode in controller_step, f"Fluxo de menu ausente: {menu_mode}")
    apply_action = (ROOT / "scripts" / "scr_apply_action" / "scr_apply_action.gml").read_text(encoding="utf-8")
    assert_true("scr_action_target_error" in apply_action, "Validacao de alvo das acoes ausente")
    assert_true("ação inválida cobrou recurso" in gml_text, "Autoteste de custo indevido ausente")
    assert_true("Sinergia +" in gml_text, "Sistema de sinergia ecologica ausente")
    assert_true("resolve_income" in gml_text and "last_income_turn" in gml_text, "Renda por turno das estruturas ausente")
    assert_true("action_points" in gml_text and "max_action_points" in gml_text, "Sistema de pontos de jogada ausente")
    assert_true("stage_goal_label" in gml_text and "stage_goal_target" in gml_text, "Objetivos específicos por fase ausentes")
    assert_true("gdf_rewards" in gml_text and "report_reward" in gml_text, "Progressão e recompensas de fase ausentes")
    assert_true("report_stars" in gml_text and "Estrelas" in controller_draw, "Sistema de estrelas no relatório ausente")
    assert_true("bnames" in controller_draw and "Polui" in controller_draw and "Biodiv" in controller_draw, "Relatório visual com barras ausente")
    assert_true("Resumo da missão" in controller_draw and "Desempenho ambiental" in controller_draw, "Relatório precisa separar resumo e desempenho em quadros")
    assert_true("Mensagem educativa" in controller_draw and "draw_text_ext_transformed(598, 444" in controller_draw, "Mensagem educativa precisa ter área própria e texto reduzido")
    assert_true("string_length(report_text) > 165" in controller_draw and "draw_roundrect(580, 402, 1030, 536" in controller_draw, "Mensagem educativa precisa ter limite de tamanho e caixa alta o suficiente")
    assert_true("draw_roundrect(580, 548, 1030, 580" in controller_draw, "Recompensa precisa ficar em quadro separado")
    assert_true("last_feedback" in gml_text and "feedback_timer" in gml_text, "Feedback curto de jogadas ausente")
    assert_true("Plano Integrado" in gml_text and "turn_combo_claimed" in gml_text, "Combo de jogadas variadas ausente")
    assert_true("A Poluição contra-atacou" in gml_text and "last_sabotage" in gml_text, "Adversario Poluicao apos cada jogada ausente")
    assert_true("sabotagem: nenhum contra-ataque registrado" in gml_text, "Autoteste de sabotagem ausente")
    assert_true("Tutorial rápido" in gml_text and "tutorial_active" in gml_text, "Tutorial de gameplay ausente")
    assert_true("sem jogadas" in gml_text, "Feedback visual de jogadas esgotadas ausente")
    assert_true("scr_action_badge_text" in gml_text and "E/A/C" in gml_text, "Custos diretos nos botoes de acao ausentes")
    assert_true("Reserva de emergência" in gml_text, "Reserva anti-turno-morto ausente")
    assert_true('case "scan": cost = { energy: 0, water: 0, credits: 0' in apply_action, "Escanear precisa ter custo zero")
    assert_true("snd_music_ecochip" in gml_text, "Musica 16 bits nao integrada")
    for hotkey in ['ord("1")', 'ord("2")', 'ord("3")', 'ord("4")', 'ord("5")', 'ord("6")', 'ord("7")', 'ord("8")']:
        assert_true(hotkey in controller_step, f"Atalho de gameplay ausente: {hotkey}")
    for event_name in ["Seca", "Vazamento", "Sabotagem", "Incendio", "Chuva", "Apoio", "Mutirao"]:
        ascii_text = (
            gml_text.replace("Incêndio", "Incendio")
            .replace("Apoio comunitário", "Apoio comunitario")
            .replace("Mutirão", "Mutirao")
        )
        assert_true(event_name in ascii_text, f"Evento dinamico nao encontrado: {event_name}")


def run() -> int:
    checks = [
        ("Projeto e recursos", lambda state: state.update(zip(["project", "resources"], test_project_file()))),
        ("Assets e sprites", lambda state: test_assets_and_sprites(state["resources"])),
        ("Sons", lambda state: test_sounds(state["resources"])),
        ("Salas e objetos", lambda state: test_rooms_and_objects(state["resources"])),
        ("Referencias GML e cobertura de gameplay", lambda state: test_gml_references(state["resources"])),
    ]
    state: dict = {}
    failures: list[str] = []
    for name, fn in checks:
        try:
            fn(state)
            print(f"[PASS] {name}")
        except Exception as exc:
            failures.append(f"[FAIL] {name}: {exc}")
            print(failures[-1])
    if failures:
        print("\nResumo: FALHOU")
        return 1
    print("\nResumo: TODOS OS TESTES AUTOMATIZADOS PASSARAM")
    return 0


if __name__ == "__main__":
    sys.exit(run())
