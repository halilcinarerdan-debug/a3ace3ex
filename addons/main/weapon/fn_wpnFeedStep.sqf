/*
    Fonksiyon: TAC_fnc_wpnFeedStep
    Çalışma yeri: İstemci

    Kayışlı MG'nin besleme prosedüründe BİR adımı yapar. Adımlar silaha özeldir (TAC_fnc_wpnFeedSteps: M249,
    M240 / M60, PKM, MG3...) ve menüde alfabetik sırayla listelenir: doğru sırayı oyuncu bilmelidir. Seçilen adım
    kendi çubuğu, hareketi ve sesiyle yapılır. Bitince doğru sıradaki adımsa ilerleme +1, son adım bitince silah
    beslemeye hazır olur; yanlış sıradaysa ilerleme sıfırlanır, prosedür baştan başlar (kısa mesaj).

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: NUMBER - adımın prosedürdeki sıra numarası (0'dan)

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_index", 0, [0]]];

private _weapon = currentWeapon _unit;
if !([_weapon] call TAC_fnc_wpnIsBeltFed) exitWith {};

private _steps = [_weapon] call TAC_fnc_wpnFeedSteps;
if (_index < 0 || {_index >= count _steps}) exitWith {};

(_steps select _index) params ["_label", "_seconds"];

[_unit, _label + "...", _seconds * TAC_wpn_cleanTimeMult, {
    params ["_unit", "_args"];
    _args params ["_weapon", "_index", "_count"];

    private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;
    private _progress = _state param [8, 0];

    if (_index != _progress) exitWith {
        _state set [8, 0];
        ["Hatalı sıra: prosedür baştan başlamalı."] call ace_common_fnc_displayTextStructured;
    };

    if ((_progress + 1) >= _count) then {
        _state set [7, true];
        _state set [8, 0];
    } else {
        _state set [8, _progress + 1];
    };
}, [_weapon, _index, count _steps], "feed"] call TAC_fnc_wpnRun;
