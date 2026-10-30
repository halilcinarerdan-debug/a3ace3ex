/*
    Fonksiyon: TAC_fnc_stressDebug
    Çalışma yeri: İstemci (debug konsolu: "Yerel çalıştır")

    Stres sisteminin durumunu döker: yüklü sürüm, hangi sway değişkeninin bulunduğu (ve değeri),
    ayarlar ve anlık seviye. Çıktı ekrana, RPT'ye ("[TAC][STRESS-DEBUG]") ve panoya gider.

    Kullanım:
        call TAC_fnc_stressDebug
    Stresi elle denemek için (debug konsolu):
        ["TAC_suppressed", [ACE_player, 2, objNull, ""]] call CBA_fnc_localEvent

    Parametreler: yok
    Dönüş: STRING - rapor
*/

private _var = call TAC_fnc_stressResolveVar;

private _lines = [
    "== TAC STRESS DEBUG ==",
    format ["Surum (yuklu PBO): %1", getText (configFile >> "CfgPatches" >> "tac_main" >> "versionStr")],
    format ["Bulunan sway degiskeni: '%1' (deger: %2)", _var, if (_var isEqualTo "") then {"-"} else {missionNamespace getVariable _var}],
    format ["Aday degiskenler: ace_common_swayFactor=%1 | ace_advanced_fatigue_swayFactor=%2 | setCustomAimCoef (getCustomAimCoef)=%3", missionNamespace getVariable ["ace_common_swayFactor", "yok"], missionNamespace getVariable ["ace_advanced_fatigue_swayFactor", "yok"], getCustomAimCoef ACE_player],
    format ["Aktif: %1 | maks carpan: %2 | esik mesafe: %3 m | artis: %4 | sonum: %5 sn | nabiz: %6 | dost: %7", TAC_stress_enabled, TAC_stress_maxMult, TAC_stress_range, TAC_stress_gain, TAC_stress_decay, TAC_stress_pulse, TAC_stress_friendly],
    format ["Seviye: %1 | temel: %2 | dongu (PFH): %3 | Suppressed dinleyici: %4", missionNamespace getVariable ["TAC_stress_level", 0], missionNamespace getVariable ["TAC_stress_base", "-"], missionNamespace getVariable ["TAC_stress_pfh", -1], ACE_player getVariable ["TAC_stress_ehSuppressed", -1]]
];

private _report = _lines joinString endl;

diag_log ("[TAC][STRESS-DEBUG]" + endl + _report);
copyToClipboard _report;
hint _report;

_report
