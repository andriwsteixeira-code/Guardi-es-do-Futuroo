function scr_update_resources(_game) {
    if (!variable_global_exists("gdf")) return;
    if (!variable_struct_exists(global.gdf, "tiles")) return;

    var allow_income = variable_struct_exists(global.gdf, "resolve_income")
        && global.gdf.resolve_income
        && (!variable_struct_exists(global.gdf, "last_income_turn") || global.gdf.last_income_turn != global.gdf.turn);

    var income_energy = 0;
    var income_water = 0;
    var income_credits = 0;
    var income_support = 0;
    var income_bio = 0;
    var polluted_score = 0;
    var bio_bonus = 0;
    var clean_water = 0;
    var forest_goal = 0;
    var structure_goal = 0;

    for (var i = 0; i < array_length(global.gdf.tiles); i++) {
        var t = global.gdf.tiles[i];
        if (!instance_exists(t)) continue;

        if (t.tile_state == "polluted") polluted_score += 1;
        if (t.tile_state == "recovering") polluted_score += 0.45;
        if (t.tile_kind == "forest") bio_bonus += 0.45;
        if (t.tile_kind == "grass") bio_bonus += 0.25;
        if (t.tile_kind == "water" && t.tile_state == "recovered") clean_water += 1;
        if (t.tile_kind == "forest" && t.tile_state != "polluted") forest_goal += 1;
        if (t.building == "solar" || t.building == "recycle" || t.building == "purifier" || t.building == "lab") structure_goal += 1;

        switch (t.building) {
            case "solar":
                if (allow_income) {
                    var solar_gain = (variable_global_exists("gdf_rewards") && global.gdf_rewards.industrial_clean) ? 3 : 2;
                    global.gdf.energy += solar_gain;
                    income_energy += solar_gain;
                }
                break;
            case "recycle":
                if (allow_income) {
                    global.gdf.credits += 2;
                    global.gdf.support += 1;
                    income_credits += 2;
                    income_support += 1;
                }
                break;
            case "purifier":
                if (allow_income) { global.gdf.water += 3; income_water += 3; }
                break;
            case "lab":
                if (allow_income) {
                    global.gdf.biodiversity += 1;
                    global.gdf.credits += 1;
                    income_bio += 1;
                    income_credits += 1;
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

    if (variable_struct_exists(global.gdf, "stage_index")) {
        if (global.gdf.stage_index == 0) global.gdf.stage_goal_current = forest_goal;
        else if (global.gdf.stage_index == 1) global.gdf.stage_goal_current = structure_goal;
        else global.gdf.stage_goal_current = clean_water;
    }

    if (allow_income) {
        global.gdf.last_income_turn = global.gdf.turn;
        global.gdf.turn_income_text = "Renda do turno: +" + string(income_energy) + " energia, +" + string(income_water) + " água, +" + string(income_credits) + " crédito, +" + string(income_support) + " apoio, +" + string(income_bio) + " biodiversidade.";
        scr_log_event(global.gdf.turn_income_text);
    }

    if (variable_struct_exists(global.gdf, "resolve_income")) global.gdf.resolve_income = false;
}

function scr_log_event(_text) {
    if (!variable_global_exists("gdf")) return;
    if (!variable_struct_exists(global.gdf, "event_log")) global.gdf.event_log = [];
    if (_text == "") return;

    var line = _text;
    if (string_length(line) > 72) line = string_copy(line, 1, 69) + "...";

    var old_log = global.gdf.event_log;
    var new_log = [line];
    var limit = min(2, array_length(old_log));
    for (var i = 0; i < limit; i++) {
        new_log[array_length(new_log)] = old_log[i];
    }
    global.gdf.event_log = new_log;
}

function scr_update_audio_state() {
    if (!variable_global_exists("gdf_sound_enabled")) global.gdf_sound_enabled = true;
    if (!variable_global_exists("gdf_master_volume")) global.gdf_master_volume = 0.8;
    if (!variable_global_exists("gdf_music_instance")) global.gdf_music_instance = -1;

    audio_master_gain(global.gdf_sound_enabled ? global.gdf_master_volume : 0);

    if (global.gdf_sound_enabled) {
        if (global.gdf_music_instance == -1 || !audio_is_playing(global.gdf_music_instance)) {
            global.gdf_music_instance = audio_play_sound(snd_music_ecochip, 0, true);
        }
    } else if (global.gdf_music_instance != -1) {
        audio_stop_sound(global.gdf_music_instance);
        global.gdf_music_instance = -1;
    }
}

function scr_action_cost_text(_action) {
    var cost = scr_action_def(_action);
    if (is_undefined(cost)) return "";
    var plays = "";
    if (variable_global_exists("gdf") && variable_struct_exists(global.gdf, "action_points")) {
        plays = " | Jogadas " + string(global.gdf.action_points) + "/" + string(global.gdf.max_action_points);
    }
    return "E/A/C: " + string(cost.energy) + "/" + string(cost.water) + "/" + string(cost.credits) + plays;
}

function scr_action_badge_text(_action) {
    var cost = scr_action_def(_action);
    if (is_undefined(cost)) return "";
    return "E" + string(cost.energy) + " A" + string(cost.water) + " C" + string(cost.credits);
}

function scr_action_type(_action) {
    switch (_action) {
        case "plant":
        case "corridor":
        case "purify":
            return "ecologia";
        case "solar":
        case "recycle":
        case "repair":
            return "infraestrutura";
        case "clean":
            return "restauração";
        case "scan":
            return "análise";
    }
    return "geral";
}

function scr_register_action_play(_action) {
    if (!variable_global_exists("gdf")) return "";
    if (!variable_struct_exists(global.gdf, "action_points")) global.gdf.action_points = 3;
    if (!variable_struct_exists(global.gdf, "max_action_points")) global.gdf.max_action_points = 3;
    if (!variable_struct_exists(global.gdf, "actions_used")) global.gdf.actions_used = 0;
    if (!variable_struct_exists(global.gdf, "actions_types_this_turn")) global.gdf.actions_types_this_turn = [];
    if (!variable_struct_exists(global.gdf, "turn_combo_claimed")) global.gdf.turn_combo_claimed = false;

    global.gdf.action_points = max(0, global.gdf.action_points - 1);
    global.gdf.actions_used += 1;

    var action_type = scr_action_type(_action);
    var has_type = false;
    for (var i = 0; i < array_length(global.gdf.actions_types_this_turn); i++) {
        if (global.gdf.actions_types_this_turn[i] == action_type) has_type = true;
    }
    if (!has_type) global.gdf.actions_types_this_turn[array_length(global.gdf.actions_types_this_turn)] = action_type;

    if (!global.gdf.turn_combo_claimed && array_length(global.gdf.actions_types_this_turn) >= 3) {
        global.gdf.turn_combo_claimed = true;
        global.gdf.support += 5;
        global.gdf.credits += 6;
        global.gdf.biodiversity += 4;
        global.gdf.pollution -= 5;
        return "Plano Integrado: +5 apoio, +6 crédito, +4 biodiversidade, -5 poluição.";
    }

    return "";
}

function scr_neighbor_synergy(_tile) {
    if (_tile == noone || !instance_exists(_tile)) return 0;

    var synergy = 0;
    for (var i = 0; i < array_length(global.gdf.tiles); i++) {
        var n = global.gdf.tiles[i];
        if (!instance_exists(n) || n == _tile) continue;

        var dist = abs(n.grid_x - _tile.grid_x) + abs(n.grid_y - _tile.grid_y);
        if (dist != 1) continue;

        if (n.tile_state == "recovered") synergy += 1;
        if (n.tile_kind == "forest" || n.tile_kind == "grass") synergy += 1;
        if (n.tile_kind == "water" && n.tile_state == "recovered") synergy += 1;
        if (n.building == "lab" || n.building == "recycle" || n.building == "purifier") synergy += 1;
    }

    return clamp(synergy, 0, 4);
}

function scr_action_synergy(_action, _tile) {
    var synergy = scr_neighbor_synergy(_tile);

    if (variable_global_exists("gdf") && variable_struct_exists(global.gdf, "stage_index")) {
        if (global.gdf.stage_index == 0 && _action == "plant") synergy += 1;
        if (global.gdf.stage_index == 1 && (_action == "solar" || _action == "recycle")) synergy += 1;
        if (global.gdf.stage_index == 2 && _action == "purify") synergy += 1;
    }

    return clamp(synergy, 0, 5);
}

function scr_action_preview(_action, _tile) {
    if (_action == "" || is_undefined(_action)) return "";

    if (variable_global_exists("gdf") && variable_struct_exists(global.gdf, "action_points") && global.gdf.action_points <= 0) {
        return "Sem jogadas neste turno. Encerre o turno.";
    }

    var cost = scr_action_def(_action);
    var text = scr_action_cost_text(_action);
    if (!is_undefined(cost) && !scr_can_pay(cost)) {
        text += " | " + scr_missing_cost_text(cost);
    }

    if (_tile != noone && instance_exists(_tile)) {
        var target_error = scr_action_target_error(_action, _tile);
        if (target_error != "") return target_error;

        var synergy = scr_action_synergy(_action, _tile);
        if (synergy > 0) text += " | Sinergia +" + string(synergy);
    }

    return text;
}

function scr_select_action(_action, _label) {
    if (!variable_global_exists("gdf")) return;
    if (variable_struct_exists(global.gdf, "action_points") && global.gdf.action_points <= 0) {
        global.gdf.selected_action = "";
        global.gdf.selected_label = "";
        global.gdf.action_preview = "";
        global.gdf.alert = "Sem jogadas neste turno. Encerre o turno para continuar.";
        global.gdf.alert_timer = 150;
        audio_play_sound(snd_fail, 1, false);
        return;
    }

    var cost = scr_action_def(_action);
    if (!is_undefined(cost) && !scr_can_pay(cost)) {
        global.gdf.selected_action = "";
        global.gdf.selected_label = "";
        global.gdf.action_preview = "";
        global.gdf.alert = "Ação indisponível: " + _label + ". " + scr_missing_cost_text(cost) + " Escanear não custa recursos.";
        global.gdf.alert_timer = 160;
        audio_play_sound(snd_fail, 1, false);
        return;
    }

    global.gdf.selected_action = _action;
    global.gdf.selected_label = _label;
    global.gdf.action_preview = scr_action_preview(_action, noone);
    global.gdf.alert = "Ação selecionada: " + _label + ". Clique em uma célula do mapa. " + global.gdf.action_preview;
    global.gdf.alert_timer = 130;
    audio_play_sound(snd_action, 1, false);
}
