if (room != rm_game) exit;
if (variable_global_exists("gdf_font_ui") && global.gdf_font_ui != -1) draw_set_font(global.gdf_font_ui);

var selected = variable_global_exists("gdf") && global.gdf.selected_action == action_id;
var no_plays = variable_global_exists("gdf")
    && variable_struct_exists(global.gdf, "action_points")
    && global.gdf.action_points <= 0
    && action_id != "next_turn"
    && action_id != "cancel";

var cost = scr_action_def(action_id);
var has_cost = !is_undefined(cost);
var affordable = true;
if (has_cost && variable_global_exists("gdf")) affordable = scr_can_pay(cost);

var base = make_colour_rgb(46, 143, 128);
var top = make_colour_rgb(107, 237, 183);
switch (action_id) {
    case "plant": base = make_colour_rgb(28, 198, 103); top = make_colour_rgb(115, 255, 166); break;
    case "clean": base = make_colour_rgb(34, 169, 236); top = make_colour_rgb(120, 226, 255); break;
    case "solar": base = make_colour_rgb(246, 176, 36); top = make_colour_rgb(255, 226, 99); break;
    case "recycle": base = make_colour_rgb(33, 190, 132); top = make_colour_rgb(101, 255, 190); break;
    case "purify": base = make_colour_rgb(22, 190, 226); top = make_colour_rgb(115, 242, 255); break;
    case "corridor": base = make_colour_rgb(96, 210, 70); top = make_colour_rgb(181, 255, 110); break;
    case "scan": base = make_colour_rgb(91, 136, 255); top = make_colour_rgb(171, 199, 255); break;
    case "repair": base = make_colour_rgb(238, 111, 54); top = make_colour_rgb(255, 174, 100); break;
    case "next_turn": base = make_colour_rgb(27, 211, 157); top = make_colour_rgb(132, 255, 207); break;
    case "cancel": base = make_colour_rgb(119, 137, 148); top = make_colour_rgb(189, 207, 216); break;
}

draw_set_alpha(0.70);
draw_set_color(c_black);
draw_roundrect(x + 4, y + 5, x + button_w + 4, y + button_h + 5, false);
draw_set_alpha(1);

var outline = make_colour_rgb(224, 255, 243);
if (hover) outline = c_white;
if (selected) outline = make_colour_rgb(255, 242, 116);
if (!affordable && !no_plays) outline = make_colour_rgb(255, 210, 82);
if (no_plays) outline = make_colour_rgb(154, 196, 204);

draw_set_color(outline);
draw_roundrect(x - 3, y - 3, x + button_w + 3, y + button_h + 3, false);

draw_set_color(make_colour_rgb(3, 17, 20));
draw_roundrect(x - 1, y - 1, x + button_w + 1, y + button_h + 1, false);
draw_set_color(base);
draw_roundrect(x, y, x + button_w, y + button_h, false);
draw_set_color(top);
draw_rectangle(x + 3, y + 3, x + button_w - 3, y + 19, false);

draw_set_alpha(0.82);
draw_set_color(make_colour_rgb(4, 22, 26));
draw_roundrect(x + 38, y + 25, x + button_w - 5, y + button_h - 5, false);
draw_set_alpha(1);

if (!affordable && !no_plays) {
    draw_set_alpha(0.20);
    draw_set_color(make_colour_rgb(255, 244, 158));
    draw_rectangle(x, y, x + button_w, y + button_h, false);
    draw_set_alpha(1);
}

if (no_plays) {
    draw_set_alpha(0.18);
    draw_set_color(make_colour_rgb(7, 20, 24));
    draw_rectangle(x, y, x + button_w, y + button_h, false);
    draw_set_alpha(1);
}

if (icon_sprite != -1) {
    draw_set_color(make_colour_rgb(8, 34, 38));
    draw_roundrect(x + 7, y + 24, x + 35, y + 52, false);
    draw_sprite_ext(icon_sprite, 0, x + 21, y + 38, 0.30, 0.30, 0, c_white, 1);
}

var hotkey = "";
switch (action_id) {
    case "plant": hotkey = "1"; break;
    case "clean": hotkey = "2"; break;
    case "solar": hotkey = "3"; break;
    case "recycle": hotkey = "4"; break;
    case "purify": hotkey = "5"; break;
    case "corridor": hotkey = "6"; break;
    case "scan": hotkey = "7"; break;
    case "repair": hotkey = "8"; break;
    case "next_turn": hotkey = "N"; break;
    case "cancel": hotkey = "Esc"; break;
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_colour_rgb(5, 23, 27));
if (hotkey != "") draw_text_transformed(x + 8, y + 5, hotkey, 0.58, 0.58, 0);

if (has_cost) {
    var cost_label = scr_action_badge_text(action_id);
    draw_set_halign(fa_right);
    draw_set_color(affordable ? make_colour_rgb(231, 255, 246) : make_colour_rgb(255, 226, 126));
    draw_roundrect(x + button_w - 58, y + 4, x + button_w - 5, y + 20, false);
    draw_set_color(affordable ? make_colour_rgb(5, 23, 27) : make_colour_rgb(89, 42, 0));
    draw_text_transformed(x + button_w - 8, y + 6, cost_label, 0.44, 0.44, 0);
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_colour_rgb(4, 24, 27));
draw_text_transformed(x + 77, y + 40 + 1, action_label, 0.62, 0.62, 0);
draw_set_color(c_white);
draw_text_transformed(x + 76, y + 40, action_label, 0.62, 0.62, 0);

if (!affordable && !no_plays) {
    draw_set_color(make_colour_rgb(255, 245, 158));
    draw_text_transformed(x + 76, y + 52, "faltam", 0.38, 0.38, 0);
}

if (no_plays) {
    draw_set_color(make_colour_rgb(255, 232, 122));
    draw_text_transformed(x + 76, y + 52, "sem jogadas", 0.38, 0.38, 0);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
