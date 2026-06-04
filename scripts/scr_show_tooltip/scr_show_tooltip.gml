function scr_show_tooltip(_text, _x, _y) {
    if (!variable_global_exists("gdf")) return;
    if (!variable_struct_exists(global.gdf, "tooltip")) {
        global.gdf.tooltip = { text: "", x: 0, y: 0, timer: 0 };
    }
    global.gdf.tooltip.text = _text;
    global.gdf.tooltip.x = _x;
    global.gdf.tooltip.y = _y;
    global.gdf.tooltip.timer = 3;
}
