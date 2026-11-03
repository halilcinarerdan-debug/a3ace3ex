/*
    Fonksiyon: TAC_fnc_wpnDebug
    Çalışma yeri: İstemci (debug konsolu: "Yerel çalıştır")

    Silah bakım sisteminin durumunu döker: ayarlar, ACE overheating var mı, hedef silahın kategorisi,
    sayısal durumu (kir/yağ/aşınma), şu anki ortam çarpanı ve hesaplanan arıza ihtimali. Çıktı ekrana,
    RPT'ye ("[TAC][WPN-DEBUG]") ve panoya gider.

    Kullanım:
        call TAC_fnc_wpnDebug
    Durumu elle ayarlamak için (debug konsolu):
        ([ACE_player, currentWeapon ACE_player] call TAC_fnc_wpnGetState) set [0, 80]    // kir
        ([ACE_player, currentWeapon ACE_player] call TAC_fnc_wpnGetState) set [1, 10]    // yag
        ([ACE_player, currentWeapon ACE_player] call TAC_fnc_wpnGetState) set [2, 14000] // asinma

    Parametreler: yok
    Dönüş: STRING - rapor
*/

private _unit = ACE_player;
private _weapon = [_unit] call TAC_fnc_wpnTargetWeapon;

private _lines = [
    "== TAC SILAH BAKIM DEBUG ==",
    format ["Surum (yuklu PBO): %1", getText (configFile >> "CfgPatches" >> "tac_main" >> "versionStr")],
    format ["Aktif: %1 | test modu: %2 (x%3) | malzeme gerekli: %4 | silahci: %5", TAC_wpn_enabled, TAC_wpn_testMode, TAC_wpn_testMult, TAC_wpn_needKit, [_unit] call TAC_fnc_wpnIsArmorer],
    format ["ACE overheating arizasi (jamWeapon) var: %1 | ACE arizali silahlar: %2", !isNil "ace_overheating_fnc_jamWeapon", _unit getVariable ["ace_overheating_jammedWeapons", []]],
    format ["Oranlar: kir %1/1000 atis | yag kaybi %2/1000 | max ariza %3%% | parca omru %4 | susturucu x%5 | MG esigi %6", TAC_wpn_dirtRate, TAC_wpn_lubeLoss, TAC_wpn_jamMax, TAC_wpn_wearLife, TAC_wpn_suppressorMult, TAC_wpn_mgThreshold],
    format ["Ortam etkisi: %1 | su an ortam carpani: x%2", TAC_wpn_env, [_unit] call TAC_fnc_wpnEnvFactor]
];

if (_weapon isEqualTo "") then {
    _lines pushBack "Takip edilen silah yok (hedef silah bos).";
} else {
    private _cat = [_weapon] call TAC_fnc_wpnCategory;
    private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;

    _lines pushBack format ["Hedef silah: %1 | kategori: %2", _weapon, _cat];
    _lines pushBack format ["Durum [kir, yag, asinma, son temizlikten atis, son ariza turu, son ariza zamani, ariza sayisi]: %1", _state];
    _lines pushBack format ["Ariza ihtimali (atis basina, ortam dahil): %1%%", (round (([_state, [_unit] call TAC_fnc_wpnEnvFactor] call TAC_fnc_wpnJamChance) * 10000)) / 100];
    _lines pushBack format ["ACE namlu sicakligi: %1", _unit getVariable [format ["ace_overheating_%1_temp", _weapon], 0]];
};

_lines pushBack format ["Bakim malzemeleri envanterde: kit %1 | yag %2 | parca %3", "TAC_WeaponCleaningKit" in (items _unit), "TAC_WeaponOil" in (items _unit), "TAC_WeaponSpareParts" in (items _unit)];

private _report = _lines joinString endl;

diag_log ("[TAC][WPN-DEBUG]" + endl + _report);
copyToClipboard _report;
hint _report;

_report
