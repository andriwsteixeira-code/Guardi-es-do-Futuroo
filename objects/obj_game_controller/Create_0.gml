display_set_gui_size(1280, 720);
randomize();
global.gdf_font_ui = font_add("Arial", 20, false, false, 32, 255);
if (!variable_global_exists("gdf_tutorial_seen")) global.gdf_tutorial_seen = false;
var _selftest = false;
if (environment_get_variable("GDF_SELFTEST") == "1") _selftest = true;
for (var _param = 1; _param <= parameter_count(); _param++) {
    if (parameter_string(_param) == "--selftest") _selftest = true;
}
if (_selftest) {
    show_debug_message("SELFTEST_TRIGGERED");
    scr_run_self_tests();
    game_end();
    exit;
}
if (!variable_global_exists("gdf_stage_index")) global.gdf_stage_index = 0;
if (!variable_global_exists("gdf")) global.gdf = {};
if (!variable_global_exists("gdf_menu_mode")) global.gdf_menu_mode = "main";
if (!variable_global_exists("gdf_sound_enabled")) global.gdf_sound_enabled = true;
if (!variable_global_exists("gdf_master_volume")) global.gdf_master_volume = 0.8;
if (!variable_global_exists("gdf_rewards")) {
    global.gdf_rewards = {
        forest_guardian: false,
        industrial_clean: false,
        coastal_watch: false
    };
}
scr_update_audio_state();
if (room == rm_game) {
    scr_init_stage(global.gdf_stage_index);
}
