/*
    Fonksiyon: TAC_fnc_rktDry
    Çalışma yeri: İstemci

    "Mühimmatı kurula": 10 sn x bakım süresi çarpanı. Silah Bakım Kiti gerekir ("Bakım malzemesi gerekli"
    açıksa; tükenmez). Bitince taşınan roket / füze mühimmatının nemi %10'a iner.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = secondaryWeapon _unit;
if (_weapon isEqualTo "") exitWith {};

[_unit, "Mühimmat kurulanıyor...", 10 * TAC_wpn_cleanTimeMult, {
    params ["_unit"];

    _unit setVariable ["TAC_rkt_moist", (_unit getVariable ["TAC_rkt_moist", 0]) min 10];
    ["Mühimmat kurulandı."] call ace_common_fnc_displayTextStructured;
}, [_weapon], "rocket"] call TAC_fnc_wpnRun;
