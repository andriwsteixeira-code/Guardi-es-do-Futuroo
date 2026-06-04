function scr_init_stage(_stage_index) {
    if (!variable_global_exists("gdf_tutorial_seen")) global.gdf_tutorial_seen = false;

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
    global.gdf.max_turns = 20;
    global.gdf.energy = 48;
    global.gdf.water = 46;
    global.gdf.credits = 88;
    global.gdf.support = 68;
    global.gdf.biodiversity = 18;
    global.gdf.pollution = 72;
    global.gdf.critical_pollution = 96;
    global.gdf.target_pollution = 25;
    global.gdf.target_biodiversity = 68;
    global.gdf.target_water = 18;
    global.gdf.selected_action = "";
    global.gdf.selected_label = "";
    global.gdf.action_preview = "";
    global.gdf.last_combo = "";
    global.gdf.max_action_points = 3;
    global.gdf.action_points = global.gdf.max_action_points;
    global.gdf.actions_used = 0;
    global.gdf.actions_types_this_turn = [];
    global.gdf.turn_combo_claimed = false;
    global.gdf.paused = false;
    global.gdf.pause_tab = "main";
    global.gdf.tutorial_active = !global.gdf_tutorial_seen;
    global.gdf.tutorial_step = 0;
    global.gdf.last_income_turn = 0;
    global.gdf.resolve_income = false;
    global.gdf.turn_income_text = "Construa estruturas para gerar renda por turno.";
    global.gdf.alert = "Observe os custos E/A/C nos botões, escolha uma ação e clique em uma célula do mapa.";
    global.gdf.alert_timer = 240;
    global.gdf.sabotage_enabled = true;
    global.gdf.last_sabotage_id = -1;
    global.gdf.last_sabotage = "A Poluição está observando suas jogadas.";
    global.gdf.next_sabotage_hint = "Escaneie áreas para reduzir o próximo contra-ataque.";
    global.gdf.pollution_threat = 35;
    global.gdf.last_feedback = "";
    global.gdf.feedback_timer = 0;
    global.gdf.event_log = [];
    global.gdf.stage_goal_label = "";
    global.gdf.stage_goal_current = 0;
    global.gdf.stage_goal_target = 1;
    global.gdf.tooltip = { text: "", x: 0, y: 0, timer: 0 };
    global.gdf.tiles = [];
    global.gdf.report_result = "";
    global.gdf.report_reason = "";
    global.gdf.report_grade = "C";
    global.gdf.report_stars = 0;
    global.gdf.report_message = "";
    global.gdf.report_reward = "";
    global.gdf.last_event = "Nenhum evento ainda.";

    switch (_stage_index) {
        case 0:
            global.gdf.stage_name = "Fase 1 - Floresta Norte";
            global.gdf.stage_focus = "Reflorestamento e nascentes";
            global.gdf.objective = "Reduza a poluição, plante árvores e mantenha a água estável.";
            global.gdf.education = "As árvores reduzem a erosão, retêm água no solo e abrem caminho para a biodiversidade voltar.";
            global.gdf.dialogue_portrait = spr_portrait_lira;
            global.gdf.dialogue_text = "Lira: Guardião, esta floresta ainda respira. Plante nas áreas secas e limpe os focos de poluição antes que se transformem em incêndios.";
            global.gdf.target_biodiversity = 70;
            global.gdf.target_water = 20;
            global.gdf.stage_goal_label = "Florestas recuperadas";
            global.gdf.stage_goal_target = 6;
            break;
        case 1:
            global.gdf.stage_name = "Fase 2 - Vale Industrial";
            global.gdf.stage_focus = "Energia limpa e reciclagem";
            global.gdf.objective = "Reduza emissões com energia limpa e reciclagem.";
            global.gdf.education = "A transição energética e a economia circular reduzem emissões sem abandonar a comunidade.";
            global.gdf.dialogue_portrait = spr_portrait_theo;
            global.gdf.dialogue_text = "Theo: O vale tem capacidade técnica. Painéis solares e reciclagem reduzem a poluição sem travar a vida da cidade.";
            global.gdf.energy = 42;
            global.gdf.credits = 96;
            global.gdf.pollution = 78;
            global.gdf.target_pollution = 22;
            global.gdf.stage_goal_label = "Estruturas limpas";
            global.gdf.stage_goal_target = 3;
            break;
        default:
            global.gdf.stage_name = "Fase 3 - Costa Azul";
            global.gdf.stage_focus = "Água limpa e biodiversidade marinha";
            global.gdf.objective = "Purifique a água e restaure a costa.";
            global.gdf.education = "A água limpa é infraestrutura viva: melhora a saúde, a pesca, a biodiversidade e a resiliência costeira.";
            global.gdf.dialogue_portrait = spr_portrait_aya;
            global.gdf.dialogue_text = "Aya: A costa responde rápido quando a água melhora. Priorize a purificação e os corredores ecológicos junto às margens.";
            global.gdf.water = 38;
            global.gdf.biodiversity = 15;
            global.gdf.target_water = 24;
            global.gdf.target_biodiversity = 72;
            global.gdf.stage_goal_label = "Águas purificadas";
            global.gdf.stage_goal_target = 5;
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
        { id: "plant", label: "Plantar", sprite: -1, icon: spr_icon_biodiversity, tip: "Plantar árvores: aumenta biodiversidade e reduz poluição próxima." },
        { id: "clean", label: "Limpar", sprite: -1, icon: spr_icon_pollution, tip: "Limpar poluição: recupera a célula e reduz a poluição global." },
        { id: "solar", label: "Solar", sprite: -1, icon: spr_icon_energy, tip: "Painel solar: gera energia limpa nos próximos turnos." },
        { id: "recycle", label: "Reciclar", sprite: -1, icon: spr_icon_resources, tip: "Estação de reciclagem: gera crédito verde e apoio social." },
        { id: "purify", label: "Purificar", sprite: -1, icon: spr_icon_water, tip: "Purificar água: limpa a água contaminada e estabiliza esse recurso." },
        { id: "corridor", label: "Corredor", sprite: -1, icon: spr_icon_biodiversity, tip: "Corredor ecológico: acelera a recuperação das células vizinhas." },
        { id: "scan", label: "Escanear", sprite: -1, icon: spr_icon_alert, tip: "Escanear área: custa zero, revela riscos e recupera crédito." },
        { id: "repair", label: "Reparar", sprite: -1, icon: spr_icon_energy, tip: "Reparar estruturas: remove dano e melhora eficiência local." },
        { id: "next_turn", label: "Encerrar", sprite: -1, icon: spr_icon_turn, tip: "Encerrar rodada: eventos acontecem e as jogadas voltam." },
        { id: "cancel", label: "Cancelar", sprite: -1, icon: spr_icon_alert, tip: "Cancelar a ação selecionada." }
    ];

    var _start = 28;
    var _gap = 6;
    for (var i = 0; i < array_length(_defs); i++) {
        var b = instance_create_layer(_start + i * (116 + _gap), 650, "Instances", obj_button_action);
        b.action_id = _defs[i].id;
        b.action_label = _defs[i].label;
        b.button_sprite = _defs[i].sprite;
        b.icon_sprite = _defs[i].icon;
        b.tooltip_text = _defs[i].tip;
        b.button_w = 116;
        b.button_h = 58;
    }

    scr_update_resources(noone);
    scr_log_event("Missão iniciada: " + global.gdf.stage_name + ".");
}
