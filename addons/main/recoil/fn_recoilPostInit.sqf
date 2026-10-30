/*
    Fonksiyon: TAC_fnc_recoilPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    Dinamik recoil modülünün istemci kurulumu:
      - CBA "unit"    : birim değişince Fired/Reloaded dinleyicilerini yeniden bağlar (applyInitial).
      - CBA "weapon", "muzzle", "vehicle": silah/namlu/araç değişince çarpanı günceller.
    Döngü yok: her şey olay tabanlı. Atış başına maliyet: tek hashmap/string karşılaştırması.

    Parametreler: yok
    Dönüş: yok
*/

if (isNil "TAC_recoil_overrideMap") then {
    [TAC_recoil_overrides] call TAC_fnc_recoilParseOverrides;
};

["unit", {
    params ["_newUnit", "_oldUnit"];
    [_newUnit, _oldUnit] call TAC_fnc_recoilAttach;
}, true] call CBA_fnc_addPlayerEventHandler;

["weapon", {
    [_this select 0] call TAC_fnc_recoilUpdate;
}] call CBA_fnc_addPlayerEventHandler;

["muzzle", {
    [_this select 0] call TAC_fnc_recoilUpdate;
}] call CBA_fnc_addPlayerEventHandler;

["vehicle", {
    [_this select 0] call TAC_fnc_recoilUpdate;
}] call CBA_fnc_addPlayerEventHandler;

missionNamespace setVariable ["TAC_recoil_ready", true];

diag_log "[TAC][RECOIL] hazir";
