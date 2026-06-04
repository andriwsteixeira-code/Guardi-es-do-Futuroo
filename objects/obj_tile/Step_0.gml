if (event_timer > 0) event_timer -= 1;
if (pop > 0) pop = max(0, pop - 0.08);

if (room == rm_game && point_in_rectangle(mouse_x, mouse_y, x, y, x + 64, y + 64)) {
    var kind_label = tile_kind;
    switch (tile_kind) {
        case "soil": kind_label = "solo"; break;
        case "dry": kind_label = "terra seca"; break;
        case "forest": kind_label = "floresta"; break;
        case "grass": kind_label = "grama"; break;
        case "water": kind_label = "água"; break;
    }

    var state_label = tile_state;
    switch (tile_state) {
        case "polluted": state_label = "poluído"; break;
        case "recovering": state_label = "em recuperação"; break;
        case "recovered": state_label = "recuperado"; break;
    }

    var label = "Célula " + string(grid_x + 1) + "," + string(grid_y + 1) + "\n" + kind_label + " | " + state_label;
    if (building != "") {
        var building_label = building;
        switch (building) {
            case "solar": building_label = "painel solar"; break;
            case "recycle": building_label = "reciclagem"; break;
            case "purifier": building_label = "purificador"; break;
            case "lab": building_label = "laboratório"; break;
            case "damaged": building_label = "estrutura danificada"; break;
        }
        label += "\nEstrutura: " + building_label;
    }

    if (variable_struct_exists(global.gdf, "selected_action") && global.gdf.selected_action != "") {
        var preview = scr_action_preview(global.gdf.selected_action, self);
        if (string_length(preview) > 42) preview = string_copy(preview, 1, 39) + "...";
        label += "\n" + preview;
    }
    scr_show_tooltip(label, device_mouse_x_to_gui(0) + 16, device_mouse_y_to_gui(0) + 18);
}
