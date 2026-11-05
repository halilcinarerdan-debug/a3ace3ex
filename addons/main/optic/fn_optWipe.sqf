/*
    Fonksiyon: TAC_fnc_optWipe
    Çalışma yeri: İstemci

    "Optiği sil": birincil silahta kapalı lensli optik takılıysa 4 sn x bakım süresi çarpanı sürer.
    Bitince buğu sıfırlanır, kir %70 azalır (kalan lekeler tam temizlikte, "Silahı temizle", gider).
    Lens Bezi gerekir ("Bakım malzemesi gerekli" açıksa; tükenmez).

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = primaryWeapon _unit;

if (_weapon isEqualTo "" || {!((currentWeapon _unit) isEqualTo _weapon)} || {!([((primaryWeaponItems _unit) select 2)] call TAC_fnc_optIsSealed)}) exitWith {};

[_unit, "Optik siliniyor...", 4 * TAC_wpn_cleanTimeMult, {
    params ["_unit", "_args"];
    _args params ["_weapon"];

    private _state = [_unit, _weapon] call TAC_fnc_optGetState;

    _state set [0, 0];
    _state set [1, (_state select 1) * 0.3];

    if ([ACE_player] call TAC_fnc_optActive) then {
        [_state select 0, _state select 1] call TAC_fnc_optApply;
    };

    ["Optik silindi."] call ace_common_fnc_displayTextStructured;
}, [_weapon], "lens"] call TAC_fnc_wpnRun;
