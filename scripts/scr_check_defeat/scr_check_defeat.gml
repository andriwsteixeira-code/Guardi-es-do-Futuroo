function scr_check_defeat(_game) {
    if (!variable_global_exists("gdf")) return "";
    if (global.gdf.pollution >= global.gdf.critical_pollution) return "Poluição crítica";
    if (global.gdf.water <= 0) return "Água acabou";
    if (global.gdf.energy <= 0) return "Energia acabou";
    if (global.gdf.support <= 0) return "Apoio social chegou a zero";
    if (global.gdf.turn > global.gdf.max_turns) return "Turnos acabaram";
    return "";
}
