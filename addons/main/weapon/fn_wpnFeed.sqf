/*
    Fonksiyon: TAC_fnc_wpnFeed
    Çalışma yeri: İstemci

    "Kayışı yerleştir ve kapağı kapat": MG'nin besleme kapağı adımı. 4 sn x bakım süresi çarpanı,
    silah hareketi ve ses (TAC_fnc_wpnRun). Bitince silah beslemeye hazırdır.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = [_unit] call TAC_fnc_wpnTargetWeapon;
if (_weapon isEqualTo "") exitWith {};

[_unit, "Kayış yerleştiriliyor, kapak kapatılıyor...", 4 * TAC_wpn_cleanTimeMult, {
    params ["_unit", "_args"];
    _args params ["_weapon"];

    ([_unit, _weapon] call TAC_fnc_wpnGetState) set [7, true];
}, [_weapon], "feed"] call TAC_fnc_wpnRun;
