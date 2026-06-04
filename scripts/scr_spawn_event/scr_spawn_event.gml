function scr_random_tile() {
    if (!variable_global_exists("gdf")) return noone;

    var len = array_length(global.gdf.tiles);
    if (len <= 0) return noone;

    return global.gdf.tiles[irandom(len - 1)];
}

function scr_pollution_sabotage(_source_tile, _action) {
    if (!variable_global_exists("gdf")) return "";
    if (variable_struct_exists(global.gdf, "sabotage_enabled") && !global.gdf.sabotage_enabled) return "";

    if (!variable_struct_exists(global.gdf, "last_sabotage_id")) global.gdf.last_sabotage_id = -1;

    var t = scr_random_tile();
    if (_action == "scan" && instance_exists(_source_tile)) t = _source_tile;

    var sabotage_id = irandom(5);
    if (sabotage_id == global.gdf.last_sabotage_id) sabotage_id = (sabotage_id + 1) mod 6;
    global.gdf.last_sabotage_id = sabotage_id;
    if (variable_struct_exists(global.gdf, "pollution_threat")) {
        global.gdf.pollution_threat = clamp(global.gdf.pollution_threat + 8, 0, 100);
    }

    var mitigated = (_action == "scan") || (instance_exists(t) && t.scanned);
    var scale = mitigated ? 0.5 : 1;
    var text = "";

    switch (sabotage_id) {
        case 0:
            global.gdf.pollution += ceil(3 * scale);
            if (instance_exists(t)) {
                t.tile_state = "polluted";
                t.recovery = max(0, t.recovery - 1);
                t.event_effect = "smoke";
                t.event_timer = 55;
                t.pop = 1;
                scr_update_tile_state(t);
            }
            text = "Nuvem tóxica elevou a poluição local.";
            break;

        case 1:
            global.gdf.credits -= ceil(3 * scale);
            global.gdf.pollution += ceil(2 * scale);
            if (instance_exists(t)) {
                t.tile_state = "polluted";
                t.event_effect = "spill";
                t.event_timer = 55;
                t.pop = 1;
                scr_update_tile_state(t);
            }
            text = "Resíduos clandestinos consumiram crédito verde.";
            break;

        case 2:
            global.gdf.energy -= ceil(3 * scale);
            if (instance_exists(t) && t.building != "" && t.building != "damaged") {
                t.building = "damaged";
                t.event_effect = "alert";
                t.event_timer = 60;
                t.pop = 1;
                text = "Dreno energético danificou uma estrutura.";
            } else {
                text = "Dreno energético reduziu sua reserva de energia.";
            }
            break;

        case 3:
            global.gdf.support -= ceil(3 * scale);
            if (instance_exists(t)) {
                t.event_effect = "alert";
                t.event_timer = 50;
                t.pop = 1;
            }
            text = "Desinformação ambiental reduziu o apoio social.";
            break;

        case 4:
            global.gdf.water -= ceil(3 * scale);
            if (instance_exists(t)) {
                if (t.tile_kind == "water") t.tile_state = "polluted";
                t.event_effect = "spill";
                t.event_timer = 55;
                t.pop = 1;
                scr_update_tile_state(t);
            }
            text = "Contaminação rápida ameaçou a reserva de água.";
            break;

        default:
            global.gdf.biodiversity -= ceil(2 * scale);
            global.gdf.pollution += ceil(2 * scale);
            if (instance_exists(t)) {
                if (t.tile_state == "recovered") t.tile_state = "recovering";
                t.recovery = max(0, t.recovery - 1);
                t.event_effect = "smoke";
                t.event_timer = 55;
                t.pop = 1;
                scr_update_tile_state(t);
            }
            text = "Pressão ecológica atrasou a recuperação natural.";
            break;
    }

    global.gdf.energy = clamp(global.gdf.energy, 0, 120);
    global.gdf.water = clamp(global.gdf.water, 0, 120);
    global.gdf.credits = clamp(global.gdf.credits, 0, 140);
    global.gdf.support = clamp(global.gdf.support, 0, 100);
    global.gdf.biodiversity = clamp(global.gdf.biodiversity, 0, 100);
    global.gdf.pollution = clamp(global.gdf.pollution, 0, 100);

    if (mitigated) text += " Área escaneada reduziu o dano.";
    global.gdf.last_sabotage = text;
    var hints = [
        "Possível fumaça tóxica.",
        "Possível descarte clandestino.",
        "Possível dano energético.",
        "Possível desinformação.",
        "Possível contaminação da água.",
        "Possível perda de biodiversidade."
    ];
    global.gdf.next_sabotage_hint = hints[(sabotage_id + 1) mod 6];
    audio_play_sound(snd_event, 1, false);
    return " A Poluição contra-atacou: " + text;
}

function scr_spawn_event(_game) {
    if (!variable_global_exists("gdf")) return;

    if (random(1) > 0.72) {
        global.gdf.last_event = "Turno estável: os sistemas de restauração mantiveram ritmo.";
        scr_log_event(global.gdf.last_event);
        return;
    }

    var event_id = irandom(6);
    var t = scr_random_tile();
    var mitigated = instance_exists(t) && t.scanned;
    var event_scale = mitigated ? 0.5 : 1;

    switch (event_id) {
        case 0:
            global.gdf.water -= round(6 * event_scale);
            global.gdf.support -= round(2 * event_scale);
            if (instance_exists(t)) {
                t.tile_kind = "dry";
                t.tile_state = "polluted";
                t.event_effect = "smoke";
                t.event_timer = 60;
                scr_update_tile_state(t);
            }
            global.gdf.last_event = "Seca leve: a água caiu e uma célula ficou seca.";
            break;

        case 1:
            global.gdf.pollution += round(9 * event_scale);
            if (instance_exists(t)) {
                t.tile_state = "polluted";
                t.event_effect = "spill";
                t.event_timer = 70;
                scr_update_tile_state(t);
            }
            global.gdf.last_event = "Vazamento tóxico: a poluição subiu em uma área crítica.";
            break;

        case 2:
            global.gdf.energy -= round(6 * event_scale);
            global.gdf.support -= round(4 * event_scale);
            if (instance_exists(t)) {
                t.building = "damaged";
                t.event_effect = "alert";
                t.event_timer = 70;
            }
            global.gdf.last_event = "Sabotagem industrial: energia e apoio social sofreram queda.";
            break;

        case 3:
            global.gdf.pollution += round(6 * event_scale);
            global.gdf.biodiversity -= round(4 * event_scale);
            if (instance_exists(t)) {
                t.tile_kind = "dry";
                t.tile_state = "polluted";
                t.event_effect = "smoke";
                t.event_timer = 70;
                scr_update_tile_state(t);
            }
            global.gdf.last_event = "Incêndio ambiental: biodiversidade caiu, mas ainda dá para recuperar.";
            break;

        case 4:
            global.gdf.water += 12;
            global.gdf.biodiversity += 4;
            if (instance_exists(t)) {
                t.event_effect = "water";
                t.event_timer = 60;
            }
            global.gdf.last_event = "Chuva regenerativa: água e biodiversidade ganharam fôlego.";
            break;

        case 5:
            global.gdf.support += 10;
            global.gdf.credits += 8;
            global.gdf.last_event = "Apoio comunitário: moradores enviaram crédito verde.";
            break;

        default:
            global.gdf.support += 7;
            global.gdf.pollution -= 9;
            if (instance_exists(t)) {
                t.recovery += 3;
                t.tile_state = "recovering";
                t.event_effect = "green";
                t.event_timer = 60;
                scr_update_tile_state(t);
            }
            global.gdf.last_event = "Mutirão ecológico: uma área recebeu recuperação acelerada.";
            break;
    }

    if (mitigated) global.gdf.last_event = "Área escaneada reduziu o impacto. " + global.gdf.last_event;

    global.gdf.alert = global.gdf.last_event;
    global.gdf.alert_timer = 210;
    scr_log_event(global.gdf.last_event);
    audio_play_sound(snd_event, 1, false);
}
