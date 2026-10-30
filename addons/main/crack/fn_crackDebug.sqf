/*
    Fonksiyon: TAC_fnc_crackDebug
    Çalışma yeri: İstemci (debug konsolu: "Yerel çalıştır")

    Crack sisteminin durumunu döker: sürüm, ayarlar, HUD durumu, efekt halen sürüyor mu.
    Çıktı ekrana, RPT'ye ("[TAC][CRACK-DEBUG]") ve panoya gider.

    Kullanım:
        call TAC_fnc_crackDebug
    Efekti elle denemek için (debug konsolu):
        call TAC_fnc_crackStart
    Gerçek bir geçişi taklit etmek için:
        ["TAC_suppressed", [ACE_player, 1.5, objNull, "B_762x51_Ball", 800]] call CBA_fnc_localEvent

    Parametreler: yok
    Dönüş: STRING - rapor
*/

private _lines = [
    "== TAC CRACK DEBUG ==",
    format ["Surum (yuklu PBO): %1", getText (configFile >> "CfgPatches" >> "tac_main" >> "versionStr")],
    format ["Aktif: %1 | tetik mesafe: %2 m | min hiz: %3 m/s | sure: %4 sn | bekleme: %5 sn | dost: %6", TAC_crack_enabled, TAC_crack_dist, TAC_crack_minSpeed, TAC_crack_duration, TAC_crack_cooldown, TAC_crack_friendly],
    format ["Blur: %1 | vignette: %2 | HUD gizle: %3", TAC_crack_blur, TAC_crack_vignette, TAC_crack_hideHud],
    format ["Efekt suruyor: blur %1 | vignette kontrol sayisi %2 | HUD gizli %3", (missionNamespace getVariable ["TAC_crack_ppBlur", -1]) >= 0, count (missionNamespace getVariable ["TAC_crack_ctrls", []]), missionNamespace getVariable ["TAC_crack_hudHidden", false]],
    format ["Anlik HUD (shownHUD): %1", shownHUD],
    format ["Mission ekrani (display 46): %1", !isNull (findDisplay 46)],
    format ["Son tetik zamani: %1 (time %2)", missionNamespace getVariable ["TAC_crack_last", "-"], round time]
];

private _report = _lines joinString endl;

diag_log ("[TAC][CRACK-DEBUG]" + endl + _report);
copyToClipboard _report;
hint _report;

_report
