/*
    Fonksiyon: TAC_fnc_wpnPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    Silah bakım sisteminin istemci kurulumu:
      1. CBA "unit" oyuncu olayı: birim değişince (respawn) "Fired" dinleyicisini yeniden bağlar.
      2. CBA yerel olayı "ace_weaponJammed" (ACE'nin ısı arızası dahil her arıza): son arıza türü ve
         zamanı kartta görünsün diye kaydedilir.
      3. ACE self-menü "Silah Bakımı": İncele | Temizle | Yağla | Arızayı gider (ayrıntılı) | Parça değiştir.
    Sürekli döngü yok.

    Parametreler: yok
    Dönüş: yok
*/

if (isNil "TAC_wpn_catCache") then {TAC_wpn_catCache = createHashMap};
if (isNil "TAC_wpn_mgSet") then {[TAC_wpn_mgTable] call TAC_fnc_wpnParseMgTable};

["unit", {
    params ["_newUnit", "_oldUnit"];
    [_newUnit, _oldUnit] call TAC_fnc_wpnAttach;
}, true] call CBA_fnc_addPlayerEventHandler;

// ACE: [unit, weapon, jamType]
["ace_weaponJammed", {
    params ["_unit", "_weapon", "_type"];

    if (!(_unit isEqualTo ACE_player)) exitWith {};

    private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;

    // Test gostergesi: arizayi kim uretti? (bizim kir/yag/asinma sistemi mi, ACE'nin isi arizasi mi)
    if (TAC_wpn_debug && {(time - (missionNamespace getVariable ["TAC_wpn_ownJam", -10])) > 0.5}) then {
        systemChat format [
            "[TAC silah] ARIZA %1 | KAYNAK: ACE (isi/diger) | namlu sicakligi %2",
            _type,
            round (_unit getVariable [format ["ace_overheating_%1_temp", _weapon], 0])
        ];
    };

    _state set [4, _type];
    _state set [5, time];
    _state set [6, (_state select 6) + 1];
}] call CBA_fnc_addEventHandler;

// ----------------------------------------------------------------------------
// ACE self-menu: Silah Bakimi
// ----------------------------------------------------------------------------
private _menu = [
    "TAC_wpn_menu",
    "Silah Bakımı",
    "\a3\ui_f\data\gui\rsc\rscdisplayarsenal\primaryweapon_ca.paa",
    {},
    {
        params ["_target", "_player"];

        TAC_wpn_enabled
        && {alive _player}
        && {!(_player getVariable ["ACE_isUnconscious", false])}
        && {isNull objectParent _player}
        && {!(([_player] call TAC_fnc_wpnTargetWeapon) isEqualTo "")}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions"], _menu, true] call ace_interact_menu_fnc_addActionToClass;

private _inspect = [
    "TAC_wpn_inspect",
    "Silahı incele",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_wpnInspect;
    },
    {true}
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_wpn_menu"], _inspect, true] call ace_interact_menu_fnc_addActionToClass;

private _clean = [
    "TAC_wpn_clean",
    "Silahı temizle",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_wpnClean;
    },
    {
        params ["_target", "_player"];

        time >= (_player getVariable ["TAC_wpn_busyUntil", 0])
        && {[_player, "TAC_WeaponCleaningKit"] call TAC_fnc_wpnHasItem}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_wpn_menu"], _clean, true] call ace_interact_menu_fnc_addActionToClass;

private _lube = [
    "TAC_wpn_lube",
    "Silahı yağla",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_wpnLube;
    },
    {
        params ["_target", "_player"];

        time >= (_player getVariable ["TAC_wpn_busyUntil", 0])
        && {[_player, "TAC_WeaponOil"] call TAC_fnc_wpnHasItem}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_wpn_menu"], _lube, true] call ace_interact_menu_fnc_addActionToClass;

private _feed = [
    "TAC_wpn_feed",
    "Kayışı yerleştir, kapağı kapat",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_wpnFeed;
    },
    {
        params ["_target", "_player"];

        // Yalnizca ELDE secili kayisli MG varken ve kayis yerlestirilmediyse gorunur.
        private _weapon = currentWeapon _player;

        TAC_mg_feedStep
        && {time >= (_player getVariable ["TAC_wpn_busyUntil", 0])}
        && {[_weapon] call TAC_fnc_wpnIsBeltFed}
        && {!(([_player, _weapon] call TAC_fnc_wpnGetState) param [7, true])}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_wpn_menu"], _feed, true] call ace_interact_menu_fnc_addActionToClass;

private _clearJam = [
    "TAC_wpn_clearJam",
    "Arızayı gider (ayrıntılı)",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_wpnClearJam;
    },
    {
        params ["_target", "_player"];

        time >= (_player getVariable ["TAC_wpn_busyUntil", 0])
        && {(currentWeapon _player) in (_player getVariable ["ace_overheating_jammedWeapons", []])}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_wpn_menu"], _clearJam, true] call ace_interact_menu_fnc_addActionToClass;

private _parts = [
    "TAC_wpn_parts",
    "Parça değiştir",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_wpnReplaceParts;
    },
    {
        params ["_target", "_player"];

        time >= (_player getVariable ["TAC_wpn_busyUntil", 0])
        && {[_player] call TAC_fnc_wpnIsArmorer}
        && {[_player, "TAC_WeaponSpareParts"] call TAC_fnc_wpnHasItem}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_wpn_menu"], _parts, true] call ace_interact_menu_fnc_addActionToClass;

diag_log format ["[TAC][WPN] hazir | ACE jamWeapon: %1", !isNil "ace_overheating_fnc_jamWeapon"];
