/*
    Fonksiyon: TAC_fnc_rktPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    Roketatar sisteminin istemci kurulumu:
      1. CBA "unit" oyuncu olayı: Fired / Reloaded olayları ve ACE "DefaultAction" ateşlenmeme dinleyicisi
         yeni birime bağlanır (TAC_fnc_rktAttach).
      2. ACE self-menü "Roketatar": İncele | Ateşlenmeyen mühimmatı çıkar (bekleme bittiyse görünür).
    Döngü yok.

    Parametreler: yok
    Dönüş: yok
*/

if (isNil "TAC_rkt_profileCache") then {TAC_rkt_profileCache = createHashMap};
if (isNil "TAC_rkt_map") then {[TAC_rkt_table] call TAC_fnc_rktParseTable};

["unit", {
    params ["_newUnit", "_oldUnit"];
    [_newUnit, _oldUnit] call TAC_fnc_rktAttach;
}, true] call CBA_fnc_addPlayerEventHandler;

private _menu = [
    "TAC_rkt_menu",
    "Roketatar",
    "\a3\ui_f\data\gui\rsc\rscdisplayarsenal\secondaryweapon_ca.paa",
    {},
    {
        params ["_target", "_player"];

        TAC_rkt_enabled
        && {alive _player}
        && {!(_player getVariable ["ACE_isUnconscious", false])}
        && {!((secondaryWeapon _player) isEqualTo "")}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions"], _menu, true] call ace_interact_menu_fnc_addActionToClass;

private _inspect = [
    "TAC_rkt_inspect",
    "Fırlatıcıyı / mühimmatı incele",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_rktInspect;
    },
    {true}
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_rkt_menu"], _inspect, true] call ace_interact_menu_fnc_addActionToClass;

private _remove = [
    "TAC_rkt_remove",
    "Ateşlenmeyen mühimmatı çıkar",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_rktRemoveRound;
    },
    {
        params ["_target", "_player"];

        private _state = [_player, secondaryWeapon _player] call TAC_fnc_rktGetState;

        time >= (_player getVariable ["TAC_wpn_busyUntil", 0])
        && {_state select 2}
        && {time >= (_state select 3)}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_rkt_menu"], _remove, true] call ace_interact_menu_fnc_addActionToClass;

diag_log "[TAC][RKT] hazir";
