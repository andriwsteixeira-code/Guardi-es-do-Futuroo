function scr_update_tile_state(_tile) {
    if (_tile == noone || !instance_exists(_tile)) return;

    if (_tile.tile_kind == "water") {
        _tile.sprite_index = (_tile.tile_state == "recovered") ? spr_tile_clean_water : spr_tile_polluted_water;
    } else if (_tile.tile_kind == "forest") {
        _tile.sprite_index = spr_tile_forest;
    } else if (_tile.tile_kind == "grass") {
        _tile.sprite_index = spr_tile_healthy_grass;
    } else if (_tile.tile_kind == "dry") {
        _tile.sprite_index = spr_tile_dry_earth;
    } else {
        if (_tile.tile_state == "polluted") _tile.sprite_index = spr_tile_polluted_soil;
        else if (_tile.tile_state == "recovering") _tile.sprite_index = spr_tile_recovering_soil;
        else _tile.sprite_index = spr_tile_recovered_soil;
    }
    _tile.image_speed = 0;
}
