if (room != rm_game || !variable_global_exists("gdf")) exit;
if (global.gdf.dialogue_timer <= 0) exit;
if (variable_struct_exists(global.gdf, "tutorial_active") && global.gdf.tutorial_active) exit;
if (variable_global_exists("gdf_font_ui") && global.gdf_font_ui != -1) draw_set_font(global.gdf_font_ui);

draw_set_alpha(0.96);
draw_set_color(make_colour_rgb(17, 38, 46));
draw_roundrect(58, 428, 760, 556, false);
draw_set_color(make_colour_rgb(95, 225, 169));
draw_rectangle(58, 428, 760, 434, false);
draw_set_alpha(1);
draw_sprite_ext(global.gdf.dialogue_portrait, 0, 124, 494, 0.40, 0.40, 0, c_white, 1);
draw_set_color(c_white);
draw_text_ext(194, 452, global.gdf.dialogue_text, 24, 530);
draw_set_color(make_colour_rgb(154, 225, 202));
draw_text_transformed(194, 526, "Espaço ou botão direito para fechar", 0.58, 0.58, 0);
