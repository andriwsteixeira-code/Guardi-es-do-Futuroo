var sx = 1 + pop * 0.05;
draw_sprite_ext(sprite_index, 0, x + 32 - 32 * sx, y + 32 - 32 * sx, sx, sx, 0, c_white, 1);

var live_pulse = 1 + sin((current_time + grid_x * 173 + grid_y * 97) / 260) * 0.04;
if (tile_state == "recovered") {
    draw_set_alpha(0.20);
    draw_sprite_ext(spr_effect_green_particles, 0, x + 32, y + 30, 0.26 * live_pulse, 0.26 * live_pulse, 0, c_white, 1);
    draw_set_alpha(1);
} else if (tile_state == "polluted") {
    draw_set_alpha(0.12);
    draw_sprite_ext(spr_effect_toxic_smoke, 0, x + 32, y + 28, 0.22, 0.22, 0, c_white, 1);
    draw_set_alpha(1);
}

if (tile_kind == "water" && tile_state == "recovered") {
    draw_set_alpha(0.22);
    draw_sprite_ext(spr_effect_water_purification, 0, x + 32, y + 32, 0.22 * live_pulse, 0.22 * live_pulse, 0, c_white, 1);
    draw_set_alpha(1);
}

if (!scanned) {
    draw_set_alpha(0.12);
    draw_set_color(c_black);
    draw_rectangle(x, y, x + 64, y + 64, false);
    draw_set_alpha(1);
}

var building_sprite = -1;
switch (building) {
    case "solar": building_sprite = spr_building_solar_panel; break;
    case "recycle": building_sprite = spr_building_recycling_station; break;
    case "purifier": building_sprite = spr_building_water_purifier; break;
    case "lab": building_sprite = spr_building_ecology_lab; break;
    case "damaged": building_sprite = spr_building_clean_energy_station; break;
}

if (building_sprite != -1) {
    var bs = 0.36 + pop * 0.02;
    draw_set_alpha(0.22);
    draw_set_color(c_black);
    draw_ellipse(x + 12, y + 45, x + 52, y + 59, false);
    draw_set_alpha(1);
    draw_sprite_ext(building_sprite, 0, x + 32, y + 34, bs, bs, 0, c_white, 1);
    if (building == "damaged") {
        draw_sprite_ext(spr_effect_toxic_smoke, 0, x + 32, y + 24, 0.32, 0.32, 0, c_white, 0.85);
    } else if (building == "solar") {
        draw_set_alpha(0.34);
        draw_sprite_ext(spr_effect_clean_energy, 0, x + 32, y + 25, 0.22 * live_pulse, 0.22 * live_pulse, 0, c_white, 1);
        draw_set_alpha(1);
    }
}

if (event_timer > 0) {
    var a = min(1, event_timer / 25);
    switch (event_effect) {
        case "smoke": draw_sprite_ext(spr_effect_toxic_smoke, 0, x + 32, y + 30, 0.65, 0.65, 0, c_white, a); break;
        case "spill": draw_sprite_ext(spr_effect_toxic_spill, 0, x + 32, y + 32, 0.7, 0.7, 0, c_white, a); break;
        case "green": draw_sprite_ext(spr_effect_green_particles, 0, x + 32, y + 28, 0.65, 0.65, 0, c_white, a); break;
        case "energy": draw_sprite_ext(spr_effect_clean_energy, 0, x + 32, y + 28, 0.65, 0.65, 0, c_white, a); break;
        case "water": draw_sprite_ext(spr_effect_water_purification, 0, x + 32, y + 30, 0.65, 0.65, 0, c_white, a); break;
        case "scan": draw_sprite_ext(spr_icon_alert, 0, x + 32, y + 30, 0.7, 0.7, 0, c_white, a); break;
        case "alert": draw_sprite_ext(spr_icon_alert, 0, x + 32, y + 30, 0.7, 0.7, 0, c_white, a); break;
    }
}

if (point_in_rectangle(mouse_x, mouse_y, x, y, x + 64, y + 64)) {
    draw_set_color(make_colour_rgb(255, 255, 220));
    draw_set_alpha(0.9);
    draw_rectangle(x, y, x + 64, y + 64, true);
    draw_set_alpha(1);
}
