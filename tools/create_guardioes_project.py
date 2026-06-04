from __future__ import annotations

import json
import math
import shutil
import subprocess
import sys
import uuid
import wave
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
PROJECT_NAME = "GuardioesDoFuturo"
PROJECT_FILE = f"{PROJECT_NAME}.yyp"
GENERATED_DIR = Path(
    r"C:\Users\User\.codex\generated_images\019e510b-68c5-7cc2-816a-e577b61bcc2a"
)
CHROMA_HELPER = Path(
    r"C:\Users\User\.codex\skills\.system\imagegen\scripts\remove_chroma_key.py"
)


ASSETS = [
    ("tile_polluted_soil", "spr_tile_polluted_soil", "tile", 64, 64),
    ("tile_recovered_soil", "spr_tile_recovered_soil", "tile", 64, 64),
    ("tile_recovering_soil", "spr_tile_recovering_soil", "tile", 64, 64),
    ("tile_polluted_water", "spr_tile_polluted_water", "tile", 64, 64),
    ("tile_clean_water", "spr_tile_clean_water", "tile", 64, 64),
    ("tile_healthy_grass", "spr_tile_healthy_grass", "tile", 64, 64),
    ("tile_dry_earth", "spr_tile_dry_earth", "tile", 64, 64),
    ("tile_forest", "spr_tile_forest", "tile", 64, 64),
    ("tile_transition", "spr_tile_transition", "tile", 64, 64),
    ("building_solar_panel", "spr_building_solar_panel", "building", 128, 128),
    ("building_wind_turbine", "spr_building_wind_turbine", "building", 128, 128),
    (
        "building_recycling_station",
        "spr_building_recycling_station",
        "building",
        128,
        128,
    ),
    (
        "building_water_purifier",
        "spr_building_water_purifier",
        "building",
        128,
        128,
    ),
    ("building_ecology_lab", "spr_building_ecology_lab", "building", 128, 128),
    (
        "building_clean_energy_station",
        "spr_building_clean_energy_station",
        "building",
        128,
        128,
    ),
    ("icon_energy", "spr_icon_energy", "icon", 64, 64),
    ("icon_water", "spr_icon_water", "icon", 64, 64),
    ("icon_biodiversity", "spr_icon_biodiversity", "icon", 64, 64),
    ("icon_pollution", "spr_icon_pollution", "icon", 64, 64),
    ("icon_social", "spr_icon_social", "icon", 64, 64),
    ("icon_alert", "spr_icon_alert", "icon", 64, 64),
    ("icon_turn", "spr_icon_turn", "icon", 64, 64),
    ("icon_resources", "spr_icon_resources", "icon", 64, 64),
    ("button_build", "spr_button_build", "button", 128, 64),
    ("button_recycle", "spr_button_recycle", "button", 128, 64),
    ("button_repair", "spr_button_repair", "button", 128, 64),
    ("button_purify", "spr_button_purify", "button", 128, 64),
    ("button_plant", "spr_button_plant", "button", 128, 64),
    ("button_scan", "spr_button_scan", "button", 128, 64),
    ("button_confirm", "spr_button_confirm", "button", 128, 64),
    ("button_cancel", "spr_button_cancel", "button", 128, 64),
    ("portrait_lira", "spr_portrait_lira", "portrait", 256, 256),
    ("portrait_theo", "spr_portrait_theo", "portrait", 256, 256),
    ("portrait_aya", "spr_portrait_aya", "portrait", 256, 256),
    ("portrait_magnus", "spr_portrait_magnus", "portrait", 256, 256),
    ("effect_toxic_smoke", "spr_effect_toxic_smoke", "effect", 128, 128),
    ("effect_ecology_glow", "spr_effect_ecology_glow", "effect", 128, 128),
    ("effect_green_particles", "spr_effect_green_particles", "effect", 128, 128),
    ("effect_clean_energy", "spr_effect_clean_energy", "effect", 128, 128),
    ("effect_toxic_spill", "spr_effect_toxic_spill", "effect", 128, 128),
    (
        "effect_water_purification",
        "spr_effect_water_purification",
        "effect",
        128,
        128,
    ),
]

SOUNDS = [
    ("snd_action", "action feedback", 0.16, [660, 880]),
    ("snd_event", "dynamic event alert", 0.22, [330, 260]),
    ("snd_success", "mission success", 0.36, [523, 659, 784]),
    ("snd_fail", "mission failure", 0.34, [392, 330, 247]),
]

OBJECTS = [
    "obj_game_controller",
    "obj_tile",
    "obj_hud",
    "obj_button_action",
    "obj_event_manager",
    "obj_dialogue_manager",
    "obj_resource_manager",
]

SCRIPTS = [
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
]

ROOMS = [
    "rm_menu",
    "rm_stage_select",
    "rm_game",
    "rm_victory",
    "rm_defeat",
    "rm_report",
]


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.replace("\n", "\r\n"), encoding="utf-8")


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def guid() -> str:
    return str(uuid.uuid4())


def run_chroma(input_path: Path, output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        sys.executable,
        str(CHROMA_HELPER),
        "--input",
        str(input_path),
        "--out",
        str(output_path),
        "--auto-key",
        "border",
        "--soft-matte",
        "--transparent-threshold",
        "12",
        "--opaque-threshold",
        "220",
        "--despill",
    ]
    subprocess.run(cmd, check=True)


def alpha_bbox(img: Image.Image):
    if img.mode != "RGBA":
        img = img.convert("RGBA")
    return img.getchannel("A").getbbox()


def fit_to_canvas(input_path: Path, output_path: Path, width: int, height: int) -> None:
    img = Image.open(input_path).convert("RGBA")
    bbox = alpha_bbox(img)
    if bbox is None:
        fitted = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    else:
        img = img.crop(bbox)
        pad = 0.92
        scale = min((width * pad) / img.width, (height * pad) / img.height)
        new_size = (
            max(1, int(round(img.width * scale))),
            max(1, int(round(img.height * scale))),
        )
        img = img.resize(new_size, Image.Resampling.LANCZOS)
        fitted = Image.new("RGBA", (width, height), (0, 0, 0, 0))
        fitted.alpha_composite(img, ((width - img.width) // 2, (height - img.height) // 2))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    fitted.save(output_path)

    validate = Image.open(output_path).convert("RGBA")
    corners = [
        validate.getpixel((0, 0))[3],
        validate.getpixel((width - 1, 0))[3],
        validate.getpixel((0, height - 1))[3],
        validate.getpixel((width - 1, height - 1))[3],
    ]
    if max(corners) != 0:
        raise RuntimeError(f"alpha validation failed for {output_path}")


def process_assets() -> dict[str, Path]:
    source_files = sorted(GENERATED_DIR.glob("*.png"), key=lambda p: p.stat().st_mtime)
    if len(source_files) != len(ASSETS):
        raise RuntimeError(
            f"expected {len(ASSETS)} imagegen PNGs, found {len(source_files)} in {GENERATED_DIR}"
        )

    source_dir = ROOT / "assets" / "imagegen_sources"
    alpha_dir = ROOT / "tmp" / "imagegen_alpha"
    final_dir = ROOT / "assets" / "generated"
    final_paths: dict[str, Path] = {}

    for src, (asset_name, _sprite_name, _kind, width, height) in zip(source_files, ASSETS):
        copied = source_dir / f"{asset_name}.png"
        copied.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, copied)
        alpha = alpha_dir / f"{asset_name}.png"
        run_chroma(copied, alpha)
        final = final_dir / f"{asset_name}.png"
        fit_to_canvas(alpha, final, width, height)
        final_paths[asset_name] = final
    return final_paths


def sprite_origin(kind: str, width: int, height: int) -> tuple[int, int, int]:
    if kind in {"tile", "button"}:
        return 0, 0, 0
    return 4, width // 2, height // 2


def sprite_resource(sprite_name: str, kind: str, width: int, height: int) -> tuple[dict, str, str]:
    frame_id = guid()
    layer_id = guid()
    key_id = guid()
    origin, xorigin, yorigin = sprite_origin(kind, width, height)
    yy = {
        "$GMSprite": "v2",
        "%Name": sprite_name,
        "bboxMode": 0,
        "bbox_bottom": height - 1,
        "bbox_left": 0,
        "bbox_right": width - 1,
        "bbox_top": 0,
        "collisionKind": 1,
        "collisionTolerance": 0,
        "DynamicTexturePage": False,
        "edgeFiltering": False,
        "For3D": False,
        "frames": [
            {
                "$GMSpriteFrame": "v1",
                "%Name": frame_id,
                "name": frame_id,
                "resourceType": "GMSpriteFrame",
                "resourceVersion": "2.0",
            }
        ],
        "gridX": 0,
        "gridY": 0,
        "height": height,
        "HTile": False,
        "layers": [
            {
                "$GMImageLayer": "",
                "%Name": layer_id,
                "blendMode": 0,
                "displayName": "default",
                "isLocked": False,
                "name": layer_id,
                "opacity": 100.0,
                "resourceType": "GMImageLayer",
                "resourceVersion": "2.0",
                "visible": True,
            }
        ],
        "name": sprite_name,
        "nineSlice": None,
        "origin": origin,
        "parent": {"name": PROJECT_NAME, "path": PROJECT_FILE},
        "preMultiplyAlpha": False,
        "resourceType": "GMSprite",
        "resourceVersion": "2.0",
        "sequence": {
            "$GMSequence": "v1",
            "%Name": sprite_name,
            "autoRecord": True,
            "backdropHeight": 768,
            "backdropImageOpacity": 0.5,
            "backdropImagePath": "",
            "backdropWidth": 1366,
            "backdropXOffset": 0.0,
            "backdropYOffset": 0.0,
            "events": {
                "$KeyframeStore<MessageEventKeyframe>": "",
                "Keyframes": [],
                "resourceType": "KeyframeStore<MessageEventKeyframe>",
                "resourceVersion": "2.0",
            },
            "eventStubScript": None,
            "eventToFunction": {},
            "length": 1.0,
            "lockOrigin": False,
            "moments": {
                "$KeyframeStore<MomentsEventKeyframe>": "",
                "Keyframes": [],
                "resourceType": "KeyframeStore<MomentsEventKeyframe>",
                "resourceVersion": "2.0",
            },
            "name": sprite_name,
            "playback": 1,
            "playbackSpeed": 30.0,
            "playbackSpeedType": 0,
            "resourceType": "GMSequence",
            "resourceVersion": "2.0",
            "seqHeight": float(height),
            "seqWidth": float(width),
            "showBackdrop": True,
            "showBackdropImage": False,
            "timeUnits": 1,
            "tracks": [
                {
                    "$GMSpriteFramesTrack": "",
                    "builtinName": 0,
                    "events": [],
                    "inheritsTrackColour": True,
                    "interpolation": 1,
                    "isCreationTrack": False,
                    "keyframes": {
                        "$KeyframeStore<SpriteFrameKeyframe>": "",
                        "Keyframes": [
                            {
                                "$Keyframe<SpriteFrameKeyframe>": "",
                                "Channels": {
                                    "0": {
                                        "$SpriteFrameKeyframe": "",
                                        "Id": {
                                            "name": frame_id,
                                            "path": f"sprites/{sprite_name}/{sprite_name}.yy",
                                        },
                                        "resourceType": "SpriteFrameKeyframe",
                                        "resourceVersion": "2.0",
                                    }
                                },
                                "Disabled": False,
                                "id": key_id,
                                "IsCreationKey": False,
                                "Key": 0.0,
                                "Length": 1.0,
                                "resourceType": "Keyframe<SpriteFrameKeyframe>",
                                "resourceVersion": "2.0",
                                "Stretch": False,
                            }
                        ],
                        "resourceType": "KeyframeStore<SpriteFrameKeyframe>",
                        "resourceVersion": "2.0",
                    },
                    "modifiers": [],
                    "name": "frames",
                    "resourceType": "GMSpriteFramesTrack",
                    "resourceVersion": "2.0",
                    "spriteId": None,
                    "trackColour": 0,
                    "tracks": [],
                    "traits": 0,
                }
            ],
            "visibleRange": None,
            "volume": 1.0,
            "xorigin": xorigin,
            "yorigin": yorigin,
        },
        "swatchColours": None,
        "swfPrecision": 0.5,
        "textureGroupId": {"name": "Default", "path": "texturegroups/Default"},
        "type": 0,
        "VTile": False,
        "width": width,
    }
    return yy, frame_id, layer_id


def create_sprites(final_paths: dict[str, Path]) -> list[str]:
    sprite_names = []
    for asset_name, sprite_name, kind, width, height in ASSETS:
        yy, frame_id, layer_id = sprite_resource(sprite_name, kind, width, height)
        sprite_dir = ROOT / "sprites" / sprite_name
        layer_dir = sprite_dir / "layers" / frame_id
        sprite_dir.mkdir(parents=True, exist_ok=True)
        layer_dir.mkdir(parents=True, exist_ok=True)
        final_img = final_paths[asset_name]
        shutil.copy2(final_img, sprite_dir / f"{frame_id}.png")
        shutil.copy2(final_img, layer_dir / f"{layer_id}.png")
        shutil.copy2(final_img, sprite_dir / f"{sprite_name}.png")
        write_json(sprite_dir / f"{sprite_name}.yy", yy)
        sprite_names.append(sprite_name)
    return sprite_names


def create_tone(path: Path, duration: float, freqs: list[int], volume: float = 0.28) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    sample_rate = 44100
    total = int(sample_rate * duration)
    segment = max(1, total // max(1, len(freqs)))
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(sample_rate)
        frames = bytearray()
        for i in range(total):
            freq = freqs[min(len(freqs) - 1, i // segment)]
            env = min(1.0, i / 900) * min(1.0, (total - i) / 1600)
            sample = math.sin((i / sample_rate) * freq * math.tau)
            value = int(max(-1, min(1, sample * env * volume)) * 32767)
            frames += value.to_bytes(2, byteorder="little", signed=True)
        wav.writeframes(bytes(frames))


def sound_resource(sound_name: str, duration: float) -> dict:
    return {
        "$GMSound": "v1",
        "%Name": sound_name,
        "conversionMode": 0,
        "compression": 0,
        "volume": 1.0,
        "preload": True,
        "bitRate": 128,
        "sampleRate": 44100,
        "type": 0,
        "bitDepth": 1,
        "audioGroupId": {
            "name": "audiogroup_default",
            "path": "audiogroups/audiogroup_default",
        },
        "soundFile": f"{sound_name}.wav",
        "duration": duration,
        "exportDir": "",
        "parent": {"name": PROJECT_NAME, "path": PROJECT_FILE},
        "resourceVersion": "1.0",
        "name": sound_name,
        "tags": [],
        "resourceType": "GMSound",
    }


def create_sounds() -> list[str]:
    sound_names = []
    for sound_name, _description, duration, freqs in SOUNDS:
        sound_dir = ROOT / "sounds" / sound_name
        create_tone(sound_dir / f"{sound_name}.wav", duration, freqs)
        write_json(sound_dir / f"{sound_name}.yy", sound_resource(sound_name, duration))
        sound_names.append(sound_name)
    return sound_names


def script_yy(script_name: str) -> dict:
    return {
        "$GMScript": "v1",
        "%Name": script_name,
        "isCompatibility": False,
        "isDnD": False,
        "name": script_name,
        "parent": {"name": PROJECT_NAME, "path": PROJECT_FILE},
        "resourceType": "GMScript",
        "resourceVersion": "2.0",
    }


def object_yy(object_name: str, events: list[tuple[int, int]]) -> dict:
    return {
        "$GMObject": "",
        "%Name": object_name,
        "eventList": [
            {
                "$GMEvent": "v1",
                "%Name": "",
                "collisionObjectId": None,
                "eventNum": event_num,
                "eventType": event_type,
                "isDnD": False,
                "name": "",
                "resourceType": "GMEvent",
                "resourceVersion": "2.0",
            }
            for event_type, event_num in events
        ],
        "managed": True,
        "name": object_name,
        "overriddenProperties": [],
        "parent": {"name": PROJECT_NAME, "path": PROJECT_FILE},
        "parentObjectId": None,
        "persistent": False,
        "physicsAngularDamping": 0.1,
        "physicsDensity": 0.5,
        "physicsFriction": 0.2,
        "physicsGroup": 1,
        "physicsKinematic": False,
        "physicsLinearDamping": 0.1,
        "physicsObject": False,
        "physicsRestitution": 0.1,
        "physicsSensor": False,
        "physicsShape": 1,
        "physicsShapePoints": [],
        "physicsStartAwake": True,
        "properties": [],
        "resourceType": "GMObject",
        "resourceVersion": "2.0",
        "solid": False,
        "spriteId": None,
        "spriteMaskId": None,
        "visible": True,
    }


def room_yy(room_name: str, controller: bool = True) -> dict:
    inst_name = f"inst_{room_name}_controller"
    instance = {
        "$GMRInstance": "v4",
        "%Name": inst_name,
        "colour": 4294967295,
        "frozen": False,
        "hasCreationCode": False,
        "ignore": False,
        "imageIndex": 0,
        "imageSpeed": 1.0,
        "inheritCode": False,
        "inheritedItemId": None,
        "inheritItemSettings": False,
        "isDnd": False,
        "name": inst_name,
        "objectId": {
            "name": "obj_game_controller",
            "path": "objects/obj_game_controller/obj_game_controller.yy",
        },
        "properties": [],
        "resourceType": "GMRInstance",
        "resourceVersion": "2.0",
        "rotation": 0.0,
        "scaleX": 1.0,
        "scaleY": 1.0,
        "x": 0.0,
        "y": 0.0,
    }
    instances = [instance] if controller else []
    return {
        "$GMRoom": "v1",
        "%Name": room_name,
        "creationCodeFile": "",
        "inheritCode": False,
        "inheritCreationOrder": False,
        "inheritLayers": False,
        "instanceCreationOrder": (
            [{"name": inst_name, "path": f"rooms/{room_name}/{room_name}.yy"}]
            if controller
            else []
        ),
        "isDnd": False,
        "layers": [
            {
                "$GMRInstanceLayer": "",
                "%Name": "Instances",
                "depth": 0,
                "effectEnabled": True,
                "effectType": None,
                "gridX": 64,
                "gridY": 64,
                "hierarchyFrozen": False,
                "inheritLayerDepth": False,
                "inheritLayerSettings": False,
                "inheritSubLayers": True,
                "inheritVisibility": True,
                "instances": instances,
                "layers": [],
                "name": "Instances",
                "properties": [],
                "resourceType": "GMRInstanceLayer",
                "resourceVersion": "2.0",
                "userdefinedDepth": False,
                "visible": True,
            },
            {
                "$GMRBackgroundLayer": "",
                "%Name": "Background",
                "animationFPS": 15.0,
                "animationSpeedType": 0,
                "colour": 4280624421,
                "depth": 100,
                "effectEnabled": True,
                "effectType": None,
                "gridX": 64,
                "gridY": 64,
                "hierarchyFrozen": False,
                "hspeed": 0.0,
                "htiled": False,
                "inheritLayerDepth": False,
                "inheritLayerSettings": False,
                "inheritSubLayers": True,
                "inheritVisibility": True,
                "layers": [],
                "name": "Background",
                "properties": [],
                "resourceType": "GMRBackgroundLayer",
                "resourceVersion": "2.0",
                "spriteId": None,
                "stretch": False,
                "userdefinedAnimFPS": False,
                "userdefinedDepth": False,
                "visible": True,
                "vspeed": 0.0,
                "vtiled": False,
                "x": 0,
                "y": 0,
            },
        ],
        "name": room_name,
        "parent": {"name": PROJECT_NAME, "path": PROJECT_FILE},
        "parentRoom": None,
        "physicsSettings": {
            "inheritPhysicsSettings": False,
            "PhysicsWorld": False,
            "PhysicsWorldGravityX": 0.0,
            "PhysicsWorldGravityY": 10.0,
            "PhysicsWorldPixToMetres": 0.1,
        },
        "resourceType": "GMRoom",
        "resourceVersion": "2.0",
        "roomSettings": {
            "Height": 720,
            "inheritRoomSettings": False,
            "persistent": False,
            "Width": 1280,
        },
        "sequenceId": None,
        "views": [
            {
                "hborder": 32,
                "hport": 720,
                "hspeed": -1,
                "hview": 720,
                "inherit": False,
                "objectId": None,
                "vborder": 32,
                "visible": False,
                "vspeed": -1,
                "wport": 1280,
                "wview": 1280,
                "xport": 0,
                "xview": 0,
                "yport": 0,
                "yview": 0,
            }
            for _ in range(8)
        ],
        "viewSettings": {
            "clearDisplayBuffer": True,
            "clearViewBackground": False,
            "enableViews": False,
            "inheritViewSettings": False,
        },
        "volume": 1.0,
    }


GML = {}

GML["scr_init_stage"] = r'''
function scr_init_stage(_stage_index) {
    with (obj_tile) instance_destroy();
    with (obj_button_action) instance_destroy();
    with (obj_hud) instance_destroy();
    with (obj_event_manager) instance_destroy();
    with (obj_dialogue_manager) instance_destroy();
    with (obj_resource_manager) instance_destroy();

    global.gdf = {};
    global.gdf.game_active = true;
    global.gdf.stage_index = _stage_index;
    global.gdf.turn = 1;
    global.gdf.max_turns = 18;
    global.gdf.energy = 38;
    global.gdf.water = 38;
    global.gdf.credits = 72;
    global.gdf.support = 62;
    global.gdf.biodiversity = 18;
    global.gdf.pollution = 72;
    global.gdf.critical_pollution = 96;
    global.gdf.target_pollution = 25;
    global.gdf.target_biodiversity = 68;
    global.gdf.target_water = 18;
    global.gdf.selected_action = "";
    global.gdf.selected_label = "";
    global.gdf.alert = "Observe o mapa, escolha uma ação e clique em um tile.";
    global.gdf.alert_timer = 240;
    global.gdf.tooltip = { text: "", x: 0, y: 0, timer: 0 };
    global.gdf.tiles = [];
    global.gdf.report_result = "";
    global.gdf.report_reason = "";
    global.gdf.report_grade = "C";
    global.gdf.report_message = "";
    global.gdf.last_event = "Nenhum evento ainda.";

    switch (_stage_index) {
        case 0:
            global.gdf.stage_name = "Fase 1 - Floresta Norte";
            global.gdf.stage_focus = "Reflorestamento e nascentes";
            global.gdf.objective = "Reduza a poluição, plante árvores e proteja a água.";
            global.gdf.education = "Árvores reduzem erosão, seguram água no solo e abrem caminho para a biodiversidade voltar.";
            global.gdf.dialogue_portrait = spr_portrait_lira;
            global.gdf.dialogue_text = "Lira: Guardião, esta floresta ainda respira. Plante nas áreas secas e limpe os focos de poluição antes que virem incêndio.";
            global.gdf.target_biodiversity = 70;
            global.gdf.target_water = 20;
            break;
        case 1:
            global.gdf.stage_name = "Fase 2 - Vale Industrial";
            global.gdf.stage_focus = "Energia limpa e reciclagem";
            global.gdf.objective = "Corte emissões instalando energia limpa e reciclagem.";
            global.gdf.education = "Transição energética e economia circular reduzem emissões sem abandonar a comunidade.";
            global.gdf.dialogue_portrait = spr_portrait_theo;
            global.gdf.dialogue_text = "Theo: O vale tem capacidade técnica. Painéis solares e reciclagem reduzem poluição sem travar a vida da cidade.";
            global.gdf.energy = 32;
            global.gdf.credits = 82;
            global.gdf.pollution = 78;
            global.gdf.target_pollution = 22;
            break;
        default:
            global.gdf.stage_name = "Fase 3 - Costa Azul";
            global.gdf.stage_focus = "Água limpa e biodiversidade marinha";
            global.gdf.objective = "Purifique a água e restaure a costa.";
            global.gdf.education = "Água limpa é infraestrutura viva: melhora saúde, pesca, biodiversidade e resiliência costeira.";
            global.gdf.dialogue_portrait = spr_portrait_aya;
            global.gdf.dialogue_text = "Aya: A costa responde rápido quando a água melhora. Priorize purificação e corredores ecológicos junto às margens.";
            global.gdf.water = 30;
            global.gdf.biodiversity = 15;
            global.gdf.target_water = 24;
            global.gdf.target_biodiversity = 72;
            break;
    }
    global.gdf.dialogue_timer = 420;

    instance_create_layer(0, 0, "Instances", obj_resource_manager);
    instance_create_layer(0, 0, "Instances", obj_event_manager);
    instance_create_layer(0, 0, "Instances", obj_dialogue_manager);
    instance_create_layer(0, 0, "Instances", obj_hud);

    var _cols = 10;
    var _rows = 7;
    var _sx = 64;
    var _sy = 94;
    for (var yy = 0; yy < _rows; yy++) {
        for (var xx = 0; xx < _cols; xx++) {
            var t = instance_create_layer(_sx + xx * 64, _sy + yy * 64, "Instances", obj_tile);
            t.grid_x = xx;
            t.grid_y = yy;
            t.tile_kind = "soil";
            t.tile_state = "polluted";
            t.building = "";
            t.scanned = false;
            t.event_effect = "";
            t.event_timer = 0;
            t.recovery = 0;
            t.pop = 0;

            if (_stage_index == 0) {
                if (yy >= 4 && xx < 4) { t.tile_kind = "dry"; }
                if ((xx + yy) mod 5 == 0) { t.tile_kind = "forest"; t.tile_state = "recovering"; t.recovery = 1; }
                if (yy == 1 && xx > 5) { t.tile_kind = "water"; t.tile_state = "polluted"; }
            } else if (_stage_index == 1) {
                if ((xx == 1 || xx == 8) && yy > 1) { t.tile_kind = "soil"; t.tile_state = "polluted"; }
                if (yy == 3 && xx > 3 && xx < 8) { t.tile_kind = "soil"; t.tile_state = "polluted"; t.building = "damaged"; }
                if ((xx + yy) mod 6 == 0) { t.tile_kind = "grass"; t.tile_state = "recovering"; }
            } else {
                if (yy <= 2) { t.tile_kind = "water"; t.tile_state = "polluted"; }
                if (yy == 3) { t.tile_kind = "dry"; t.tile_state = "recovering"; }
                if (yy > 4 && (xx mod 3 == 0)) { t.tile_kind = "grass"; t.tile_state = "recovering"; }
            }

            scr_update_tile_state(t);
            global.gdf.tiles[array_length(global.gdf.tiles)] = t;
        }
    }

    var _defs = [
        { id: "plant", label: "Plantar", sprite: spr_button_plant, icon: spr_icon_biodiversity, tip: "Plantar árvores: melhora biodiversidade e reduz poluição próxima." },
        { id: "clean", label: "Limpar", sprite: -1, icon: spr_icon_pollution, tip: "Limpar poluição: recupera um tile e reduz a poluição global." },
        { id: "solar", label: "Solar", sprite: spr_button_build, icon: spr_icon_energy, tip: "Painel solar: gera energia limpa a cada turno." },
        { id: "recycle", label: "Reciclar", sprite: spr_button_recycle, icon: spr_icon_resources, tip: "Estação de reciclagem: gera crédito verde e apoio social." },
        { id: "purify", label: "Purificar", sprite: spr_button_purify, icon: spr_icon_water, tip: "Purificar água: limpa água contaminada e estabiliza o recurso água." },
        { id: "corridor", label: "Corredor", sprite: -1, icon: spr_icon_biodiversity, tip: "Corredor ecológico: acelera a recuperação dos tiles vizinhos." },
        { id: "scan", label: "Escanear", sprite: spr_button_scan, icon: spr_icon_alert, tip: "Escanear área: revela riscos e melhora apoio social." },
        { id: "repair", label: "Reparar", sprite: spr_button_repair, icon: spr_icon_energy, tip: "Reparar estruturas: remove dano e melhora eficiência local." },
        { id: "next_turn", label: "Turno", sprite: spr_button_confirm, icon: spr_icon_turn, tip: "Confirmar e avançar para o próximo turno." },
        { id: "cancel", label: "Cancelar", sprite: spr_button_cancel, icon: spr_icon_alert, tip: "Cancelar a ação selecionada." }
    ];

    var _start = 54;
    var _gap = 8;
    for (var i = 0; i < array_length(_defs); i++) {
        var b = instance_create_layer(_start + i * (110 + _gap), 642, "Instances", obj_button_action);
        b.action_id = _defs[i].id;
        b.action_label = _defs[i].label;
        b.button_sprite = _defs[i].sprite;
        b.icon_sprite = _defs[i].icon;
        b.tooltip_text = _defs[i].tip;
        b.button_w = 110;
        b.button_h = 52;
    }

    scr_update_resources(noone);
}
'''

GML["scr_update_tile_state"] = r'''
function scr_update_tile_state(_tile) {
    if (_tile == noone || !instance_exists(_tile)) return;

    if (_tile.tile_kind == "water") {
        _tile.sprite_index = (_tile.tile_state == "recovered") ? spr_tile_clean_water : spr_tile_polluted_water;
    } else if (_tile.tile_kind == "forest") {
        _tile.sprite_index = spr_tile_forest;
    } else if (_tile.tile_kind == "grass") {
        _tile.sprite_index = spr_tile_healthy_grass;
    } else if (_tile.tile_kind == "dry") {
        _tile.sprite_index = spr_tile_dry_earth;
    } else {
        if (_tile.tile_state == "polluted") _tile.sprite_index = spr_tile_polluted_soil;
        else if (_tile.tile_state == "recovering") _tile.sprite_index = spr_tile_recovering_soil;
        else _tile.sprite_index = spr_tile_recovered_soil;
    }
    _tile.image_speed = 0;
}
'''

GML["scr_show_tooltip"] = r'''
function scr_show_tooltip(_text, _x, _y) {
    if (!variable_global_exists("gdf")) return;
    if (!variable_struct_exists(global.gdf, "tooltip")) {
        global.gdf.tooltip = { text: "", x: 0, y: 0, timer: 0 };
    }
    global.gdf.tooltip.text = _text;
    global.gdf.tooltip.x = _x;
    global.gdf.tooltip.y = _y;
    global.gdf.tooltip.timer = 3;
}
'''

GML["scr_apply_action"] = r'''
function scr_action_def(_action) {
    switch (_action) {
        case "plant": return { energy: 2, water: 2, credits: 8, support: 0, name: "Plantar árvores" };
        case "clean": return { energy: 4, water: 1, credits: 10, support: 0, name: "Limpar poluição" };
        case "solar": return { energy: 0, water: 0, credits: 20, support: 0, name: "Construir painel solar" };
        case "recycle": return { energy: 3, water: 0, credits: 18, support: 0, name: "Construir estação de reciclagem" };
        case "purify": return { energy: 5, water: 0, credits: 14, support: 0, name: "Purificar água" };
        case "corridor": return { energy: 3, water: 3, credits: 16, support: 0, name: "Criar corredor ecológico" };
        case "scan": return { energy: 1, water: 0, credits: 2, support: 0, name: "Escanear área" };
        case "repair": return { energy: 4, water: 0, credits: 12, support: 0, name: "Reparar estruturas" };
    }
    return undefined;
}

function scr_can_pay(_cost) {
    return global.gdf.energy >= _cost.energy
        && global.gdf.water >= _cost.water
        && global.gdf.credits >= _cost.credits
        && global.gdf.support >= _cost.support;
}

function scr_affect_neighbors(_tile, _recovery_gain, _pollution_drop) {
    for (var i = 0; i < array_length(global.gdf.tiles); i++) {
        var n = global.gdf.tiles[i];
        if (!instance_exists(n) || n == _tile) continue;
        var dist = abs(n.grid_x - _tile.grid_x) + abs(n.grid_y - _tile.grid_y);
        if (dist == 1) {
            n.recovery += _recovery_gain;
            if (n.tile_state == "polluted" && n.recovery >= 2) n.tile_state = "recovering";
            if (n.tile_state == "recovering" && n.recovery >= 4) n.tile_state = "recovered";
            if (n.tile_kind == "water" && n.tile_state == "recovered") n.tile_kind = "water";
            n.pop = 1;
            scr_update_tile_state(n);
        }
    }
    global.gdf.pollution = clamp(global.gdf.pollution - _pollution_drop, 0, 100);
}

function scr_apply_action(_game, _action, _tile) {
    if (!variable_global_exists("gdf")) return false;
    if (_action == "" || is_undefined(_action)) {
        global.gdf.alert = "Selecione uma ação antes de escolher um tile.";
        global.gdf.alert_timer = 120;
        return false;
    }
    if (_tile == noone || !instance_exists(_tile)) return false;

    var cost = scr_action_def(_action);
    if (is_undefined(cost)) return false;

    if (!scr_can_pay(cost)) {
        global.gdf.alert = "Recursos insuficientes para: " + cost.name;
        global.gdf.alert_timer = 150;
        return false;
    }

    global.gdf.energy -= cost.energy;
    global.gdf.water -= cost.water;
    global.gdf.credits -= cost.credits;
    global.gdf.support -= cost.support;
    _tile.scanned = true;
    _tile.pop = 1;

    switch (_action) {
        case "plant":
            if (_tile.tile_kind != "water") {
                _tile.tile_kind = "forest";
                _tile.tile_state = "recovering";
                _tile.recovery += 3;
                global.gdf.biodiversity += 8;
                global.gdf.support += 2;
                scr_affect_neighbors(_tile, 1, 5);
                _tile.event_effect = "green";
                _tile.event_timer = 45;
            }
            break;
        case "clean":
            _tile.tile_state = "recovering";
            _tile.recovery += 3;
            if (_tile.tile_kind == "water") global.gdf.water += 2;
            global.gdf.pollution -= 10;
            global.gdf.support += 1;
            _tile.event_effect = "clean";
            _tile.event_timer = 45;
            break;
        case "solar":
            if (_tile.tile_kind != "water") {
                _tile.building = "solar";
                _tile.tile_state = "recovering";
                global.gdf.energy += 10;
                global.gdf.pollution -= 4;
                _tile.event_effect = "energy";
                _tile.event_timer = 50;
            }
            break;
        case "recycle":
            if (_tile.tile_kind != "water") {
                _tile.building = "recycle";
                global.gdf.credits += 5;
                global.gdf.support += 5;
                global.gdf.pollution -= 6;
                _tile.event_effect = "green";
                _tile.event_timer = 50;
            }
            break;
        case "purify":
            if (_tile.tile_kind == "water") {
                _tile.tile_state = "recovered";
                global.gdf.water += 12;
                global.gdf.biodiversity += 4;
                global.gdf.pollution -= 7;
                _tile.event_effect = "water";
                _tile.event_timer = 55;
            } else {
                global.gdf.water += 5;
                _tile.building = "purifier";
                _tile.event_effect = "water";
                _tile.event_timer = 55;
            }
            break;
        case "corridor":
            _tile.tile_kind = (_tile.tile_kind == "water") ? "water" : "grass";
            _tile.tile_state = "recovered";
            global.gdf.biodiversity += 10;
            global.gdf.support += 2;
            scr_affect_neighbors(_tile, 2, 4);
            _tile.event_effect = "green";
            _tile.event_timer = 55;
            break;
        case "scan":
            _tile.scanned = true;
            global.gdf.support += 3;
            global.gdf.credits += 2;
            _tile.event_effect = "scan";
            _tile.event_timer = 40;
            break;
        case "repair":
            if (_tile.building == "damaged") {
                _tile.building = "lab";
                global.gdf.energy += 5;
                global.gdf.support += 5;
                global.gdf.pollution -= 3;
            } else if (_tile.building != "") {
                global.gdf.energy += 4;
                global.gdf.support += 2;
            } else {
                _tile.building = "lab";
                global.gdf.support += 2;
            }
            _tile.event_effect = "energy";
            _tile.event_timer = 45;
            break;
    }

    global.gdf.energy = clamp(global.gdf.energy, 0, 120);
    global.gdf.water = clamp(global.gdf.water, 0, 120);
    global.gdf.credits = clamp(global.gdf.credits, 0, 140);
    global.gdf.support = clamp(global.gdf.support, 0, 100);
    global.gdf.biodiversity = clamp(global.gdf.biodiversity, 0, 100);
    global.gdf.pollution = clamp(global.gdf.pollution, 0, 100);
    global.gdf.alert = cost.name + " aplicado. O ambiente reagiu imediatamente.";
    global.gdf.alert_timer = 140;
    global.gdf.selected_action = "";
    global.gdf.selected_label = "";
    audio_play_sound(snd_action, 1, false);

    scr_update_tile_state(_tile);
    scr_update_resources(_game);

    if (scr_check_victory(_game)) {
        scr_make_report("Vitória", "Metas ambientais atingidas");
        room_goto(rm_victory);
    } else {
        var defeat_reason = scr_check_defeat(_game);
        if (defeat_reason != "") {
            scr_make_report("Derrota", defeat_reason);
            room_goto(rm_defeat);
        }
    }
    return true;
}
'''

GML["scr_update_resources"] = r'''
function scr_update_resources(_game) {
    if (!variable_global_exists("gdf")) return;
    if (!variable_struct_exists(global.gdf, "tiles")) return;

    var polluted_score = 0;
    var bio_bonus = 0;
    var clean_water = 0;

    for (var i = 0; i < array_length(global.gdf.tiles); i++) {
        var t = global.gdf.tiles[i];
        if (!instance_exists(t)) continue;

        if (t.tile_state == "polluted") polluted_score += 1;
        if (t.tile_state == "recovering") polluted_score += 0.45;
        if (t.tile_kind == "forest") bio_bonus += 0.45;
        if (t.tile_kind == "grass") bio_bonus += 0.25;
        if (t.tile_kind == "water" && t.tile_state == "recovered") clean_water += 1;

        switch (t.building) {
            case "solar":
                if (global.gdf.turn > 1) global.gdf.energy += 1;
                break;
            case "recycle":
                if (global.gdf.turn > 1) {
                    global.gdf.credits += 1;
                    global.gdf.support += 0.35;
                }
                break;
            case "purifier":
                if (global.gdf.turn > 1) global.gdf.water += 1.4;
                break;
            case "lab":
                if (global.gdf.turn > 1) {
                    global.gdf.biodiversity += 0.6;
                    global.gdf.credits += 0.3;
                }
                break;
        }
    }

    var total = max(1, array_length(global.gdf.tiles));
    var map_pollution = round((polluted_score / total) * 100);
    global.gdf.pollution = clamp(round(global.gdf.pollution * 0.55 + map_pollution * 0.45), 0, 100);
    global.gdf.biodiversity = clamp(round(global.gdf.biodiversity + bio_bonus * 0.08), 0, 100);
    global.gdf.water = clamp(round(global.gdf.water + clean_water * 0.05), 0, 120);
    global.gdf.energy = clamp(round(global.gdf.energy), 0, 120);
    global.gdf.credits = clamp(round(global.gdf.credits), 0, 140);
    global.gdf.support = clamp(round(global.gdf.support), 0, 100);
}
'''

GML["scr_spawn_event"] = r'''
function scr_random_tile() {
    if (!variable_global_exists("gdf")) return noone;
    var len = array_length(global.gdf.tiles);
    if (len <= 0) return noone;
    return global.gdf.tiles[irandom(len - 1)];
}

function scr_spawn_event(_game) {
    if (!variable_global_exists("gdf")) return;
    if (random(1) > 0.72) {
        global.gdf.last_event = "Turno estável: os sistemas de restauração mantiveram ritmo.";
        return;
    }

    var event_id = irandom(6);
    var t = scr_random_tile();
    switch (event_id) {
        case 0:
            global.gdf.water -= 8;
            global.gdf.support -= 2;
            if (instance_exists(t)) { t.tile_kind = "dry"; t.tile_state = "polluted"; t.event_effect = "smoke"; t.event_timer = 60; scr_update_tile_state(t); }
            global.gdf.last_event = "Seca: a água caiu e um tile ficou seco.";
            break;
        case 1:
            global.gdf.pollution += 12;
            if (instance_exists(t)) { t.tile_state = "polluted"; t.event_effect = "spill"; t.event_timer = 70; scr_update_tile_state(t); }
            global.gdf.last_event = "Vazamento tóxico: poluição subiu em uma área crítica.";
            break;
        case 2:
            global.gdf.energy -= 8;
            global.gdf.support -= 5;
            if (instance_exists(t)) { t.building = "damaged"; t.event_effect = "alert"; t.event_timer = 70; }
            global.gdf.last_event = "Sabotagem industrial: energia e apoio social sofreram queda.";
            break;
        case 3:
            global.gdf.pollution += 8;
            global.gdf.biodiversity -= 6;
            if (instance_exists(t)) { t.tile_kind = "dry"; t.tile_state = "polluted"; t.event_effect = "smoke"; t.event_timer = 70; scr_update_tile_state(t); }
            global.gdf.last_event = "Incêndio ambiental: biodiversidade caiu, mas ainda dá para recuperar.";
            break;
        case 4:
            global.gdf.water += 10;
            global.gdf.biodiversity += 3;
            if (instance_exists(t)) { t.event_effect = "water"; t.event_timer = 60; }
            global.gdf.last_event = "Chuva positiva: água e biodiversidade ganharam fôlego.";
            break;
        case 5:
            global.gdf.support += 10;
            global.gdf.credits += 6;
            global.gdf.last_event = "Apoio comunitário: moradores enviaram crédito verde.";
            break;
        default:
            global.gdf.support += 6;
            global.gdf.pollution -= 8;
            if (instance_exists(t)) { t.recovery += 3; t.tile_state = "recovering"; t.event_effect = "green"; t.event_timer = 60; scr_update_tile_state(t); }
            global.gdf.last_event = "Mutirão ecológico: uma área recebeu recuperação acelerada.";
            break;
    }
    global.gdf.alert = global.gdf.last_event;
    global.gdf.alert_timer = 210;
    audio_play_sound(snd_event, 1, false);
}
'''

GML["scr_next_turn"] = r'''
function scr_next_turn(_game) {
    if (!variable_global_exists("gdf")) return;
    global.gdf.turn += 1;
    global.gdf.energy -= 2;
    global.gdf.water -= 1;
    global.gdf.support -= 1;

    for (var i = 0; i < array_length(global.gdf.tiles); i++) {
        var t = global.gdf.tiles[i];
        if (!instance_exists(t)) continue;
        if (t.tile_state == "recovering") {
            t.recovery += 1;
            if (t.recovery >= 4) {
                t.tile_state = "recovered";
                if (t.tile_kind == "soil") t.tile_kind = "grass";
                t.pop = 1;
            }
            scr_update_tile_state(t);
        }
    }

    scr_spawn_event(_game);
    scr_update_resources(_game);

    if (scr_check_victory(_game)) {
        scr_make_report("Vitória", "Metas ambientais atingidas");
        room_goto(rm_victory);
        return;
    }

    var defeat_reason = scr_check_defeat(_game);
    if (defeat_reason != "") {
        scr_make_report("Derrota", defeat_reason);
        room_goto(rm_defeat);
    }
}
'''

GML["scr_check_victory"] = r'''
function scr_check_victory(_game) {
    if (!variable_global_exists("gdf")) return false;
    return global.gdf.pollution <= global.gdf.target_pollution
        && global.gdf.biodiversity >= global.gdf.target_biodiversity
        && global.gdf.water >= global.gdf.target_water
        && global.gdf.support > 0;
}
'''

GML["scr_check_defeat"] = r'''
function scr_check_defeat(_game) {
    if (!variable_global_exists("gdf")) return "";
    if (global.gdf.pollution >= global.gdf.critical_pollution) return "Poluição crítica";
    if (global.gdf.water <= 0) return "Água acabou";
    if (global.gdf.energy <= 0) return "Energia acabou";
    if (global.gdf.support <= 0) return "Apoio social chegou a zero";
    if (global.gdf.turn > global.gdf.max_turns) return "Turnos acabaram";
    return "";
}
'''

GML["scr_make_report"] = r'''
function scr_make_report(_result, _reason) {
    if (!variable_global_exists("gdf")) return;
    global.gdf.report_result = _result;
    global.gdf.report_reason = _reason;

    var _score = 0;
    _score += 100 - global.gdf.pollution;
    _score += global.gdf.biodiversity;
    _score += global.gdf.water * 0.35;
    _score += global.gdf.energy * 0.25;
    _score += global.gdf.support * 0.4;
    _score -= max(0, global.gdf.turn - 10) * 2;

    if (_score >= 175) global.gdf.report_grade = "S";
    else if (_score >= 145) global.gdf.report_grade = "A";
    else if (_score >= 115) global.gdf.report_grade = "B";
    else global.gdf.report_grade = "C";

    if (_result == "Vitória") {
        audio_play_sound(snd_success, 1, false);
        global.gdf.report_message = "Missão concluída: decisões sustentáveis criaram efeitos positivos em cadeia. " + global.gdf.education;
    } else {
        audio_play_sound(snd_fail, 1, false);
        global.gdf.report_message = "Missão encerrada por risco operacional. Tente equilibrar recursos antes de focar em uma única solução. " + global.gdf.education;
    }
}
'''

GML["scr_run_self_tests"] = r'''
function scr_selftest_fail(_failures, _message) {
    _failures[array_length(_failures)] = _message;
    return _failures;
}

function scr_run_self_tests() {
    var _failures = [];

    scr_init_stage(0);
    if (!variable_global_exists("gdf")) _failures = scr_selftest_fail(_failures, "global.gdf nao foi criado");
    if (array_length(global.gdf.tiles) != 70) _failures = scr_selftest_fail(_failures, "mapa nao criou 70 tiles");

    var _land = noone;
    var _water = noone;
    for (var i = 0; i < array_length(global.gdf.tiles); i++) {
        var _tile = global.gdf.tiles[i];
        if (instance_exists(_tile)) {
            if (_land == noone && _tile.tile_kind != "water") _land = _tile;
            if (_water == noone && _tile.tile_kind == "water") _water = _tile;
        }
    }
    if (_land == noone) _failures = scr_selftest_fail(_failures, "nenhum tile terrestre encontrado");
    if (_water == noone) _failures = scr_selftest_fail(_failures, "nenhum tile de agua encontrado");

    global.gdf.energy = 100;
    global.gdf.water = 100;
    global.gdf.credits = 100;
    global.gdf.support = 80;
    global.gdf.biodiversity = 20;
    global.gdf.pollution = 70;

    if (_land != noone) {
        var _bio_before = global.gdf.biodiversity;
        if (!scr_apply_action(self, "plant", _land)) {
            _failures = scr_selftest_fail(_failures, "acao plantar retornou false");
        } else {
            if (_land.tile_kind != "forest") _failures = scr_selftest_fail(_failures, "plantar nao transformou tile em floresta");
            if (global.gdf.biodiversity <= _bio_before) _failures = scr_selftest_fail(_failures, "plantar nao aumentou biodiversidade");
        }
    }

    global.gdf.energy = 100;
    global.gdf.water = 100;
    global.gdf.credits = 100;
    global.gdf.support = 80;
    if (_water != noone) {
        if (!scr_apply_action(self, "purify", _water)) {
            _failures = scr_selftest_fail(_failures, "acao purificar retornou false");
        } else if (_water.tile_state != "recovered") {
            _failures = scr_selftest_fail(_failures, "purificar nao recuperou tile de agua");
        }
    }

    global.gdf.energy = 100;
    global.gdf.water = 100;
    global.gdf.credits = 100;
    global.gdf.support = 80;
    var _turn_before = global.gdf.turn;
    scr_next_turn(self);
    if (global.gdf.turn != _turn_before + 1) _failures = scr_selftest_fail(_failures, "scr_next_turn nao incrementou turno");

    global.gdf.pollution = 20;
    global.gdf.biodiversity = 80;
    global.gdf.water = 40;
    global.gdf.support = 20;
    if (!scr_check_victory(self)) _failures = scr_selftest_fail(_failures, "condicao de vitoria nao ativou");

    global.gdf.pollution = 97;
    var _defeat_reason = scr_check_defeat(self);
    if (_defeat_reason != "Poluição crítica") _failures = scr_selftest_fail(_failures, "derrota por poluicao critica nao ativou");

    var _status = (array_length(_failures) == 0) ? "PASS" : "FAIL";
    show_debug_message("SELFTEST_RESULT:" + _status);
    for (var d = 0; d < array_length(_failures); d++) {
        show_debug_message("SELFTEST_FAILURE:" + _failures[d]);
    }

    var _path = working_directory + "selftest_result.txt";
    var _file = file_text_open_write(_path);
    if (array_length(_failures) == 0) {
        file_text_write_string(_file, "PASS");
        file_text_writeln(_file);
    } else {
        file_text_write_string(_file, "FAIL");
        file_text_writeln(_file);
        for (var f = 0; f < array_length(_failures); f++) {
            file_text_write_string(_file, _failures[f]);
            file_text_writeln(_file);
        }
    }
    file_text_close(_file);
}
'''

GML["obj_game_controller_Create_0"] = r'''
display_set_gui_size(1280, 720);
randomize();
var _selftest = false;
for (var _param = 1; _param <= parameter_count(); _param++) {
    if (parameter_string(_param) == "--selftest") _selftest = true;
}
if (_selftest) {
    scr_run_self_tests();
    game_end();
    exit;
}
if (!variable_global_exists("gdf_stage_index")) global.gdf_stage_index = 0;
if (!variable_global_exists("gdf")) global.gdf = {};
if (room == rm_game) {
    scr_init_stage(global.gdf_stage_index);
}
'''

GML["obj_game_controller_Step_0"] = r'''
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var clicked = mouse_check_button_pressed(mb_left);

if (room == rm_menu) {
    if (clicked && point_in_rectangle(mx, my, 480, 472, 800, 532)) {
        room_goto(rm_stage_select);
    }
} else if (room == rm_stage_select) {
    if (clicked) {
        for (var i = 0; i < 3; i++) {
            var x1 = 120 + i * 360;
            var y1 = 190;
            if (point_in_rectangle(mx, my, x1, y1, x1 + 320, y1 + 350)) {
                global.gdf_stage_index = i;
                room_goto(rm_game);
            }
        }
    }
} else if (room == rm_game) {
    if (!variable_global_exists("gdf") || !variable_struct_exists(global.gdf, "game_active")) {
        scr_init_stage(global.gdf_stage_index);
    }
    if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("N"))) {
        scr_next_turn(self);
    }
    if (keyboard_check_pressed(ord("L"))) { global.gdf.selected_action = "clean"; global.gdf.selected_label = "Limpar"; }
    if (keyboard_check_pressed(ord("C"))) { global.gdf.selected_action = "corridor"; global.gdf.selected_label = "Corredor"; }
    if (clicked && my < 585) {
        var tile = instance_position(mouse_x, mouse_y, obj_tile);
        if (tile != noone) scr_apply_action(self, global.gdf.selected_action, tile);
    }
} else if (room == rm_victory || room == rm_defeat) {
    if (clicked && point_in_rectangle(mx, my, 480, 560, 800, 620)) {
        room_goto(rm_report);
    }
} else if (room == rm_report) {
    if (clicked && point_in_rectangle(mx, my, 420, 604, 620, 660)) {
        room_goto(rm_stage_select);
    }
    if (clicked && point_in_rectangle(mx, my, 660, 604, 860, 660)) {
        room_goto(rm_menu);
    }
}
'''

GML["obj_game_controller_Draw_64"] = r'''
draw_set_alpha(1);
draw_set_color(make_colour_rgb(14, 30, 38));
draw_rectangle(0, 0, 1280, 720, false);

if (room == rm_menu) {
    draw_set_color(make_colour_rgb(24, 64, 68));
    draw_rectangle(0, 520, 1280, 720, false);
    draw_sprite_ext(spr_tile_forest, 0, 112, 560, 2.2, 2.2, 0, c_white, 1);
    draw_sprite_ext(spr_tile_clean_water, 0, 250, 585, 2.0, 2.0, 0, c_white, 1);
    draw_sprite_ext(spr_building_clean_energy_station, 0, 1040, 520, 1.2, 1.2, 0, c_white, 1);
    draw_sprite_ext(spr_effect_ecology_glow, 0, 1038, 518, 1.0, 1.0, 0, c_white, 0.8);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(640, 150, "Guardiões do Futuro", 2.4, 2.4, 0);
    draw_set_color(make_colour_rgb(157, 228, 205));
    draw_text_transformed(640, 230, "Estratégia ecológica por turnos", 1.0, 1.0, 0);
    draw_set_color(make_colour_rgb(215, 244, 234));
    draw_text(640, 302, "Restaure regiões degradadas com ciência, energia limpa e decisões ambientais inteligentes.");
    draw_set_color(make_colour_rgb(40, 182, 132));
    draw_roundrect(480, 472, 800, 532, false);
    draw_set_color(c_white);
    draw_text(640, 502, "INICIAR MISSÃO");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
} else if (room == rm_stage_select) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(640, 82, "Seleção de Fase", 1.7, 1.7, 0);
    draw_set_color(make_colour_rgb(157, 228, 205));
    draw_text(640, 128, "Escolha uma região para restaurar.");

    var names = ["Floresta Norte", "Vale Industrial", "Costa Azul"];
    var focus = ["Reflorestamento", "Energia limpa", "Água e costa"];
    var icons = [spr_tile_forest, spr_building_solar_panel, spr_tile_clean_water];
    for (var i = 0; i < 3; i++) {
        var x1 = 120 + i * 360;
        draw_set_color(make_colour_rgb(28, 54, 62));
        draw_roundrect(x1, 190, x1 + 320, 540, false);
        draw_set_color(make_colour_rgb(72, 178, 150));
        draw_rectangle(x1, 190, x1 + 320, 196, false);
        draw_sprite_ext(icons[i], 0, x1 + 160, 300, 1.5, 1.5, 0, c_white, 1);
        draw_set_color(c_white);
        draw_text_transformed(x1 + 160, 405, names[i], 1.1, 1.1, 0);
        draw_set_color(make_colour_rgb(182, 230, 212));
        draw_text(x1 + 160, 450, focus[i]);
        draw_set_color(make_colour_rgb(45, 160, 130));
        draw_roundrect(x1 + 70, 488, x1 + 250, 528, false);
        draw_set_color(c_white);
        draw_text(x1 + 160, 508, "JOGAR");
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
} else if (room == rm_victory || room == rm_defeat) {
    var victory = (room == rm_victory);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_sprite_ext(victory ? spr_effect_ecology_glow : spr_effect_toxic_smoke, 0, 640, 188, 1.6, 1.6, 0, c_white, 0.9);
    draw_set_color(victory ? make_colour_rgb(158, 242, 193) : make_colour_rgb(255, 196, 140));
    draw_text_transformed(640, 300, victory ? "Missão Restaurada" : "Missão em Risco", 2.0, 2.0, 0);
    draw_set_color(c_white);
    if (variable_global_exists("gdf") && variable_struct_exists(global.gdf, "report_reason")) {
        draw_text(640, 365, global.gdf.report_reason);
    }
    draw_set_color(make_colour_rgb(40, 182, 132));
    draw_roundrect(480, 560, 800, 620, false);
    draw_set_color(c_white);
    draw_text(640, 590, "VER RELATÓRIO");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
} else if (room == rm_report) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(640, 70, "Relatório Final", 1.8, 1.8, 0);
    draw_set_color(make_colour_rgb(29, 58, 66));
    draw_roundrect(250, 130, 1030, 560, false);
    draw_set_color(make_colour_rgb(72, 178, 150));
    draw_rectangle(250, 130, 1030, 138, false);

    if (variable_global_exists("gdf")) {
        draw_set_color(c_white);
        draw_text_transformed(640, 178, global.gdf.stage_name, 1.2, 1.2, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        var lx = 345;
        var ly = 230;
        draw_set_color(make_colour_rgb(214, 244, 232));
        draw_text(lx, ly, "Resultado: " + global.gdf.report_result);
        draw_text(lx, ly + 34, "Poluição final: " + string(global.gdf.pollution));
        draw_text(lx, ly + 68, "Biodiversidade final: " + string(global.gdf.biodiversity));
        draw_text(lx, ly + 102, "Água restante: " + string(global.gdf.water));
        draw_text(lx, ly + 136, "Energia restante: " + string(global.gdf.energy));
        draw_text(lx, ly + 170, "Apoio social: " + string(global.gdf.support));
        draw_text(lx, ly + 204, "Nota da missão: " + global.gdf.report_grade);
        draw_set_color(c_white);
        draw_text_ext(610, 260, global.gdf.report_message, 26, 360);
    }
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_colour_rgb(45, 160, 130));
    draw_roundrect(420, 604, 620, 660, false);
    draw_roundrect(660, 604, 860, 660, false);
    draw_set_color(c_white);
    draw_text(520, 632, "OUTRA FASE");
    draw_text(760, 632, "MENU");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
draw_set_alpha(1);
'''

GML["obj_tile_Create_0"] = r'''
grid_x = 0;
grid_y = 0;
tile_kind = "soil";
tile_state = "polluted";
building = "";
scanned = false;
event_effect = "";
event_timer = 0;
recovery = 0;
pop = 0;
scr_update_tile_state(self);
'''

GML["obj_tile_Step_0"] = r'''
if (event_timer > 0) event_timer -= 1;
if (pop > 0) pop = max(0, pop - 0.08);

if (room == rm_game && point_in_rectangle(mouse_x, mouse_y, x, y, x + 64, y + 64)) {
    var label = "Tile " + string(grid_x + 1) + "," + string(grid_y + 1) + " | " + tile_kind + " | " + tile_state;
    if (building != "") label += " | estrutura: " + building;
    scr_show_tooltip(label, device_mouse_x_to_gui(0) + 16, device_mouse_y_to_gui(0) + 18);
}
'''

GML["obj_tile_Draw_0"] = r'''
var sx = 1 + pop * 0.05;
draw_sprite_ext(sprite_index, 0, x + 32 - 32 * sx, y + 32 - 32 * sx, sx, sx, 0, c_white, 1);

if (!scanned) {
    draw_set_alpha(0.12);
    draw_set_color(c_black);
    draw_rectangle(x, y, x + 64, y + 64, false);
    draw_set_alpha(1);
}

switch (building) {
    case "solar": draw_sprite(spr_building_solar_panel, 0, x + 32, y + 34); break;
    case "recycle": draw_sprite(spr_building_recycling_station, 0, x + 32, y + 34); break;
    case "purifier": draw_sprite(spr_building_water_purifier, 0, x + 32, y + 34); break;
    case "lab": draw_sprite(spr_building_ecology_lab, 0, x + 32, y + 34); break;
    case "damaged":
        draw_sprite(spr_building_clean_energy_station, 0, x + 32, y + 34);
        draw_sprite_ext(spr_effect_toxic_smoke, 0, x + 32, y + 24, 0.55, 0.55, 0, c_white, 0.9);
        break;
}

if (event_timer > 0) {
    var a = min(1, event_timer / 25);
    switch (event_effect) {
        case "smoke": draw_sprite_ext(spr_effect_toxic_smoke, 0, x + 32, y + 30, 0.65, 0.65, 0, c_white, a); break;
        case "spill": draw_sprite_ext(spr_effect_toxic_spill, 0, x + 32, y + 32, 0.7, 0.7, 0, c_white, a); break;
        case "green": draw_sprite_ext(spr_effect_green_particles, 0, x + 32, y + 28, 0.65, 0.65, 0, c_white, a); break;
        case "energy": draw_sprite_ext(spr_effect_clean_energy, 0, x + 32, y + 28, 0.65, 0.65, 0, c_white, a); break;
        case "water": draw_sprite_ext(spr_effect_water_purification, 0, x + 32, y + 30, 0.65, 0.65, 0, c_white, a); break;
        case "scan": draw_sprite_ext(spr_icon_alert, 0, x + 32, y + 30, 0.7, 0.7, 0, c_white, a); break;
        case "alert": draw_sprite_ext(spr_icon_alert, 0, x + 32, y + 30, 0.7, 0.7, 0, c_white, a); break;
    }
}

if (point_in_rectangle(mouse_x, mouse_y, x, y, x + 64, y + 64)) {
    draw_set_color(make_colour_rgb(255, 255, 220));
    draw_set_alpha(0.9);
    draw_rectangle(x, y, x + 64, y + 64, true);
    draw_set_alpha(1);
}
'''

GML["obj_button_action_Create_0"] = r'''
action_id = "";
action_label = "";
button_sprite = -1;
icon_sprite = -1;
tooltip_text = "";
button_w = 110;
button_h = 52;
hover = false;
'''

GML["obj_button_action_Step_0"] = r'''
if (room != rm_game || !variable_global_exists("gdf")) exit;
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
hover = point_in_rectangle(mx, my, x, y, x + button_w, y + button_h);
if (hover) scr_show_tooltip(tooltip_text, mx + 16, my - 44);

if (hover && mouse_check_button_pressed(mb_left)) {
    if (action_id == "next_turn") {
        scr_next_turn(instance_find(obj_game_controller, 0));
    } else if (action_id == "cancel") {
        global.gdf.selected_action = "";
        global.gdf.selected_label = "";
        global.gdf.alert = "Ação cancelada.";
        global.gdf.alert_timer = 80;
    } else {
        global.gdf.selected_action = action_id;
        global.gdf.selected_label = action_label;
        global.gdf.alert = "Ação selecionada: " + action_label + ". Clique em um tile.";
        global.gdf.alert_timer = 120;
    }
}
'''

GML["obj_button_action_Draw_64"] = r'''
if (room != rm_game) exit;
var selected = variable_global_exists("gdf") && global.gdf.selected_action == action_id;
var alpha = hover ? 1 : 0.88;

if (button_sprite != -1) {
    draw_sprite_ext(button_sprite, 0, x, y, button_w / 128, button_h / 64, 0, c_white, alpha);
} else {
    draw_set_alpha(alpha);
    draw_set_color(make_colour_rgb(31, 70, 78));
    draw_roundrect(x, y, x + button_w, y + button_h, false);
    draw_set_color(make_colour_rgb(73, 188, 150));
    draw_rectangle(x, y, x + button_w, y + 5, false);
    draw_set_alpha(1);
}

if (icon_sprite != -1) draw_sprite_ext(icon_sprite, 0, x + 55, y + 22, 0.42, 0.42, 0, c_white, 1);

if (selected || hover) {
    draw_set_color(selected ? make_colour_rgb(255, 244, 170) : make_colour_rgb(170, 230, 214));
    draw_set_alpha(selected ? 1 : 0.7);
    draw_rectangle(x - 2, y - 2, x + button_w + 2, y + button_h + 2, true);
    draw_set_alpha(1);
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text_transformed(x + button_w * 0.5, y + button_h - 10, action_label, 0.72, 0.72, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
'''

GML["obj_hud_Draw_64"] = r'''
if (room != rm_game || !variable_global_exists("gdf")) exit;

draw_set_alpha(0.92);
draw_set_color(make_colour_rgb(18, 38, 46));
draw_rectangle(0, 0, 1280, 82, false);
draw_rectangle(0, 598, 1280, 720, false);
draw_set_alpha(1);

var hud_x = 24;
var hud_y = 18;
var gap = 164;

var labels = ["Energia", "Água", "Bio", "Poluição", "Apoio", "Crédito", "Turno"];
var values = [global.gdf.energy, global.gdf.water, global.gdf.biodiversity, global.gdf.pollution, global.gdf.support, global.gdf.credits, string(global.gdf.turn) + "/" + string(global.gdf.max_turns)];
var icons = [spr_icon_energy, spr_icon_water, spr_icon_biodiversity, spr_icon_pollution, spr_icon_social, spr_icon_resources, spr_icon_turn];

for (var i = 0; i < array_length(labels); i++) {
    var px = hud_x + i * gap;
    draw_sprite_ext(icons[i], 0, px + 20, hud_y + 22, 0.45, 0.45, 0, c_white, 1);
    draw_set_color(make_colour_rgb(184, 226, 216));
    draw_text_transformed(px + 46, hud_y + 4, labels[i], 0.72, 0.72, 0);
    draw_set_color(c_white);
    draw_text_transformed(px + 46, hud_y + 27, string(values[i]), 0.9, 0.9, 0);
}

draw_set_alpha(0.88);
draw_set_color(make_colour_rgb(25, 56, 63));
draw_roundrect(804, 96, 1238, 208, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_text_transformed(824, 112, global.gdf.stage_name, 0.88, 0.88, 0);
draw_set_color(make_colour_rgb(186, 230, 212));
draw_text_ext(824, 144, global.gdf.objective, 22, 390);
draw_set_color(make_colour_rgb(145, 220, 194));
draw_text_transformed(824, 190, "Evento: " + global.gdf.last_event, 0.62, 0.62, 0);

if (global.gdf.selected_action != "") {
    draw_set_alpha(0.9);
    draw_set_color(make_colour_rgb(47, 132, 112));
    draw_roundrect(24, 548, 408, 586, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(40, 558, "Selecionado: " + global.gdf.selected_label + " -> clique em um tile");
}

if (global.gdf.alert_timer > 0) {
    draw_set_alpha(min(0.95, global.gdf.alert_timer / 40));
    draw_set_color(make_colour_rgb(36, 82, 74));
    draw_roundrect(426, 548, 854, 586, false);
    draw_set_color(c_white);
    draw_text_ext(444, 558, global.gdf.alert, 20, 390);
    draw_set_alpha(1);
}

if (global.gdf.tooltip.timer > 0) {
    var tx = clamp(global.gdf.tooltip.x, 12, 980);
    var ty = clamp(global.gdf.tooltip.y, 90, 560);
    draw_set_alpha(0.96);
    draw_set_color(make_colour_rgb(10, 24, 30));
    draw_roundrect(tx, ty, tx + 286, ty + 44, false);
    draw_set_alpha(1);
    draw_set_color(make_colour_rgb(218, 246, 236));
    draw_text_ext(tx + 10, ty + 9, global.gdf.tooltip.text, 18, 260);
}
'''

GML["obj_resource_manager_Step_0"] = r'''
if (!variable_global_exists("gdf")) exit;
if (variable_struct_exists(global.gdf, "alert_timer") && global.gdf.alert_timer > 0) global.gdf.alert_timer -= 1;
if (variable_struct_exists(global.gdf, "tooltip") && global.gdf.tooltip.timer > 0) global.gdf.tooltip.timer -= 1;
if (variable_struct_exists(global.gdf, "dialogue_timer") && global.gdf.dialogue_timer > 0) global.gdf.dialogue_timer -= 1;
'''

GML["obj_event_manager_Create_0"] = r'''
manager_name = "event_manager";
'''

GML["obj_dialogue_manager_Step_0"] = r'''
if (room != rm_game || !variable_global_exists("gdf")) exit;
if (global.gdf.dialogue_timer > 0 && (keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_right))) {
    global.gdf.dialogue_timer = 0;
}
'''

GML["obj_dialogue_manager_Draw_64"] = r'''
if (room != rm_game || !variable_global_exists("gdf")) exit;
if (global.gdf.dialogue_timer <= 0) exit;

draw_set_alpha(0.96);
draw_set_color(make_colour_rgb(17, 38, 46));
draw_roundrect(152, 468, 1128, 590, false);
draw_set_alpha(1);
draw_sprite_ext(global.gdf.dialogue_portrait, 0, 222, 528, 0.42, 0.42, 0, c_white, 1);
draw_set_color(c_white);
draw_text_ext(292, 502, global.gdf.dialogue_text, 26, 780);
draw_set_color(make_colour_rgb(154, 225, 202));
draw_text_transformed(292, 562, "Espaço ou botão direito para fechar", 0.62, 0.62, 0);
'''


OBJECT_EVENTS = {
    "obj_game_controller": [(0, 0), (3, 0), (8, 64)],
    "obj_tile": [(0, 0), (3, 0), (8, 0)],
    "obj_hud": [(8, 64)],
    "obj_button_action": [(0, 0), (3, 0), (8, 64)],
    "obj_event_manager": [(0, 0)],
    "obj_dialogue_manager": [(3, 0), (8, 64)],
    "obj_resource_manager": [(3, 0)],
}

EVENT_FILES = {
    (0, 0): "Create_0.gml",
    (3, 0): "Step_0.gml",
    (8, 0): "Draw_0.gml",
    (8, 64): "Draw_64.gml",
}


def create_scripts_and_objects() -> None:
    for script_name in SCRIPTS:
        script_dir = ROOT / "scripts" / script_name
        write_json(script_dir / f"{script_name}.yy", script_yy(script_name))
        write_text(script_dir / f"{script_name}.gml", GML[script_name].strip() + "\n")

    for object_name in OBJECTS:
        object_dir = ROOT / "objects" / object_name
        write_json(object_dir / f"{object_name}.yy", object_yy(object_name, OBJECT_EVENTS[object_name]))
        for event in OBJECT_EVENTS[object_name]:
            file_name = EVENT_FILES[event]
            key = f"{object_name}_{file_name[:-4]}"
            code = GML.get(key, "")
            write_text(object_dir / file_name, code.strip() + "\n")


def create_rooms() -> None:
    for room_name in ROOMS:
        room_dir = ROOT / "rooms" / room_name
        write_json(room_dir / f"{room_name}.yy", room_yy(room_name))


def create_project(sprite_names: list[str], sound_names: list[str]) -> None:
    resources = []
    for sprite_name in sprite_names:
        resources.append({"id": {"name": sprite_name, "path": f"sprites/{sprite_name}/{sprite_name}.yy"}})
    for sound_name in sound_names:
        resources.append({"id": {"name": sound_name, "path": f"sounds/{sound_name}/{sound_name}.yy"}})
    for script_name in SCRIPTS:
        resources.append({"id": {"name": script_name, "path": f"scripts/{script_name}/{script_name}.yy"}})
    for object_name in OBJECTS:
        resources.append({"id": {"name": object_name, "path": f"objects/{object_name}/{object_name}.yy"}})
    for room_name in ROOMS:
        resources.append({"id": {"name": room_name, "path": f"rooms/{room_name}/{room_name}.yy"}})

    yyp = {
        "$GMProject": "v1",
        "%Name": PROJECT_NAME,
        "AudioGroups": [
            {
                "$GMAudioGroup": "v1",
                "%Name": "audiogroup_default",
                "exportDir": "",
                "name": "audiogroup_default",
                "resourceType": "GMAudioGroup",
                "resourceVersion": "2.0",
                "targets": -1,
            }
        ],
        "configs": {"children": [], "name": "Default"},
        "defaultScriptType": 0,
        "Folders": [],
        "ForcedPrefabProjectReferences": [],
        "IncludedFiles": [],
        "isEcma": False,
        "LibraryEmitters": [],
        "MetaData": {"IDEVersion": "2024.14.4.222"},
        "name": PROJECT_NAME,
        "resources": resources,
        "resourceType": "GMProject",
        "resourceVersion": "2.0",
        "RoomOrderNodes": [
            {"roomId": {"name": room_name, "path": f"rooms/{room_name}/{room_name}.yy"}}
            for room_name in ROOMS
        ],
        "templateType": "game",
        "TextureGroups": [
            {
                "$GMTextureGroup": "",
                "%Name": "Default",
                "autocrop": True,
                "border": 2,
                "compressFormat": "bz2",
                "customOptions": "",
                "directory": "",
                "groupParent": None,
                "isScaled": True,
                "loadType": "default",
                "mipsToGenerate": 0,
                "name": "Default",
                "resourceType": "GMTextureGroup",
                "resourceVersion": "2.0",
                "targets": -1,
            }
        ],
    }
    write_json(ROOT / PROJECT_FILE, yyp)
    write_text(
        ROOT / f"{PROJECT_NAME}.resource_order",
        '{\n  "FolderOrderSettings":[],\n  "ResourceOrderSettings":[],\n}\n',
    )


def create_options() -> None:
    main_options = {
        "$GMMainOptions": "v5",
        "%Name": "Main",
        "name": "Main",
        "option_allow_instance_change": False,
        "option_audio_error_behaviour": False,
        "option_author": "Codex",
        "option_collision_compatibility": False,
        "option_copy_on_write_enabled": False,
        "option_draw_colour": 4294967295,
        "option_gameguid": guid(),
        "option_gameid": "0",
        "option_game_speed": 60,
        "option_legacy_json_parsing": False,
        "option_legacy_number_conversion": False,
        "option_legacy_other_behaviour": False,
        "option_legacy_primitive_drawing": False,
        "option_mips_for_3d_textures": False,
        "option_remove_unused_assets": True,
        "option_sci_usesci": False,
        "option_spine_licence": False,
        "option_steam_app_id": "0",
        "option_template_description": None,
        "option_template_icon": "${base_options_dir}/main/template_icon.png",
        "option_template_image": "${base_options_dir}/main/template_image.png",
        "option_window_colour": 255,
        "resourceType": "GMMainOptions",
        "resourceVersion": "2.0",
    }
    windows_options = {
        "$GMWindowsOptions": "v2",
        "%Name": "Windows",
        "name": "Windows",
        "option_windows_allow_fullscreen_switching": False,
        "option_windows_borderless": False,
        "option_windows_company_info": "Codex",
        "option_windows_copyright_info": "",
        "option_windows_copy_exe_to_dest": False,
        "option_windows_d3dswapeffectdiscard": False,
        "option_windows_description_info": "MVP educativo de estratégia ecológica",
        "option_windows_disable_sandbox": False,
        "option_windows_display_cursor": True,
        "option_windows_display_name": "Guardiões do Futuro",
        "option_windows_enable_steam": False,
        "option_windows_executable_name": "${project_name}.exe",
        "option_windows_icon": "${base_options_dir}/windows/icons/icon.ico",
        "option_windows_installer_finished": "${base_options_dir}/windows/installer/finished.bmp",
        "option_windows_installer_header": "${base_options_dir}/windows/installer/header.bmp",
        "option_windows_interpolate_pixels": True,
        "option_windows_license": "${base_options_dir}/windows/installer/license.txt",
        "option_windows_nsis_file": "${base_options_dir}/windows/installer/nsis_script.nsi",
        "option_windows_product_info": "${project_name}",
        "option_windows_resize_window": False,
        "option_windows_save_location": 0,
        "option_windows_scale": 0,
        "option_windows_sleep_margin": 10,
        "option_windows_splash_screen": "${base_options_dir}/windows/splash/splash.png",
        "option_windows_start_fullscreen": False,
        "option_windows_steam_use_alternative_launcher": False,
        "option_windows_texture_page": "2048x2048",
        "option_windows_use_raw_mouse": False,
        "option_windows_use_splash": False,
        "option_windows_version": "1.0.0.0",
        "option_windows_vsync": True,
        "resourceType": "GMWindowsOptions",
        "resourceVersion": "2.0",
    }
    write_json(ROOT / "options" / "main" / "options_main.yy", main_options)
    write_json(ROOT / "options" / "windows" / "options_windows.yy", windows_options)


def create_docs() -> None:
    asset_lines = [
        "# Guardiões do Futuro - MVP GameMaker",
        "",
        "Projeto jogável em GML para GameMaker, criado como MVP modular de estratégia, puzzle e simulação ecológica leve.",
        "",
        "## Como abrir",
        "",
        f"Abra `{PROJECT_FILE}` na IDE GameMaker.",
        "",
        "## Loop jogável",
        "",
        "1. Escolha uma das 3 regiões.",
        "2. Observe indicadores no HUD.",
        "3. Clique em uma ação e depois em um tile.",
        "4. Use o botão Turno ou a tecla Espaço/N para simular impactos.",
        "5. Alcance as metas antes dos recursos críticos acabarem.",
        "",
        "## Arquitetura",
        "",
        "- `obj_game_controller`: fluxo de telas, seleção de fase e entrada principal.",
        "- `obj_tile`: tiles do mapa e feedback visual local.",
        "- `obj_hud`: indicadores, objetivos, alertas e tooltips.",
        "- `obj_button_action`: barra de ações em até dois cliques.",
        "- `obj_event_manager`: base para eventos dinâmicos.",
        "- `obj_dialogue_manager`: tutorial e falas de personagens.",
        "- `obj_resource_manager`: timers de HUD e recursos globais.",
        "- `sounds/`: efeitos WAV procedurais leves para ação, evento, vitória e derrota.",
        "",
        "## Assets",
        "",
        "Todos os PNGs visuais foram gerados individualmente com a skill `imagegen`, salvos primeiro em `assets/imagegen_sources/`, convertidos para alpha em `tmp/imagegen_alpha/` e normalizados em `assets/generated/`.",
    ]
    write_text(ROOT / "README.md", "\n".join(asset_lines) + "\n")

    prompts = [
        "# Imagegen Prompt Set",
        "",
        "Modo usado: built-in `image_gen`, com fundo chroma-key magenta `#ff00ff` e remoção local via `remove_chroma_key.py`.",
        "",
        "Prompt base aplicado a cada asset individualmente:",
        "",
        "```text",
        "Style: Miniature Stylized Eco Realism. Visual: eco futuristic, clean sustainable technology, hopeful environmental restoration, premium indie AAA quality, high readability, cinematic lighting, soft ambient occlusion, clean silhouettes, game-ready.",
        "Requirements: perfectly flat solid #ff00ff chroma-key background, single isolated asset, centered composition, sharp detail, no text, no watermark, no showcase sheet.",
        "```",
        "",
        "Assets gerados, na ordem:",
    ]
    for asset_name, sprite_name, kind, width, height in ASSETS:
        prompts.append(f"- `{asset_name}` -> `{sprite_name}` ({kind}, {width}x{height})")
    write_text(ROOT / "docs" / "IMAGEGEN_PROMPTS.md", "\n".join(prompts) + "\n")


def clean_generated_project_dirs() -> None:
    for name in ["sprites", "sounds", "objects", "scripts", "rooms", "options", "assets", "tmp", "docs"]:
        path = ROOT / name
        if path.exists():
            shutil.rmtree(path)
    for file_name in [PROJECT_FILE, f"{PROJECT_NAME}.resource_order", "README.md"]:
        path = ROOT / file_name
        if path.exists():
            path.unlink()


def main() -> None:
    clean_generated_project_dirs()
    final_paths = process_assets()
    sprite_names = create_sprites(final_paths)
    sound_names = create_sounds()
    create_scripts_and_objects()
    create_rooms()
    create_project(sprite_names, sound_names)
    create_options()
    create_docs()
    print(f"Created {PROJECT_FILE} with {len(sprite_names)} sprites, {len(sound_names)} sounds, {len(SCRIPTS)} scripts, {len(OBJECTS)} objects.")


if __name__ == "__main__":
    main()
