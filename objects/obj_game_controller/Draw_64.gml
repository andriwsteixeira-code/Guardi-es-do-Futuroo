draw_set_alpha(1);
if (variable_global_exists("gdf_font_ui") && global.gdf_font_ui != -1) draw_set_font(global.gdf_font_ui);

if (room == rm_game) exit;

draw_set_color(make_colour_rgb(14, 30, 38));
draw_rectangle(0, 0, 1280, 720, false);

if (room == rm_menu) {
    if (!variable_global_exists("gdf_menu_mode")) global.gdf_menu_mode = "main";
    if (!variable_global_exists("gdf_sound_enabled")) global.gdf_sound_enabled = true;
    if (!variable_global_exists("gdf_master_volume")) global.gdf_master_volume = 0.8;

    draw_sprite_stretched(spr_menu_background, 0, 0, 0, 1280, 720);
    draw_set_alpha(0.54);
    draw_set_color(make_colour_rgb(8, 24, 30));
    draw_rectangle(0, 0, 1280, 720, false);
    draw_set_alpha(0.86);
    draw_set_color(make_colour_rgb(10, 32, 39));
    draw_roundrect(342, 70, 938, 632, false);
    draw_set_alpha(1);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(640, 112, "Guardiões do Futuro", 2.25, 2.25, 0);
    draw_set_color(make_colour_rgb(157, 228, 205));
    draw_text_transformed(640, 184, "Estratégia ecológica por turnos", 0.95, 0.95, 0);
    draw_set_color(make_colour_rgb(215, 244, 234));
    draw_text(640, 238, "Recupere ecossistemas usando ciência, energia limpa e decisões ambientais.");

    var _mode = global.gdf_menu_mode;
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    if (_mode == "main") {
        var _labels = ["INICIAR MISSÃO", "OPÇÕES DE SOM", "CRÉDITOS"];
        for (var i = 0; i < 3; i++) {
            var _y1 = 366 + i * 72;
            var _hover = point_in_rectangle(_mx, _my, 470, _y1, 810, _y1 + 58);
            draw_set_color(make_colour_rgb(6, 24, 27));
            draw_roundrect(466, _y1 + 5, 814, _y1 + 63, false);
            draw_set_color(_hover ? make_colour_rgb(92, 240, 183) : make_colour_rgb(42, 190, 138));
            draw_roundrect(470, _y1, 810, _y1 + 58, false);
            draw_set_color(c_white);
            draw_text(640, _y1 + 29, _labels[i]);
        }
    } else if (_mode == "options") {
        draw_set_color(c_white);
        draw_text_transformed(640, 306, "Opções de som", 1.25, 1.25, 0);

        var _sound_text = global.gdf_sound_enabled ? "SOM: LIGADO" : "SOM: DESLIGADO";
        var _sound_hover = point_in_rectangle(_mx, _my, 470, 340, 810, 398);
        draw_set_color(_sound_hover ? make_colour_rgb(82, 228, 174) : make_colour_rgb(40, 182, 132));
        draw_roundrect(470, 340, 810, 398, false);
        draw_set_color(c_white);
        draw_text(640, 369, _sound_text);

        draw_set_color(make_colour_rgb(215, 244, 234));
        draw_text(640, 424, "VOLUME");
        draw_set_color(make_colour_rgb(30, 68, 76));
        draw_roundrect(560, 450, 720, 476, false);
        draw_set_color(make_colour_rgb(80, 205, 158));
        draw_rectangle(560, 450, 560 + 160 * global.gdf_master_volume, 476, false);
        draw_set_color(c_white);
        draw_text(640, 463, string(round(global.gdf_master_volume * 100)) + "%");

        draw_set_color(point_in_rectangle(_mx, _my, 470, 434, 540, 492) ? make_colour_rgb(82, 228, 174) : make_colour_rgb(40, 182, 132));
        draw_roundrect(470, 434, 540, 492, false);
        draw_set_color(c_white);
        draw_text(505, 463, "-");

        draw_set_color(point_in_rectangle(_mx, _my, 740, 434, 810, 492) ? make_colour_rgb(82, 228, 174) : make_colour_rgb(40, 182, 132));
        draw_roundrect(740, 434, 810, 492, false);
        draw_set_color(c_white);
        draw_text(775, 463, "+");

        draw_set_color(point_in_rectangle(_mx, _my, 470, 548, 810, 606) ? make_colour_rgb(82, 228, 174) : make_colour_rgb(40, 182, 132));
        draw_roundrect(470, 548, 810, 606, false);
        draw_set_color(c_white);
        draw_text(640, 577, "VOLTAR");
    } else if (_mode == "credits") {
        draw_set_color(c_white);
        draw_text_transformed(640, 286, "Créditos", 1.25, 1.25, 0);
        draw_set_color(make_colour_rgb(215, 244, 234));
        draw_text_transformed(640, 330, "Equipe Guardiões do Futuro", 0.78, 0.78, 0);

        var _team = ["Paulo Sergio", "Andrews", "Elias", "Luís Felipe", "Gerdson", "Claudio"];
        for (var c = 0; c < array_length(_team); c++) {
            var _cx = (c < 3) ? 540 : 740;
            var _cy = 372 + (c mod 3) * 34;
            draw_set_color(make_colour_rgb(230, 255, 246));
            draw_text(_cx, _cy, _team[c]);
        }

        draw_set_color(make_colour_rgb(154, 225, 202));
        draw_text_transformed(640, 492, "Motor: GameMaker / GML  |  Arte e assets: imagegen", 0.58, 0.58, 0);

        draw_set_color(point_in_rectangle(_mx, _my, 470, 548, 810, 606) ? make_colour_rgb(82, 228, 174) : make_colour_rgb(40, 182, 132));
        draw_roundrect(470, 548, 810, 606, false);
        draw_set_color(c_white);
        draw_text(640, 577, "VOLTAR");
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
} else if (room == rm_stage_select) {
    draw_sprite_stretched(spr_menu_background, 0, 0, 0, 1280, 720);
    draw_set_alpha(0.68);
    draw_set_color(make_colour_rgb(7, 22, 28));
    draw_rectangle(0, 0, 1280, 720, false);
    draw_set_alpha(1);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(640, 64, "Seleção de fase", 1.7, 1.7, 0);
    draw_set_color(make_colour_rgb(157, 228, 205));
    draw_text(640, 110, "Escolha uma região para restaurar. Cada imagem representa o mapa que será carregado.");

    var names = ["Floresta Norte", "Vale Industrial", "Costa Azul"];
    var focus = ["Reflorestamento", "Energia limpa", "Água e costa"];
    var risks = ["Nascentes e solo seco", "Emissões e resíduos", "Água e erosão"];
    var key_actions = ["Ação-chave: plantar", "Ação-chave: solar", "Ação-chave: purificar"];
    var cards = [spr_stage_forest_card, spr_stage_industrial_card, spr_stage_coast_card];

    for (var i = 0; i < 3; i++) {
        var x1 = 100 + i * 370;
        var y1 = 150;
        var _hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), x1, y1, x1 + 340, y1 + 430);
        draw_set_color(make_colour_rgb(5, 18, 22));
        draw_roundrect(x1 + 6, y1 + 8, x1 + 346, y1 + 438, false);
        draw_set_color(_hover ? make_colour_rgb(38, 94, 82) : make_colour_rgb(22, 52, 58));
        draw_roundrect(x1, y1, x1 + 340, y1 + 430, false);
        draw_set_color(_hover ? make_colour_rgb(107, 237, 183) : make_colour_rgb(72, 178, 150));
        draw_rectangle(x1, y1, x1 + 340, y1 + 8, false);
        draw_sprite_stretched(cards[i], 0, x1 + 10, y1 + 18, 320, 210);
        draw_set_alpha(0.72);
        draw_set_color(make_colour_rgb(4, 18, 22));
        draw_rectangle(x1 + 10, y1 + 178, x1 + 330, y1 + 228, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text_transformed(x1 + 170, y1 + 205, names[i], 1.02, 1.02, 0);
        draw_set_color(make_colour_rgb(182, 230, 212));
        draw_text_transformed(x1 + 170, y1 + 255, focus[i], 0.74, 0.74, 0);
        draw_set_color(make_colour_rgb(45, 110, 102));
        draw_rectangle(x1 + 38, y1 + 286, x1 + 302, y1 + 288, false);
        draw_set_color(make_colour_rgb(222, 248, 239));
        draw_text_transformed(x1 + 170, y1 + 312, risks[i], 0.62, 0.62, 0);
        draw_set_color(make_colour_rgb(255, 226, 126));
        draw_text_transformed(x1 + 170, y1 + 340, key_actions[i], 0.58, 0.58, 0);
        draw_set_color(_hover ? make_colour_rgb(82, 228, 174) : make_colour_rgb(45, 160, 130));
        draw_roundrect(x1 + 70, y1 + 368, x1 + 270, y1 + 414, false);
        draw_set_color(c_white);
        draw_text(x1 + 170, y1 + 391, "JOGAR");
    }

    var back_hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), 40, 626, 220, 676);
    draw_set_color(back_hover ? make_colour_rgb(82, 228, 174) : make_colour_rgb(38, 132, 118));
    draw_roundrect(40, 626, 220, 676, false);
    draw_set_color(c_white);
    draw_text(130, 651, "MENU");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
} else if (room == rm_victory || room == rm_defeat) {
    var victory = (room == rm_victory);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_sprite_ext(victory ? spr_effect_ecology_glow : spr_effect_toxic_smoke, 0, 640, 188, 1.6, 1.6, 0, c_white, 0.9);
    draw_set_color(victory ? make_colour_rgb(158, 242, 193) : make_colour_rgb(255, 196, 140));
    draw_text_transformed(640, 300, victory ? "Missão restaurada" : "Missão em risco", 2.0, 2.0, 0);
    draw_set_color(c_white);
    if (variable_global_exists("gdf") && variable_struct_exists(global.gdf, "report_reason")) draw_text(640, 365, global.gdf.report_reason);
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
    draw_text_transformed(640, 66, "Relatório Final", 1.65, 1.65, 0);
    draw_set_color(make_colour_rgb(29, 58, 66));
    draw_roundrect(210, 126, 1070, 590, false);
    draw_set_color(make_colour_rgb(72, 178, 150));
    draw_rectangle(210, 126, 1070, 134, false);

    if (variable_global_exists("gdf")) {
        draw_set_color(make_colour_rgb(20, 48, 56));
        draw_roundrect(250, 150, 1030, 230, false);
        draw_set_color(c_white);
        draw_text_transformed(640, 176, global.gdf.stage_name, 0.95, 0.95, 0);
        draw_set_color(make_colour_rgb(255, 226, 126));
        draw_text_transformed(575, 212, "Estrelas:", 0.52, 0.52, 0);
        for (var st = 0; st < 3; st++) {
            draw_text_transformed(660 + st * 36, 212, st < global.gdf.report_stars ? "*" : "-", 1.25, 1.25, 0);
        }

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        var summary_x = 250;
        var summary_y = 248;
        var summary_w = 300;
        draw_set_color(make_colour_rgb(20, 48, 56));
        draw_roundrect(summary_x, summary_y, summary_x + summary_w, 548, false);
        draw_set_color(make_colour_rgb(101, 236, 184));
        draw_text_transformed(summary_x + 18, summary_y + 14, "Resumo da missão", 0.58, 0.58, 0);

        var labels_report = ["Resultado", "Poluição", "Biodiv.", "Água", "Energia", "Apoio", "Nota", "Objetivo"];
        var values_report = [
            global.gdf.report_result,
            string(global.gdf.pollution),
            string(global.gdf.biodiversity),
            string(global.gdf.water),
            string(global.gdf.energy),
            string(global.gdf.support),
            global.gdf.report_grade,
            string(global.gdf.stage_goal_current) + "/" + string(global.gdf.stage_goal_target)
        ];
        for (var ri = 0; ri < array_length(labels_report); ri++) {
            var row_y = summary_y + 50 + ri * 29;
            draw_set_color(make_colour_rgb(26, 62, 66));
            draw_roundrect(summary_x + 14, row_y, summary_x + summary_w - 14, row_y + 23, false);
            draw_set_color(make_colour_rgb(188, 232, 220));
            draw_text_transformed(summary_x + 26, row_y + 5, labels_report[ri], 0.42, 0.42, 0);
            draw_set_halign(fa_right);
            draw_set_color(c_white);
            draw_text_transformed(summary_x + summary_w - 28, row_y + 4, values_report[ri], 0.50, 0.50, 0);
            draw_set_halign(fa_left);
        }

        var bx = 580;
        var by = 248;
        draw_set_color(make_colour_rgb(20, 48, 56));
        draw_roundrect(bx, by, 1030, 388, false);
        draw_set_color(make_colour_rgb(101, 236, 184));
        draw_text_transformed(bx + 18, by + 14, "Desempenho ambiental", 0.58, 0.58, 0);
        var bnames = ["Poluição", "Biodiv.", "Água", "Energia", "Apoio"];
        var bvals = [100 - global.gdf.pollution, global.gdf.biodiversity, global.gdf.water, global.gdf.energy, global.gdf.support];
        for (var bi = 0; bi < 5; bi++) {
            draw_set_color(make_colour_rgb(214, 244, 232));
            draw_text_transformed(bx + 22, by + 48 + bi * 17, bnames[bi], 0.38, 0.38, 0);
            draw_set_color(make_colour_rgb(36, 82, 76));
            draw_roundrect(bx + 126, by + 48 + bi * 17, bx + 408, by + 60 + bi * 17, false);
            draw_set_color(bi == 0 ? make_colour_rgb(255, 206, 121) : make_colour_rgb(95, 225, 169));
            draw_rectangle(bx + 126, by + 48 + bi * 17, bx + 126 + 282 * clamp(bvals[bi], 0, 100) / 100, by + 60 + bi * 17, false);
        }

        draw_set_color(make_colour_rgb(20, 48, 56));
        draw_roundrect(580, 402, 1030, 536, false);
        draw_set_color(make_colour_rgb(101, 236, 184));
        draw_text_transformed(598, 416, "Mensagem educativa", 0.54, 0.54, 0);
        draw_set_color(c_white);
        var report_text = global.gdf.report_message;
        if (string_length(report_text) > 165) report_text = string_copy(report_text, 1, 162) + "...";
        draw_text_ext_transformed(598, 444, report_text, 34, 402, 0.44, 0.44, 0);

        draw_set_color(make_colour_rgb(20, 48, 56));
        draw_roundrect(580, 548, 1030, 580, false);
        draw_set_color(make_colour_rgb(255, 226, 126));
        var reward_text = global.gdf.report_reward;
        if (string_length(reward_text) > 86) reward_text = string_copy(reward_text, 1, 83) + "...";
        draw_text_ext_transformed(598, 557, reward_text, 26, 404, 0.42, 0.42, 0);
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
