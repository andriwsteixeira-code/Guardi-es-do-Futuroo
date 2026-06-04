function scr_selftest_fail(_failures, _message) {
    _failures[array_length(_failures)] = _message;
    return _failures;
}

function scr_selftest_find_tile(_kind, _state, _building) {
    for (var i = 0; i < array_length(global.gdf.tiles); i++) {
        var _tile = global.gdf.tiles[i];
        if (!instance_exists(_tile)) continue;
        if (_kind != "" && _tile.tile_kind != _kind) continue;
        if (_state != "" && _tile.tile_state != _state) continue;
        if (_building != "" && _tile.building != _building) continue;
        return _tile;
    }
    return noone;
}

function scr_selftest_count_tiles(_kind, _state, _building) {
    var _count = 0;
    for (var i = 0; i < array_length(global.gdf.tiles); i++) {
        var _tile = global.gdf.tiles[i];
        if (!instance_exists(_tile)) continue;
        if (_kind != "" && _tile.tile_kind != _kind) continue;
        if (_state != "" && _tile.tile_state != _state) continue;
        if (_building != "" && _tile.building != _building) continue;
        _count += 1;
    }
    return _count;
}

function scr_selftest_seed_resources() {
    global.gdf.energy = 100;
    global.gdf.water = 100;
    global.gdf.credits = 100;
    global.gdf.support = 80;
    global.gdf.biodiversity = 12;
    global.gdf.pollution = 80;
    global.gdf.target_pollution = -1;
    global.gdf.target_biodiversity = 101;
    global.gdf.critical_pollution = 999;
    global.gdf.max_turns = 99;
    global.gdf.last_income_turn = 0;
    global.gdf.resolve_income = false;
    global.gdf.turn_income_text = "";
    global.gdf.last_combo = "";
    global.gdf.action_preview = "";
    global.gdf.max_action_points = 99;
    global.gdf.action_points = 99;
    global.gdf.actions_used = 0;
    global.gdf.actions_types_this_turn = [];
    global.gdf.turn_combo_claimed = false;
    global.gdf.sabotage_enabled = false;
    global.gdf.last_sabotage_id = -1;
    global.gdf.last_sabotage = "";
    global.gdf.event_log = [];
    global.gdf.last_feedback = "";
    global.gdf.feedback_timer = 0;
    global.gdf.pollution_threat = 35;
}

function scr_selftest_expect_action(_failures, _stage, _action, _kind, _building, _message) {
    scr_init_stage(_stage);
    scr_selftest_seed_resources();
    var _tile = scr_selftest_find_tile(_kind, "", _building);
    if (_tile == noone && _building == "damaged") {
        _tile = scr_selftest_find_tile("soil", "", "");
        if (_tile != noone) _tile.building = "damaged";
    }
    if (_tile == noone) {
        _failures = scr_selftest_fail(_failures, _message + ": tile alvo ausente");
        return _failures;
    }

    var _before_pollution = global.gdf.pollution;
    var _before_bio = global.gdf.biodiversity;
    var _before_turn = global.gdf.turn;
    if (!scr_apply_action(self, _action, _tile)) {
        _failures = scr_selftest_fail(_failures, _message + ": ação retornou false");
        return _failures;
    }
    if (global.gdf.turn != _before_turn) _failures = scr_selftest_fail(_failures, _message + ": ação mudou turno indevidamente");

    switch (_action) {
        case "plant":
            if (_tile.tile_kind != "forest") _failures = scr_selftest_fail(_failures, _message + ": plantar não criou floresta");
            if (global.gdf.biodiversity <= _before_bio) _failures = scr_selftest_fail(_failures, _message + ": plantar não aumentou biodiversidade");
            break;
        case "clean":
            if (_tile.tile_state == "polluted") _failures = scr_selftest_fail(_failures, _message + ": limpar não alterou estado do tile");
            if (global.gdf.pollution >= _before_pollution) _failures = scr_selftest_fail(_failures, _message + ": limpar não reduziu poluição");
            break;
        case "solar":
            if (_tile.building != "solar") _failures = scr_selftest_fail(_failures, _message + ": solar não criou estrutura");
            break;
        case "recycle":
            if (_tile.building != "recycle") _failures = scr_selftest_fail(_failures, _message + ": reciclagem não criou estrutura");
            break;
        case "purify":
            if (_tile.tile_kind == "water" && _tile.tile_state != "recovered") _failures = scr_selftest_fail(_failures, _message + ": purificar não recuperou água");
            if (_tile.tile_kind != "water" && _tile.building != "purifier") _failures = scr_selftest_fail(_failures, _message + ": purificar em terra não criou purificador");
            break;
        case "corridor":
            if (_tile.tile_state != "recovered") _failures = scr_selftest_fail(_failures, _message + ": corredor não recuperou tile");
            break;
        case "scan":
            if (!_tile.scanned) _failures = scr_selftest_fail(_failures, _message + ": escanear não marcou tile");
            break;
        case "repair":
            if (_tile.building == "damaged") _failures = scr_selftest_fail(_failures, _message + ": reparar não removeu dano");
            break;
    }
    return _failures;
}

function scr_selftest_expect_invalid(_failures, _stage, _action, _kind, _building, _message) {
    scr_init_stage(_stage);
    scr_selftest_seed_resources();
    var _tile = scr_selftest_find_tile(_kind, "", _building);
    if (_tile == noone) {
        _failures = scr_selftest_fail(_failures, _message + ": tile alvo ausente");
        return _failures;
    }

    var _energy = global.gdf.energy;
    var _water = global.gdf.water;
    var _credits = global.gdf.credits;
    var _support = global.gdf.support;
    var _result = scr_apply_action(self, _action, _tile);
    if (_result) _failures = scr_selftest_fail(_failures, _message + ": ação inválida retornou true");
    if (global.gdf.energy != _energy || global.gdf.water != _water || global.gdf.credits != _credits || global.gdf.support != _support) {
        _failures = scr_selftest_fail(_failures, _message + ": ação inválida cobrou recurso");
    }
    return _failures;
}

function scr_selftest_restore_stage(_failures, _stage) {
    scr_init_stage(_stage);
    var _target_pollution = global.gdf.target_pollution;
    var _target_bio = global.gdf.target_biodiversity;
    var _target_water = global.gdf.target_water;
    scr_selftest_seed_resources();

    for (var i = 0; i < array_length(global.gdf.tiles); i++) {
        var _tile = global.gdf.tiles[i];
        if (!instance_exists(_tile)) continue;
        global.gdf.energy = 100;
        global.gdf.water = 100;
        global.gdf.credits = 100;
        global.gdf.support = 80;
        if (_tile.tile_kind == "water") {
            scr_apply_action(self, "purify", _tile);
        } else {
            scr_apply_action(self, "clean", _tile);
            global.gdf.energy = 100;
            global.gdf.water = 100;
            global.gdf.credits = 100;
            global.gdf.support = 80;
            scr_apply_action(self, "corridor", _tile);
        }
    }

    global.gdf.target_pollution = _target_pollution;
    global.gdf.target_biodiversity = _target_bio;
    global.gdf.target_water = _target_water;
    global.gdf.pollution = min(global.gdf.pollution, _target_pollution);
    global.gdf.biodiversity = max(global.gdf.biodiversity, _target_bio);
    global.gdf.water = max(global.gdf.water, _target_water);
    global.gdf.support = max(global.gdf.support, 10);
    global.gdf.stage_goal_current = global.gdf.stage_goal_target;
    if (!scr_check_victory(self)) _failures = scr_selftest_fail(_failures, "fase " + string(_stage + 1) + ": restauração completa não ativou vitória");
    return _failures;
}

function scr_run_self_tests() {
    var _failures = [];

    var _scan_cost = scr_action_def("scan");
    if (is_undefined(_scan_cost) || _scan_cost.energy != 0 || _scan_cost.water != 0 || _scan_cost.credits != 0) {
        _failures = scr_selftest_fail(_failures, "ux: escanear precisa ter custo zero");
    }

    scr_init_stage(0);
    scr_selftest_seed_resources();
    global.gdf.sabotage_enabled = true;
    random_set_seed(2140);
    var _sabotage_tile = scr_selftest_find_tile("soil", "", "");
    if (_sabotage_tile == noone) _sabotage_tile = scr_selftest_find_tile("dry", "", "");
    if (_sabotage_tile == noone) {
        _failures = scr_selftest_fail(_failures, "sabotagem: tile alvo ausente");
    } else {
        if (!scr_apply_action(self, "scan", _sabotage_tile)) _failures = scr_selftest_fail(_failures, "sabotagem: ação de teste falhou");
        if (global.gdf.last_sabotage_id < 0) _failures = scr_selftest_fail(_failures, "sabotagem: nenhum contra-ataque registrado");
        if (global.gdf.last_sabotage == "") _failures = scr_selftest_fail(_failures, "sabotagem: texto do adversário ausente");
        if (string_pos("A Poluição contra-atacou", global.gdf.alert) <= 0) _failures = scr_selftest_fail(_failures, "sabotagem: alerta do adversário ausente");
    }

    for (var stage = 0; stage < 3; stage++) {
        scr_init_stage(stage);
        if (!variable_global_exists("gdf")) _failures = scr_selftest_fail(_failures, "fase " + string(stage + 1) + ": global.gdf não foi criado");
        if (array_length(global.gdf.tiles) != 70) _failures = scr_selftest_fail(_failures, "fase " + string(stage + 1) + ": mapa não criou 70 tiles");
        if (instance_number(obj_button_action) != 10) _failures = scr_selftest_fail(_failures, "fase " + string(stage + 1) + ": barra de ações não criou 10 botões");
        if (stage == 0 && scr_selftest_count_tiles("water", "", "") <= 0) _failures = scr_selftest_fail(_failures, "fase 1: sem água para nascentes");
        if (stage == 1 && scr_selftest_count_tiles("", "", "damaged") <= 0) _failures = scr_selftest_fail(_failures, "fase 2: sem estrutura danificada");
        if (stage == 2 && scr_selftest_count_tiles("water", "", "") <= 0) _failures = scr_selftest_fail(_failures, "fase 3: sem água costeira");

        var _land_kind = (scr_selftest_find_tile("soil", "", "") != noone) ? "soil" : "dry";
        _failures = scr_selftest_expect_action(_failures, stage, "plant", _land_kind, "", "fase " + string(stage + 1) + " plantar");
        _failures = scr_selftest_expect_action(_failures, stage, "clean", "", "", "fase " + string(stage + 1) + " limpar");
        _failures = scr_selftest_expect_action(_failures, stage, "solar", _land_kind, "", "fase " + string(stage + 1) + " solar");
        _failures = scr_selftest_expect_action(_failures, stage, "recycle", _land_kind, "", "fase " + string(stage + 1) + " reciclar");
        var _purify_kind = (scr_selftest_find_tile("water", "", "") != noone) ? "water" : _land_kind;
        _failures = scr_selftest_expect_action(_failures, stage, "purify", _purify_kind, "", "fase " + string(stage + 1) + " purificar");
        _failures = scr_selftest_expect_action(_failures, stage, "corridor", _land_kind, "", "fase " + string(stage + 1) + " corredor");
        _failures = scr_selftest_expect_action(_failures, stage, "scan", _land_kind, "", "fase " + string(stage + 1) + " escanear");
        _failures = scr_selftest_expect_action(_failures, stage, "repair", "", "damaged", "fase " + string(stage + 1) + " reparar");

        if (scr_selftest_find_tile("water", "", "") != noone) {
            _failures = scr_selftest_expect_invalid(_failures, stage, "plant", "water", "", "fase " + string(stage + 1) + " plantio inválido na água");
            _failures = scr_selftest_expect_invalid(_failures, stage, "solar", "water", "", "fase " + string(stage + 1) + " solar inválido na água");
        }
        _failures = scr_selftest_expect_invalid(_failures, stage, "repair", _land_kind, "", "fase " + string(stage + 1) + " reparo sem estrutura");
        _failures = scr_selftest_restore_stage(_failures, stage);
    }

    scr_init_stage(0);
    scr_selftest_seed_resources();
    var _synergy_tile = scr_selftest_find_tile("soil", "", "");
    if (_synergy_tile == noone) _synergy_tile = scr_selftest_find_tile("dry", "", "");
    if (_synergy_tile == noone) {
        _failures = scr_selftest_fail(_failures, "sinergia: tile alvo ausente");
    } else {
        var _bio_before_synergy = global.gdf.biodiversity;
        if (!scr_apply_action(self, "plant", _synergy_tile)) {
            _failures = scr_selftest_fail(_failures, "sinergia: plantio falhou");
        }
        if (global.gdf.last_combo == "") _failures = scr_selftest_fail(_failures, "sinergia: feedback nao foi registrado");
        if (global.gdf.biodiversity <= _bio_before_synergy + 8) _failures = scr_selftest_fail(_failures, "sinergia: bonus de biodiversidade ausente");
    }

    scr_init_stage(1);
    scr_selftest_seed_resources();
    var _income_tile = scr_selftest_find_tile("soil", "", "");
    if (_income_tile == noone) {
        _failures = scr_selftest_fail(_failures, "renda por turno: tile alvo ausente");
    } else {
        _income_tile.building = "solar";
        global.gdf.turn = 2;
        global.gdf.energy = 50;
        global.gdf.resolve_income = true;
        scr_update_resources(self);
        if (global.gdf.energy != 52) _failures = scr_selftest_fail(_failures, "renda por turno: painel solar nao gerou energia");
        var _energy_after_income = global.gdf.energy;
        scr_update_resources(self);
        if (global.gdf.energy != _energy_after_income) _failures = scr_selftest_fail(_failures, "renda por turno: renda duplicou fora do turno");
    }

    scr_init_stage(0);
    scr_selftest_seed_resources();
    global.gdf.max_action_points = 2;
    global.gdf.action_points = 2;
    var _ap_tile = scr_selftest_find_tile("soil", "", "");
    if (_ap_tile == noone) _ap_tile = scr_selftest_find_tile("dry", "", "");
    if (_ap_tile == noone) {
        _failures = scr_selftest_fail(_failures, "jogadas: tile alvo ausente");
    } else {
        if (!scr_apply_action(self, "scan", _ap_tile)) _failures = scr_selftest_fail(_failures, "jogadas: primeira acao falhou");
        if (global.gdf.action_points != 1) _failures = scr_selftest_fail(_failures, "jogadas: primeira acao nao consumiu ponto");
        if (!scr_apply_action(self, "scan", _ap_tile)) _failures = scr_selftest_fail(_failures, "jogadas: segunda acao falhou");
        if (global.gdf.action_points != 0) _failures = scr_selftest_fail(_failures, "jogadas: segunda acao nao zerou pontos");
        var _credits_before_block = global.gdf.credits;
        if (scr_apply_action(self, "scan", _ap_tile)) _failures = scr_selftest_fail(_failures, "jogadas: acao sem pontos foi permitida");
        if (global.gdf.credits != _credits_before_block) _failures = scr_selftest_fail(_failures, "jogadas: acao bloqueada alterou recursos");
        scr_next_turn(self);
        if (global.gdf.action_points != global.gdf.max_action_points) _failures = scr_selftest_fail(_failures, "jogadas: novo turno nao restaurou pontos");
    }

    scr_init_stage(1);
    scr_selftest_seed_resources();
    global.gdf.max_action_points = 4;
    global.gdf.action_points = 4;
    var _combo_tile = scr_selftest_find_tile("soil", "", "");
    if (_combo_tile == noone) {
        _failures = scr_selftest_fail(_failures, "plano integrado: tile alvo ausente");
    } else {
        scr_apply_action(self, "scan", _combo_tile);
        scr_apply_action(self, "clean", _combo_tile);
        scr_apply_action(self, "solar", _combo_tile);
        if (!global.gdf.turn_combo_claimed) _failures = scr_selftest_fail(_failures, "plano integrado: combo de tipos nao ativou");
    }

    scr_init_stage(0);
    scr_selftest_seed_resources();
    var _turn_before = global.gdf.turn;
    random_set_seed(2140);
    for (var e = 0; e < 8; e++) scr_spawn_event(self);
    scr_next_turn(self);
    if (global.gdf.turn != _turn_before + 1) _failures = scr_selftest_fail(_failures, "scr_next_turn não incrementou turno");
    if (global.gdf.energy < 0 || global.gdf.water < 0 || global.gdf.support < 0) _failures = scr_selftest_fail(_failures, "eventos deixaram recurso negativo");

    global.gdf.pollution = 20;
    global.gdf.biodiversity = 80;
    global.gdf.water = 40;
    global.gdf.support = 20;
    global.gdf.target_pollution = 25;
    global.gdf.target_biodiversity = 68;
    global.gdf.target_water = 18;
    global.gdf.stage_goal_current = global.gdf.stage_goal_target;
    if (!scr_check_victory(self)) _failures = scr_selftest_fail(_failures, "condição de vitória não ativou");

    global.gdf.pollution = 97;
    global.gdf.critical_pollution = 96;
    var _defeat_reason = scr_check_defeat(self);
    if (_defeat_reason != "Poluição crítica") _failures = scr_selftest_fail(_failures, "derrota por poluição crítica não ativou");

    var _status = (array_length(_failures) == 0) ? "PASS" : "FAIL";
    show_debug_message("SELFTEST_RESULT:" + _status);
    for (var d = 0; d < array_length(_failures); d++) {
        show_debug_message("SELFTEST_FAILURE:" + _failures[d]);
    }

    var _file = file_text_open_write(working_directory + "selftest_result.txt");
    file_text_write_string(_file, _status);
    file_text_writeln(_file);
    for (var f = 0; f < array_length(_failures); f++) {
        file_text_write_string(_file, _failures[f]);
        file_text_writeln(_file);
    }
    file_text_close(_file);
}
