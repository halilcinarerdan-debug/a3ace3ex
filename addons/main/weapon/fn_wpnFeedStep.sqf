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
    _args params ["_weapon", "_index"];

    [_unit, _index] call TAC_fnc_wpnFeedApply;
}, [_weapon, _index], "feed"] call TAC_fnc_wpnRun;
