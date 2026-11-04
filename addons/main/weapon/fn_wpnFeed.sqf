/*
    Fonksiyon: TAC_fnc_wpnFeed
    Çalışma yeri: İstemci

    "Besleme kapağı prosedürü": elde seçili kayışlı MG'ye özel çok adımlı prosedür (TAC_fnc_wpnFeedSteps:
    M249 / M240 / M60 / PKM / MG3 / MMG... her biri kendi sırası ve süresiyle). Her adım kendi ilerleme çubuğu,
    silah hareketi ve sesiyle çalışır (TAC_fnc_wpnSteps). Son adım bitince silah beslemeye hazırdır.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = currentWeapon _unit;
if !([_weapon] call TAC_fnc_wpnIsBeltFed) exitWith {};

[_unit, [_weapon] call TAC_fnc_wpnFeedSteps, "feed", _weapon, {
    params ["_unit", "_args"];
    _args params ["_weapon"];

    ([_unit, _weapon] call TAC_fnc_wpnGetState) set [7, true];
}, [_weapon]] call TAC_fnc_wpnSteps;
