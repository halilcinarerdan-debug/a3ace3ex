/*
    Fonksiyon: TAC_fnc_optPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır; silah bakım menüsünden SONRA)

    Optik buğu / kir sisteminin istemci kurulumu:
      1. CBA oyuncu olayları "cameraView", "weapon", "unit": optikten bakış başladı/bitti kontrolü
         (TAC_fnc_optRefresh). Döngü yalnızca optikten bakarken çalışır.
      2. ACE self-menü "Silah Bakımı > Optiği sil" (TAC_fnc_optWipe), Lens Bezi ister.

    Parametreler: yok
    Dönüş: yok
*/

["cameraView", {
    call TAC_fnc_optRefresh;
}] call CBA_fnc_addPlayerEventHandler;

["weapon", {
    call TAC_fnc_optRefresh;
}] call CBA_fnc_addPlayerEventHandler;

["unit", {
    call TAC_fnc_optStop;
}] call CBA_fnc_addPlayerEventHandler;

private _wipe = [
    "TAC_opt_wipe",
    "Optiği sil",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_optWipe;
    },
    {
        params ["_target", "_player"];

        TAC_opt_enabled
        && {time >= (_player getVariable ["TAC_wpn_busyUntil", 0])}
        && {(currentWeapon _player) isEqualTo (primaryWeapon _player)}
        && {[((primaryWeaponItems _player) select 2)] call TAC_fnc_optIsSealed}
        && {[_player, "TAC_LensCloth"] call TAC_fnc_wpnHasItem}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_wpn_menu"], _wipe, true] call ace_interact_menu_fnc_addActionToClass;

diag_log "[TAC][OPT] hazir";
