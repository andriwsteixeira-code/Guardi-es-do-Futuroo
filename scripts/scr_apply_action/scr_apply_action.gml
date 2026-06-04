function scr_action_def(_action) {
    var cost = undefined;
    switch (_action) {
        case "plant": cost = { energy: 1, water: 1, credits: 4, support: 0, name: "Plantar árvores" }; break;
        case "clean": cost = { energy: 2, water: 0, credits: 5, support: 0, name: "Limpar poluição" }; break;
        case "solar": cost = { energy: 0, water: 0, credits: 10, support: 0, name: "Construir painel solar" }; break;
        case "recycle": cost = { energy: 1, water: 0, credits: 8, support: 0, name: "Construir estação de reciclagem" }; break;
        case "purify": cost = { energy: 2, water: 0, credits: 7, support: 0, name: "Purificar água" }; break;
        case "corridor": cost = { energy: 2, water: 1, credits: 9, support: 0, name: "Criar corredor ecológico" }; break;
        case "scan": cost = { energy: 0, water: 0, credits: 0, support: 0, name: "Escanear área" }; break;
        case "repair": cost = { energy: 2, water: 0, credits: 6, support: 0, name: "Reparar estruturas" }; break;
    }
    if (is_undefined(cost)) return undefined;

    if (variable_global_exists("gdf_rewards")) {
        if (global.gdf_rewards.forest_guardian && _action == "plant") {
            cost.water = max(0, cost.water - 1);
            cost.credits = max(0, cost.credits - 1);
        }
        if (global.gdf_rewards.industrial_clean && (_action == "solar" || _action == "recycle")) {
            cost.credits = max(0, cost.credits - 2);
        }
    }

    return cost;
}

function scr_can_pay(_cost) {
    return global.gdf.energy >= _cost.energy
        && global.gdf.water >= _cost.water
        && global.gdf.credits >= _cost.credits
        && global.gdf.support >= _cost.support;
}

function scr_missing_cost_text(_cost) {
    var parts = [];
    var missing_energy = max(0, _cost.energy - global.gdf.energy);
    var missing_water = max(0, _cost.water - global.gdf.water);
    var missing_credits = max(0, _cost.credits - global.gdf.credits);
    var missing_support = max(0, _cost.support - global.gdf.support);

    if (missing_energy > 0) parts[array_length(parts)] = "energia " + string(missing_energy);
    if (missing_water > 0) parts[array_length(parts)] = "água " + string(missing_water);
    if (missing_credits > 0) parts[array_length(parts)] = "crédito " + string(missing_credits);
    if (missing_support > 0) parts[array_length(parts)] = "apoio " + string(missing_support);

    if (array_length(parts) <= 0) return "Recursos suficientes.";

    var text = "Faltam: ";
    for (var i = 0; i < array_length(parts); i++) {
        if (i > 0) text += ", ";
        text += parts[i];
    }
    return text + ".";
}

function scr_action_target_error(_action, _tile) {
    switch (_action) {
        case "plant":
            if (_tile.tile_kind == "water") return "Plante apenas em terra firme.";
            break;
        case "solar":
            if (_tile.tile_kind == "water") return "Painéis solares precisam de terra firme.";
            break;
        case "recycle":
            if (_tile.tile_kind == "water") return "A estação de reciclagem precisa de terra firme.";
            break;
        case "repair":
            if (_tile.building == "") return "Escolha uma estrutura para reparar.";
            break;
    }
    return "";
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
        global.gdf.alert = "Selecione uma ação antes de escolher uma célula do mapa.";
        global.gdf.alert_timer = 120;
        return false;
    }

    if (_tile == noone || !instance_exists(_tile)) return false;

    var cost = scr_action_def(_action);
    if (is_undefined(cost)) return false;

    if (variable_struct_exists(global.gdf, "action_points") && global.gdf.action_points <= 0) {
        global.gdf.alert = "Sem jogadas neste turno. Encerre o turno para receber novas jogadas.";
        global.gdf.alert_timer = 150;
        audio_play_sound(snd_fail, 1, false);
        return false;
    }

    var target_error = scr_action_target_error(_action, _tile);
    if (target_error != "") {
        global.gdf.alert = target_error;
        global.gdf.alert_timer = 140;
        return false;
    }

    if (!scr_can_pay(cost)) {
        global.gdf.alert = "Ação bloqueada: " + cost.name + ". " + scr_missing_cost_text(cost) + " Escanear custa zero e ajuda a recuperar crédito.";
        global.gdf.alert_timer = 150;
        audio_play_sound(snd_fail, 1, false);
        return false;
    }

    var before_energy = global.gdf.energy;
    var before_water = global.gdf.water;
    var before_credits = global.gdf.credits;
    var before_support = global.gdf.support;
    var before_biodiversity = global.gdf.biodiversity;
    var before_pollution = global.gdf.pollution;

    var synergy = scr_action_synergy(_action, _tile);

    global.gdf.energy -= cost.energy;
    global.gdf.water -= cost.water;
    global.gdf.credits -= cost.credits;
    global.gdf.support -= cost.support;

    _tile.scanned = true;
    _tile.pop = 1;

    switch (_action) {
        case "plant":
            _tile.tile_kind = "forest";
            _tile.tile_state = "recovering";
            _tile.recovery += 3;
            global.gdf.biodiversity += 9;
            global.gdf.support += 3;
            scr_affect_neighbors(_tile, 1, 6);
            _tile.event_effect = "green";
            _tile.event_timer = 45;
            break;

        case "clean":
            _tile.tile_state = "recovering";
            _tile.recovery += 3;
            if (_tile.tile_kind == "water") global.gdf.water += 2;
            global.gdf.pollution -= 11;
            global.gdf.support += 2;
            _tile.event_effect = "clean";
            _tile.event_timer = 45;
            break;

        case "solar":
            _tile.building = "solar";
            _tile.tile_state = "recovering";
            global.gdf.energy += 10;
            global.gdf.support += 1;
            global.gdf.pollution -= 4;
            _tile.event_effect = "energy";
            _tile.event_timer = 50;
            break;

        case "recycle":
            _tile.building = "recycle";
            global.gdf.credits += 8;
            global.gdf.support += 6;
            global.gdf.pollution -= 7;
            _tile.event_effect = "green";
            _tile.event_timer = 50;
            break;

        case "purify":
            if (_tile.tile_kind == "water") {
                _tile.tile_state = "recovered";
                global.gdf.water += 13;
                global.gdf.biodiversity += 5;
                global.gdf.pollution -= 8;
            } else {
                global.gdf.water += 6;
                _tile.building = "purifier";
            }
            _tile.event_effect = "water";
            _tile.event_timer = 55;
            break;

        case "corridor":
            _tile.tile_kind = (_tile.tile_kind == "water") ? "water" : "grass";
            _tile.tile_state = "recovered";
            global.gdf.biodiversity += 11;
            global.gdf.support += 3;
            scr_affect_neighbors(_tile, 2, 4);
            _tile.event_effect = "green";
            _tile.event_timer = 55;
            break;

        case "scan":
            _tile.scanned = true;
            global.gdf.support += 4;
            global.gdf.credits += 6;
            global.gdf.energy += 1;
            if (variable_global_exists("gdf_rewards") && global.gdf_rewards.coastal_watch) {
                global.gdf.credits += 2;
                global.gdf.pollution -= 2;
            }
            if (variable_struct_exists(global.gdf, "pollution_threat")) {
                global.gdf.pollution_threat = max(0, global.gdf.pollution_threat - 15);
            }
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

    global.gdf.last_combo = "";
    var turn_combo = scr_register_action_play(_action);
    if (synergy > 0) {
        global.gdf.biodiversity += synergy * 2;
        global.gdf.pollution -= synergy * 2;
        global.gdf.support += min(3, synergy);
        _tile.event_timer = max(_tile.event_timer, 60);
        if (_tile.event_effect == "") _tile.event_effect = "green";
        global.gdf.last_combo = "Sinergia +" + string(synergy) + ": restauração em cadeia.";
    }

    global.gdf.energy = clamp(global.gdf.energy, 0, 120);
    global.gdf.water = clamp(global.gdf.water, 0, 120);
    global.gdf.credits = clamp(global.gdf.credits, 0, 140);
    global.gdf.support = clamp(global.gdf.support, 0, 100);
    global.gdf.biodiversity = clamp(global.gdf.biodiversity, 0, 100);
    global.gdf.pollution = clamp(global.gdf.pollution, 0, 100);

    var feedback_parts = [];
    var delta_pollution = before_pollution - global.gdf.pollution;
    var delta_bio = global.gdf.biodiversity - before_biodiversity;
    var delta_water = global.gdf.water - before_water;
    var delta_energy = global.gdf.energy - before_energy;
    var delta_credits = global.gdf.credits - before_credits;
    var delta_support = global.gdf.support - before_support;
    if (delta_pollution != 0) feedback_parts[array_length(feedback_parts)] = "Poluição " + ((delta_pollution > 0) ? "-" : "+") + string(abs(delta_pollution));
    if (delta_bio != 0) feedback_parts[array_length(feedback_parts)] = "Biodiv. " + ((delta_bio > 0) ? "+" : "-") + string(abs(delta_bio));
    if (delta_water != 0) feedback_parts[array_length(feedback_parts)] = "Água " + ((delta_water > 0) ? "+" : "-") + string(abs(delta_water));
    if (delta_energy != 0) feedback_parts[array_length(feedback_parts)] = "Energia " + ((delta_energy > 0) ? "+" : "-") + string(abs(delta_energy));
    if (delta_credits != 0) feedback_parts[array_length(feedback_parts)] = "Crédito " + ((delta_credits > 0) ? "+" : "-") + string(abs(delta_credits));
    if (delta_support != 0) feedback_parts[array_length(feedback_parts)] = "Apoio " + ((delta_support > 0) ? "+" : "-") + string(abs(delta_support));

    global.gdf.last_feedback = "";
    for (var fp = 0; fp < min(4, array_length(feedback_parts)); fp++) {
        if (fp > 0) global.gdf.last_feedback += " | ";
        global.gdf.last_feedback += feedback_parts[fp];
    }
    global.gdf.feedback_timer = 160;

    global.gdf.alert = "Ação concluída: " + cost.name + ".";
    if (turn_combo != "") {
        global.gdf.alert += " " + turn_combo;
    } else if (global.gdf.last_combo != "") {
        global.gdf.alert += " " + global.gdf.last_combo;
    } else {
        global.gdf.alert += " O ambiente reagiu imediatamente.";
    }
    global.gdf.alert += " Jogadas restantes: " + string(global.gdf.action_points) + "/" + string(global.gdf.max_action_points) + ".";
    global.gdf.alert_timer = 140;
    global.gdf.selected_action = "";
    global.gdf.selected_label = "";
    global.gdf.action_preview = "";

    audio_play_sound(snd_action, 1, false);
    scr_update_tile_state(_tile);
    scr_log_event(cost.name + ": " + global.gdf.last_feedback);

    var sabotage_text = scr_pollution_sabotage(_tile, _action);
    if (sabotage_text != "") {
        global.gdf.alert += sabotage_text;
        global.gdf.alert_timer = 230;
        scr_log_event(global.gdf.last_sabotage);
    }

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
