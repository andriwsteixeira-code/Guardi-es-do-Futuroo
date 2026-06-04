if (room != rm_game || !variable_global_exists("gdf")) exit;
if (variable_global_exists("gdf_font_ui") && global.gdf_font_ui != -1) draw_set_font(global.gdf_font_ui);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_alpha(0.94);
draw_set_color(make_colour_rgb(16, 36, 44));
draw_rectangle(0, 0, 1280, 84, false);
draw_set_alpha(0.98);
draw_set_color(make_colour_rgb(9, 31, 36));
draw_rectangle(0, 580, 1280, 638, false);
draw_set_color(make_colour_rgb(23, 68, 67));
draw_rectangle(0, 580, 1280, 586, false);
draw_set_alpha(1);

var labels = ["Energia", "Água", "Biodiv.", "Poluição", "Apoio", "Crédito", "Jogadas", "Turno"];
var values = [
    global.gdf.energy,
    global.gdf.water,
    global.gdf.biodiversity,
    global.gdf.pollution,
    global.gdf.support,
    global.gdf.credits,
    string(global.gdf.action_points) + "/" + string(global.gdf.max_action_points),
    string(global.gdf.turn) + "/" + string(global.gdf.max_turns)
];
var icons = [spr_icon_energy, spr_icon_water, spr_icon_biodiversity, spr_icon_pollution, spr_icon_social, spr_icon_resources, spr_icon_turn, spr_icon_turn];

for (var i = 0; i < array_length(labels); i++) {
    var px = 20 + i * 154;
    var py = 10;
    var value_color = c_white;

    if ((i == 0 || i == 1) && values[i] < 10) value_color = make_colour_rgb(255, 129, 98);
    else if ((i == 0 || i == 1) && values[i] < 20) value_color = make_colour_rgb(255, 222, 112);
    else if (i == 2 && values[i] >= global.gdf.target_biodiversity) value_color = make_colour_rgb(115, 255, 166);
    else if (i == 3 && values[i] <= global.gdf.target_pollution) value_color = make_colour_rgb(115, 255, 166);
    else if (i == 3 && values[i] >= global.gdf.critical_pollution - 10) value_color = make_colour_rgb(255, 129, 98);
    else if (i == 4 && values[i] < 12) value_color = make_colour_rgb(255, 129, 98);
    else if (i == 6 && global.gdf.action_points <= 0) value_color = make_colour_rgb(255, 222, 112);

    draw_set_alpha(0.92);
    draw_set_color(make_colour_rgb(25, 56, 63));
    draw_roundrect(px, py, px + 136, py + 62, false);
    draw_set_alpha(1);
    draw_sprite_ext(icons[i], 0, px + 23, py + 31, 0.42, 0.42, 0, c_white, 1);
    draw_set_color(make_colour_rgb(184, 226, 216));
    draw_text_transformed(px + 46, py + 11, labels[i], 0.62, 0.62, 0);
    draw_set_color(value_color);
    draw_text_transformed(px + 46, py + 33, string(values[i]), 0.88, 0.88, 0);

    if (i == 6 && global.gdf.action_points <= 0) {
        draw_set_color(make_colour_rgb(255, 232, 122));
        draw_text_transformed(px + 84, py + 45, "encerre", 0.46, 0.46, 0);
    }
}

var side_x = 782;
var side_w = 466;
var tutorial_open = variable_struct_exists(global.gdf, "tutorial_active") && global.gdf.tutorial_active;
var dialogue_open = variable_struct_exists(global.gdf, "dialogue_timer") && global.gdf.dialogue_timer > 0;
var pause_open = variable_struct_exists(global.gdf, "paused") && global.gdf.paused;
var modal_open = tutorial_open || dialogue_open || pause_open;

draw_set_alpha(0.96);
draw_set_color(make_colour_rgb(18, 44, 50));
draw_roundrect(side_x, 128, side_x + side_w, 282, false);
draw_set_color(make_colour_rgb(22, 56, 63));
draw_roundrect(side_x, 294, side_x + side_w, 406, false);
draw_set_color(make_colour_rgb(26, 50, 58));
draw_roundrect(side_x, 418, side_x + side_w, 560, false);
draw_set_alpha(1);

draw_set_color(make_colour_rgb(101, 236, 184));
draw_rectangle(side_x, 128, side_x + side_w, 134, false);
draw_set_color(c_white);
draw_text_transformed(side_x + 18, 146, global.gdf.stage_name, 0.74, 0.74, 0);
draw_set_color(make_colour_rgb(163, 233, 207));
draw_text_transformed(side_x + 18, 172, global.gdf.stage_focus, 0.54, 0.54, 0);
draw_set_color(make_colour_rgb(101, 236, 184));
draw_text_transformed(side_x + 18, 204, "Objetivo", 0.52, 0.52, 0);
draw_set_color(make_colour_rgb(218, 248, 237));
draw_text_transformed(side_x + 18, 226, global.gdf.stage_goal_label + ": " + string(global.gdf.stage_goal_current) + "/" + string(global.gdf.stage_goal_target), 0.54, 0.54, 0);

draw_set_color(make_colour_rgb(34, 78, 76));
draw_roundrect(side_x + 18, 250, side_x + 142, 272, false);
draw_roundrect(side_x + 154, 250, side_x + 310, 272, false);
draw_roundrect(side_x + 322, 250, side_x + 448, 272, false);
draw_set_color(make_colour_rgb(255, 226, 126));
draw_text_transformed(side_x + 26, 255, "Poluição <= " + string(global.gdf.target_pollution), 0.42, 0.42, 0);
draw_text_transformed(side_x + 162, 255, "Biodiversidade >= " + string(global.gdf.target_biodiversity), 0.42, 0.42, 0);
draw_text_transformed(side_x + 330, 255, "Água >= " + string(global.gdf.target_water), 0.42, 0.42, 0);

draw_set_color(make_colour_rgb(101, 236, 184));
draw_text_transformed(side_x + 18, 308, "Evento do turno", 0.56, 0.56, 0);
draw_set_color(make_colour_rgb(218, 248, 237));
var event_short = global.gdf.last_event;
if (string_length(event_short) > 58) event_short = string_copy(event_short, 1, 55) + "...";
draw_text_transformed(side_x + 18, 334, event_short, 0.52, 0.52, 0);
draw_set_color(make_colour_rgb(101, 236, 184));
draw_text_transformed(side_x + 18, 362, "Histórico", 0.48, 0.48, 0);
draw_set_color(make_colour_rgb(200, 232, 222));
if (variable_struct_exists(global.gdf, "event_log")) {
    for (var li = 0; li < min(2, array_length(global.gdf.event_log)); li++) {
        draw_text_transformed(side_x + 18, 382 + li * 18, global.gdf.event_log[li], 0.40, 0.40, 0);
    }
}

draw_set_color(make_colour_rgb(255, 206, 121));
draw_text_transformed(side_x + 18, 432, "Adversário: Poluição", 0.56, 0.56, 0);
draw_set_color(make_colour_rgb(236, 246, 232));
var sabotage_short = "";
if (variable_struct_exists(global.gdf, "last_sabotage") && global.gdf.last_sabotage != "") {
    sabotage_short = global.gdf.last_sabotage;
} else {
    sabotage_short = "A Poluição ainda não reagiu.";
}
if (string_length(sabotage_short) > 74) sabotage_short = string_copy(sabotage_short, 1, 71) + "...";
draw_text_ext(side_x + 18, 456, sabotage_short, 22, side_w - 36);

var threat = variable_struct_exists(global.gdf, "pollution_threat") ? global.gdf.pollution_threat : global.gdf.pollution;
draw_set_color(make_colour_rgb(255, 206, 121));
draw_text_transformed(side_x + 18, 508, "Ameaça", 0.44, 0.44, 0);
draw_set_color(make_colour_rgb(55, 76, 76));
draw_roundrect(side_x + 84, 510, side_x + 258, 524, false);
draw_set_color(threat >= 70 ? make_colour_rgb(255, 129, 98) : make_colour_rgb(255, 206, 121));
draw_rectangle(side_x + 84, 510, side_x + 84 + 174 * clamp(threat, 0, 100) / 100, 524, false);
draw_set_color(make_colour_rgb(200, 232, 222));
var hint = variable_struct_exists(global.gdf, "next_sabotage_hint") ? global.gdf.next_sabotage_hint : "Escaneie para reduzir danos.";
draw_text_transformed(side_x + 18, 536, hint, 0.42, 0.42, 0);

draw_set_color(c_white);
draw_text_transformed(28, 594, "Ações ambientais", 0.70, 0.70, 0);
draw_set_color(make_colour_rgb(205, 244, 231));
draw_text_transformed(28, 616, "E/A/C = energia, água e crédito.", 0.50, 0.50, 0);

draw_set_alpha(0.92);
draw_set_color(make_colour_rgb(21, 58, 62));
draw_roundrect(300, 594, 882, 626, false);
draw_set_alpha(1);
var status_text = "Clique em uma ação e depois em uma célula do mapa.";
if (!modal_open && global.gdf.selected_action != "") {
    var preview = global.gdf.action_preview;
    if (preview == "") preview = scr_action_cost_text(global.gdf.selected_action);
    status_text = "Ação: " + global.gdf.selected_label + " | " + preview;
} else if (!modal_open && variable_struct_exists(global.gdf, "feedback_timer") && global.gdf.feedback_timer > 0 && global.gdf.last_feedback != "") {
    status_text = global.gdf.last_feedback;
} else if (!modal_open && global.gdf.alert_timer > 0) {
    status_text = global.gdf.alert;
} else if (!modal_open && variable_struct_exists(global.gdf, "turn_income_text") && global.gdf.turn_income_text != "") {
    status_text = global.gdf.turn_income_text;
}
if (string_length(status_text) > 64) status_text = string_copy(status_text, 1, 61) + "...";
draw_set_color(make_colour_rgb(230, 255, 246));
draw_text_transformed(316, 604, status_text, 0.50, 0.50, 0);

draw_set_color(make_colour_rgb(21, 58, 62));
draw_roundrect(900, 594, 1108, 626, false);
draw_set_color(make_colour_rgb(205, 244, 231));
draw_text_transformed(914, 604, "Fila", 0.44, 0.44, 0);
for (var qi = 0; qi < global.gdf.max_action_points; qi++) {
    var qx = 970 + qi * 38;
    if (qi < global.gdf.actions_used) draw_set_color(make_colour_rgb(72, 178, 150));
    else if (qi == global.gdf.actions_used) draw_set_color(make_colour_rgb(255, 226, 126));
    else draw_set_color(make_colour_rgb(55, 76, 76));
    draw_circle(qx, 610, 9, false);
}

var menu_hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), 1130, 590, 1248, 626);
draw_set_color(menu_hover ? make_colour_rgb(255, 190, 112) : make_colour_rgb(206, 111, 62));
draw_roundrect(1130, 590, 1248, 626, false);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text_transformed(1189, 608, "PAUSA", 0.62, 0.62, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

if (!modal_open && global.gdf.tooltip.timer > 0) {
    var tx = clamp(global.gdf.tooltip.x, 12, 430);
    var ty = clamp(global.gdf.tooltip.y, 90, 520);
    draw_set_alpha(0.97);
    draw_set_color(make_colour_rgb(10, 24, 30));
    draw_roundrect(tx, ty, tx + 320, ty + 96, false);
    draw_set_alpha(1);
    draw_set_color(make_colour_rgb(218, 246, 236));
    draw_text_ext(tx + 12, ty + 10, global.gdf.tooltip.text, 24, 292);
}

if (pause_open) {
    draw_set_alpha(0.76);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 1280, 720, false);
    draw_set_alpha(1);

    draw_set_color(make_colour_rgb(20, 48, 56));
    draw_roundrect(380, 110, 900, 624, false);
    draw_set_color(make_colour_rgb(95, 225, 169));
    draw_rectangle(380, 110, 900, 118, false);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(640, 154, global.gdf.pause_tab == "encyclopedia" ? "Enciclopédia" : "Pausa", 1.35, 1.35, 0);

    if (global.gdf.pause_tab == "encyclopedia") {
        var topics = [
            "Reflorestamento: árvores protegem o solo e ajudam a água voltar.",
            "Energia solar: reduz emissões e gera energia limpa por turno.",
            "Reciclagem: transforma resíduos em crédito verde e apoio social.",
            "Purificação: água limpa recupera biodiversidade e comunidades.",
            "Biodiversidade: corredores conectam áreas e aceleram a vida."
        ];

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        for (var ei = 0; ei < array_length(topics); ei++) {
            var ey = 210 + ei * 58;
            draw_set_color(make_colour_rgb(29, 70, 70));
            draw_roundrect(430, ey, 850, ey + 42, false);
            draw_set_color(make_colour_rgb(225, 252, 242));
            draw_text_ext(446, ey + 9, topics[ei], 18, 388);
        }

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(make_colour_rgb(45, 160, 130));
        draw_roundrect(530, 550, 750, 602, false);
        draw_set_color(c_white);
        draw_text(640, 576, "VOLTAR");
    } else {
        var sound_label = global.gdf_sound_enabled ? "SOM: LIGADO" : "SOM: DESLIGADO";
        var labels_pause = ["CONTINUAR", "REINICIAR FASE", "ENCICLOPÉDIA", sound_label, "VOLTAR AO MENU"];
        for (var pause_i = 0; pause_i < array_length(labels_pause); pause_i++) {
            var py = 214 + pause_i * 60;
            var hover_pause = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), 490, py, 790, py + 48);
            draw_set_color(hover_pause ? make_colour_rgb(82, 228, 174) : make_colour_rgb(45, 160, 130));
            draw_roundrect(490, py, 790, py + 48, false);
            draw_set_color(c_white);
            draw_text(640, py + 24, labels_pause[pause_i]);
        }
        draw_set_color(make_colour_rgb(178, 242, 220));
        draw_text_transformed(640, 548, "P/Esc continua. M abre a pausa durante a fase.", 0.55, 0.55, 0);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    exit;
}

if (tutorial_open) {
    var step = clamp(global.gdf.tutorial_step, 0, 3);
    var titles = [
        "1. Observe a região",
        "2. Leia os custos",
        "3. Aplique uma ação",
        "4. Encerre o turno"
    ];
    var bodies = [
        "Topo: recursos. Direita: objetivo, evento e Poluição. Rodapé: ações. Sua missão é cumprir a meta da fase e manter os recursos vivos.",
        "Cada turno tem 3 jogadas. Nos botões, E/A/C significa energia, água e crédito. A fila no rodapé mostra quantas jogadas restam.",
        "Clique em uma ação ou use 1 a 8. Depois clique em uma célula. Áreas recuperadas próximas geram sinergia e deixam a restauração mais forte.",
        "Após cada jogada, a Poluição reage. Escanear reduz danos e revela risco. Quando terminar suas jogadas, pressione N ou clique em Encerrar."
    ];

    draw_set_alpha(0.72);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 1280, 720, false);
    draw_set_alpha(1);

    draw_set_color(make_colour_rgb(24, 58, 64));
    draw_roundrect(260, 155, 1020, 575, false);
    draw_set_color(make_colour_rgb(95, 225, 169));
    draw_rectangle(260, 155, 1020, 164, false);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(640, 220, "Tutorial rápido", 1.35, 1.35, 0);
    draw_set_color(make_colour_rgb(178, 242, 220));
    draw_text_transformed(640, 270, titles[step], 1.05, 1.05, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_colour_rgb(230, 255, 246));
    draw_text_ext(360, 320, bodies[step], 26, 560);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_colour_rgb(51, 132, 122));
    draw_roundrect(430, 505, 625, 560, false);
    draw_set_color(make_colour_rgb(75, 205, 153));
    draw_roundrect(655, 505, 850, 560, false);
    draw_set_color(c_white);
    draw_text(527, 533, "PULAR");
    draw_text(752, 533, step == 3 ? "JOGAR" : "PRÓXIMO");

    draw_set_color(make_colour_rgb(178, 242, 220));
    draw_text_transformed(640, 593, "Espaço/Enter avança, Esc pula, H reabre o tutorial.", 0.62, 0.62, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

draw_set_alpha(1);
