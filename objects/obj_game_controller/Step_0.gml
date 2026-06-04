var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var clicked = mouse_check_button_pressed(mb_left);

if (room == rm_menu) {
    if (!variable_global_exists("gdf_menu_mode")) global.gdf_menu_mode = "main";
    if (!variable_global_exists("gdf_sound_enabled")) global.gdf_sound_enabled = true;
    if (!variable_global_exists("gdf_master_volume")) global.gdf_master_volume = 0.8;

    if (keyboard_check_pressed(vk_escape)) global.gdf_menu_mode = "main";

    if (clicked) {
        if (global.gdf_menu_mode == "main") {
            if (point_in_rectangle(mx, my, 470, 366, 810, 424)) {
                if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
                room_goto(rm_stage_select);
            } else if (point_in_rectangle(mx, my, 470, 438, 810, 496)) {
                global.gdf_menu_mode = "options";
                if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
            } else if (point_in_rectangle(mx, my, 470, 510, 810, 568)) {
                global.gdf_menu_mode = "credits";
                if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
            }
        } else if (global.gdf_menu_mode == "options") {
            if (point_in_rectangle(mx, my, 470, 340, 810, 398)) {
                global.gdf_sound_enabled = !global.gdf_sound_enabled;
                scr_update_audio_state();
                if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
            } else if (point_in_rectangle(mx, my, 470, 434, 540, 492)) {
                global.gdf_master_volume = clamp(global.gdf_master_volume - 0.1, 0, 1);
                scr_update_audio_state();
                if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
            } else if (point_in_rectangle(mx, my, 740, 434, 810, 492)) {
                global.gdf_master_volume = clamp(global.gdf_master_volume + 0.1, 0, 1);
                scr_update_audio_state();
                if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
            } else if (point_in_rectangle(mx, my, 470, 548, 810, 606)) {
                global.gdf_menu_mode = "main";
                if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
            }
        } else if (global.gdf_menu_mode == "credits") {
            if (point_in_rectangle(mx, my, 470, 548, 810, 606)) {
                global.gdf_menu_mode = "main";
                if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
            }
        }
    }
} else if (room == rm_stage_select) {
    if (clicked) {
        if (point_in_rectangle(mx, my, 40, 626, 220, 676)) {
            if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
            global.gdf_menu_mode = "main";
            room_goto(rm_menu);
            exit;
        }

        for (var i = 0; i < 3; i++) {
            var x1 = 100 + i * 370;
            var y1 = 150;
            if (point_in_rectangle(mx, my, x1, y1, x1 + 340, y1 + 430)) {
                global.gdf_stage_index = i;
                if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
                room_goto(rm_game);
            }
        }
    }
} else if (room == rm_game) {
    if (!variable_global_exists("gdf") || !variable_struct_exists(global.gdf, "game_active")) {
        scr_init_stage(global.gdf_stage_index);
    }

    if (!variable_struct_exists(global.gdf, "paused")) global.gdf.paused = false;
    if (!variable_struct_exists(global.gdf, "pause_tab")) global.gdf.pause_tab = "main";

    if (global.gdf.paused) {
        if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("P"))) {
            global.gdf.paused = false;
            global.gdf.pause_tab = "main";
            if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
            exit;
        }

        if (clicked) {
            if (global.gdf.pause_tab == "encyclopedia") {
                if (point_in_rectangle(mx, my, 530, 550, 750, 602)) {
                    global.gdf.pause_tab = "main";
                    if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
                }
            } else {
                if (point_in_rectangle(mx, my, 490, 214, 790, 262)) {
                    global.gdf.paused = false;
                    if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
                } else if (point_in_rectangle(mx, my, 490, 274, 790, 322)) {
                    if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
                    scr_init_stage(global.gdf_stage_index);
                } else if (point_in_rectangle(mx, my, 490, 334, 790, 382)) {
                    global.gdf.pause_tab = "encyclopedia";
                    if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
                } else if (point_in_rectangle(mx, my, 490, 394, 790, 442)) {
                    global.gdf_sound_enabled = !global.gdf_sound_enabled;
                    scr_update_audio_state();
                    if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
                } else if (point_in_rectangle(mx, my, 490, 454, 790, 502)) {
                    global.gdf_menu_mode = "main";
                    if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
                    room_goto(rm_menu);
                }
            }
        }
        exit;
    }

    if (keyboard_check_pressed(ord("P")) || keyboard_check_pressed(ord("M")) || (clicked && point_in_rectangle(mx, my, 1130, 590, 1248, 626))) {
        global.gdf.paused = true;
        global.gdf.pause_tab = "main";
        if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
        exit;
    }

    if (keyboard_check_pressed(ord("H"))) {
        global.gdf.tutorial_active = true;
        global.gdf.tutorial_step = 0;
    }

    if (variable_struct_exists(global.gdf, "tutorial_active") && global.gdf.tutorial_active) {
        if (keyboard_check_pressed(vk_escape) || (clicked && point_in_rectangle(mx, my, 430, 505, 625, 560))) {
            global.gdf.tutorial_active = false;
            global.gdf_tutorial_seen = true;
            global.gdf.alert = "Tutorial pulado. Use H para rever.";
            global.gdf.alert_timer = 120;
        } else if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter) || (clicked && point_in_rectangle(mx, my, 655, 505, 850, 560))) {
            global.gdf.tutorial_step += 1;
            if (global.gdf.tutorial_step > 3) {
                global.gdf.tutorial_active = false;
                global.gdf_tutorial_seen = true;
                global.gdf.alert = "Tutorial concluído. Escolha uma ação e restaure a região.";
                global.gdf.alert_timer = 160;
            }
        }
        exit;
    }

    if (variable_struct_exists(global.gdf, "dialogue_timer") && global.gdf.dialogue_timer > 0) {
        if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_right) || clicked) {
            global.gdf.dialogue_timer = 0;
            global.gdf.alert = "Escolha uma ação ambiental ou use as teclas 1 a 8.";
            global.gdf.alert_timer = 120;
        }
        exit;
    }

    if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("N"))) {
        scr_next_turn(self);
    }

    if (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right)) {
        global.gdf.selected_action = "";
        global.gdf.selected_label = "";
        global.gdf.action_preview = "";
        global.gdf.alert = "Ação cancelada.";
        global.gdf.alert_timer = 80;
    }

    if (keyboard_check_pressed(ord("1"))) scr_select_action("plant", "Plantar");
    if (keyboard_check_pressed(ord("2"))) scr_select_action("clean", "Limpar");
    if (keyboard_check_pressed(ord("3"))) scr_select_action("solar", "Solar");
    if (keyboard_check_pressed(ord("4"))) scr_select_action("recycle", "Reciclar");
    if (keyboard_check_pressed(ord("5"))) scr_select_action("purify", "Purificar");
    if (keyboard_check_pressed(ord("6"))) scr_select_action("corridor", "Corredor");
    if (keyboard_check_pressed(ord("7"))) scr_select_action("scan", "Escanear");
    if (keyboard_check_pressed(ord("8"))) scr_select_action("repair", "Reparar");

    if (keyboard_check_pressed(ord("L"))) scr_select_action("clean", "Limpar");
    if (keyboard_check_pressed(ord("C"))) scr_select_action("corridor", "Corredor");

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
