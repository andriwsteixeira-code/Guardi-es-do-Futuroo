function scr_make_report(_result, _reason) {
    if (!variable_global_exists("gdf")) return;

    global.gdf.report_result = _result;
    global.gdf.report_reason = _reason;

    var _score = 0;
    _score += 100 - global.gdf.pollution;
    _score += global.gdf.biodiversity;
    _score += global.gdf.water * 0.35;
    _score += global.gdf.energy * 0.25;
    _score += global.gdf.support * 0.4;
    _score -= max(0, global.gdf.turn - 10) * 2;

    if (_score >= 175) global.gdf.report_grade = "S";
    else if (_score >= 145) global.gdf.report_grade = "A";
    else if (_score >= 115) global.gdf.report_grade = "B";
    else global.gdf.report_grade = "C";

    if (_result == "Vitória") {
        global.gdf.report_stars = 1;
        if (global.gdf.pollution <= global.gdf.target_pollution - 5 && global.gdf.biodiversity >= global.gdf.target_biodiversity + 6) {
            global.gdf.report_stars += 1;
        }
        if (global.gdf.turn <= 12 && global.gdf.water >= global.gdf.target_water + 6 && global.gdf.support >= 40) {
            global.gdf.report_stars += 1;
        }
        audio_play_sound(snd_success, 1, false);
        global.gdf.report_message = "Você restaurou a região com decisões em cadeia. " + global.gdf.education;
        global.gdf.report_reward = "Recompensa desbloqueada: ";
        if (!variable_global_exists("gdf_rewards")) {
            global.gdf_rewards = { forest_guardian: false, industrial_clean: false, coastal_watch: false };
        }
        if (global.gdf.stage_index == 0) {
            global.gdf_rewards.forest_guardian = true;
            global.gdf.report_reward += "plantio eficiente.";
        } else if (global.gdf.stage_index == 1) {
            global.gdf_rewards.industrial_clean = true;
            global.gdf.report_reward += "energia solar aprimorada.";
        } else {
            global.gdf_rewards.coastal_watch = true;
            global.gdf.report_reward += "escaneamento costeiro avançado.";
        }
    } else {
        global.gdf.report_stars = 0;
        audio_play_sound(snd_fail, 1, false);
        global.gdf.report_message = "Equilibre água, energia e apoio antes de repetir ações. " + global.gdf.education;
        global.gdf.report_reward = "Sem recompensa: restaure a região para desbloquear melhorias.";
    }
}
