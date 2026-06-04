if (!variable_global_exists("gdf")) exit;
if (variable_struct_exists(global.gdf, "alert_timer") && global.gdf.alert_timer > 0) global.gdf.alert_timer -= 1;
if (variable_struct_exists(global.gdf, "tooltip") && global.gdf.tooltip.timer > 0) global.gdf.tooltip.timer -= 1;
if (variable_struct_exists(global.gdf, "feedback_timer") && global.gdf.feedback_timer > 0) global.gdf.feedback_timer -= 1;
if (variable_struct_exists(global.gdf, "dialogue_timer") && global.gdf.dialogue_timer > 0) global.gdf.dialogue_timer -= 1;
