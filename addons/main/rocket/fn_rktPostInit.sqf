/*
    Fonksiyon: TAC_fnc_rktPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    Roketatar sisteminin istemci kurulumu:
      1. CBA "unit" oyuncu olayı: Fired / Reloaded olayları ve ACE "DefaultAction" ateşlenmeme dinleyicisi
         yeni birime bağlanır (TAC_fnc_rktAttach).
      2. ACE self-menü "Roketatar": İncele | Atışa hazırla | Mühimmatı kurula | Ateşlenmeyen mühimmatı çıkar (bekleme bittiyse görünür).
    10 sn aralıklı tek bir PFH mühimmat nemini günceller (fırlatıcı yoksa anında çıkar).

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
        // Yalnizca fırlatici ELDE secili ve yuklu muhimmat (roket basligi) varken
        && {(currentWeapon _player) isEqualTo (secondaryWeapon _player)}
        && {(_player ammo (secondaryWeapon _player)) > 0}
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

// Atis hazirligi: silaha ve basliga ozel prosedur. Menude yalnizca KALAN adimlar, ALFABETIK sirayla listelenir
// (dogru sirayi oyuncu bilmelidir); yanlis sirada yapilan adim prosedürü sifirlar.
private _prepare = [
    "TAC_rkt_prepare",
    "Atış hazırlığı prosedürü",
    "",
    {},
    {
        params ["_target", "_player"];

        private _weapon = secondaryWeapon _player;

        TAC_rkt_prepare
        && {time >= (_player getVariable ["TAC_wpn_busyUntil", 0])}
        && {(_player ammo _weapon) > 0}
        && {!(([_player, _weapon] call TAC_fnc_rktGetState) select 5)}
    },
    {
        params ["_target", "_player"];

        private _weapon = secondaryWeapon _player;
        private _mags = secondaryWeaponMagazine _player;
        private _magazine = if (_mags isEqualTo []) then {currentMagazine _player} else {_mags select 0};
        private _steps = [_weapon, _magazine] call TAC_fnc_rktPrepSteps;
        private _progress = ([_player, _weapon] call TAC_fnc_rktGetState) param [10, 0];
        private _list = [];

        {
            if (_forEachIndex >= _progress) then {_list pushBack [_x select 0, _forEachIndex]};
        } forEach _steps;

        _list sort true;

        _list apply {
            _x params ["_label", "_index"];

            [[
                format ["TAC_rkt_step_%1", _index],
                _label,
                "",
                {
                    params ["_target", "_player", "_index"];
                    [_player, _index] call TAC_fnc_rktStep;
                },
                {true},
                {},
                _index
            ] call ace_interact_menu_fnc_createAction, [], _target]
        }
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_rkt_menu"], _prepare, true] call ace_interact_menu_fnc_addActionToClass;

private _dry = [
    "TAC_rkt_dry",
    "Mühimmatı kurula",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_rktDry;
    },
    {
        params ["_target", "_player"];

        time >= (_player getVariable ["TAC_wpn_busyUntil", 0])
        && {(_player getVariable ["TAC_rkt_moist", 0]) > 10}
        && {[_player, "TAC_WeaponCleaningKit"] call TAC_fnc_wpnHasItem}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_rkt_menu"], _dry, true] call ace_interact_menu_fnc_addActionToClass;

[TAC_fnc_rktTick, 10] call CBA_fnc_addPerFrameHandler;

private _battery = [
    "TAC_rkt_battery",
    "Pili değiştir",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_rktBattery;
    },
    {
        params ["_target", "_player"];

        private _weapon = secondaryWeapon _player;

        TAC_rkt_guided
        && {time >= (_player getVariable ["TAC_wpn_busyUntil", 0])}
        && {(([_weapon] call TAC_fnc_rktProfile) select 0) isEqualTo "guided"}
        && {[_player, "TAC_MissileBattery"] call TAC_fnc_wpnHasItem}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_rkt_menu"], _battery, true] call ace_interact_menu_fnc_addActionToClass;

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
