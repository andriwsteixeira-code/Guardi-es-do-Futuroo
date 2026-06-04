function scr_next_turn(_game) {
    if (!variable_global_exists("gdf")) return;

    global.gdf.turn += 1;
    global.gdf.action_points = global.gdf.max_action_points;
    global.gdf.actions_used = 0;
    global.gdf.actions_types_this_turn = [];
    global.gdf.turn_combo_claimed = false;
    global.gdf.selected_action = "";
    global.gdf.selected_label = "";
    global.gdf.action_preview = "";

    global.gdf.energy -= 1;
    global.gdf.water -= 1;
    if ((global.gdf.turn mod 3) == 0) global.gdf.support -= 1;

    global.gdf.resolve_income = true;

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

    var reserve = [];
    if (global.gdf.energy > 0 && global.gdf.energy < 4) {
        global.gdf.energy += 5;
        reserve[array_length(reserve)] = "+5 energia";
    }
    if (global.gdf.water > 0 && global.gdf.water < 4) {
        global.gdf.water += 5;
        reserve[array_length(reserve)] = "+5 água";
    }
    if (global.gdf.credits < 6) {
        global.gdf.credits += 8;
        reserve[array_length(reserve)] = "+8 crédito";
    }
    if (global.gdf.support > 0 && global.gdf.support < 5) {
        global.gdf.support += 4;
        reserve[array_length(reserve)] = "+4 apoio";
    }

    global.gdf.energy = clamp(global.gdf.energy, 0, 120);
    global.gdf.water = clamp(global.gdf.water, 0, 120);
    global.gdf.credits = clamp(global.gdf.credits, 0, 140);
    global.gdf.support = clamp(global.gdf.support, 0, 100);

    var reserve_text = "";
    if (array_length(reserve) > 0) {
        reserve_text = " Reserva de emergência: ";
        for (var r = 0; r < array_length(reserve); r++) {
            if (r > 0) reserve_text += ", ";
            reserve_text += reserve[r];
        }
        reserve_text += ".";
    }

    global.gdf.alert = "Turno " + string(global.gdf.turn) + ": 3 jogadas disponíveis. " + global.gdf.last_event + reserve_text;
    global.gdf.alert_timer = 220;
    if (variable_struct_exists(global.gdf, "pollution_threat")) {
        global.gdf.pollution_threat = max(10, global.gdf.pollution_threat - 4);
    }
    scr_log_event("Turno " + string(global.gdf.turn) + ": jogadas renovadas.");

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
