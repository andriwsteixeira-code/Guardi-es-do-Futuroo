if (room != rm_game || !variable_global_exists("gdf")) exit;
if (variable_struct_exists(global.gdf, "tutorial_active") && global.gdf.tutorial_active) exit;
if (global.gdf.dialogue_timer > 0 && (keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_right))) {
    global.gdf.dialogue_timer = 0;
}
