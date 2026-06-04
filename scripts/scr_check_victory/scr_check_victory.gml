function scr_check_victory(_game) {
    if (!variable_global_exists("gdf")) return false;
    var stage_goal_ok = true;
    if (variable_struct_exists(global.gdf, "stage_goal_target")) {
        stage_goal_ok = global.gdf.stage_goal_current >= global.gdf.stage_goal_target;
    }
    return global.gdf.pollution <= global.gdf.target_pollution
        && global.gdf.biodiversity >= global.gdf.target_biodiversity
        && global.gdf.water >= global.gdf.target_water
        && global.gdf.support > 0
        && stage_goal_ok;
}
