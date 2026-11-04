/*
    Fonksiyon: TAC_fnc_trtPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    Sabit silah / taret sistemi kurulumu:
      1. CBA "unit" oyuncu olayı: FiredMan + ACE DefaultAction dinleyicisi (TAC_fnc_trtAttach)
      2. ACE etkileşim menüsü (sabit silaha bakıp ACE tuşuna basınca; 0. tip, "StaticWeapon" sınıfı):
         "Sabit silah bakımı / hazırlığı" (alt öğeler: TAC_fnc_trtChildren)
    Döngü yok.

    Parametreler: yok
    Dönüş: yok
*/

["unit", {
    params ["_newUnit", "_oldUnit"];
    [_newUnit, _oldUnit] call TAC_fnc_trtAttach;
}, true] call CBA_fnc_addPlayerEventHandler;

private _root = [
    "TAC_trt",
    "Sabit silah bakımı / hazırlığı",
    "",
    {},
    {
        params ["_target", "_player"];

        TAC_trt_enabled
        && {alive _target}
        && {!(_player getVariable ["ACE_isUnconscious", false])}
        && {time >= (_player getVariable ["TAC_wpn_busyUntil", 0])}
        && {!(([((_target weaponsTurret [0])) param [0, ""], _target] call TAC_fnc_trtKind) isEqualTo "other")}
    },
    {
        _this call TAC_fnc_trtChildren
    }
] call ace_interact_menu_fnc_createAction;

["StaticWeapon", 0, ["ACE_MainActions"], _root, true] call ace_interact_menu_fnc_addActionToClass;

diag_log "[TAC][TRT] hazir";
