if (room != rm_game || !variable_global_exists("gdf")) exit;
if (variable_struct_exists(global.gdf, "tutorial_active") && global.gdf.tutorial_active) exit;
if (variable_struct_exists(global.gdf, "dialogue_timer") && global.gdf.dialogue_timer > 0) exit;
if (variable_struct_exists(global.gdf, "paused") && global.gdf.paused) exit;

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

hover = point_in_rectangle(mx, my, x, y, x + button_w, y + button_h);
if (hover) {
    if (!hover_sound_played) {
        hover_sound_played = true;
        if (global.gdf_sound_enabled) audio_play_sound(snd_action, 1, false);
    }
    var _tip = tooltip_text;
    var _cost = scr_action_def(action_id);
    if (!is_undefined(_cost)) {
        _tip += "\n" + scr_action_cost_text(action_id);
        if (!scr_can_pay(_cost)) _tip += "\n" + scr_missing_cost_text(_cost);
    }
    scr_show_tooltip(_tip, mx + 16, my - 70);
} else {
    hover_sound_played = false;
}

if (hover && mouse_check_button_pressed(mb_left)) {
    if (action_id == "next_turn") {
        audio_play_sound(snd_action, 1, false);
        scr_next_turn(instance_find(obj_game_controller, 0));
    } else if (action_id == "cancel") {
        global.gdf.selected_action = "";
        global.gdf.selected_label = "";
        global.gdf.action_preview = "";
        global.gdf.alert = "Ação cancelada.";
        global.gdf.alert_timer = 80;
        audio_play_sound(snd_action, 1, false);
    } else {
        scr_select_action(action_id, action_label);
    }
}
