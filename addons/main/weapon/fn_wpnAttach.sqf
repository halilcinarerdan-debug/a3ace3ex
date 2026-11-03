/*
    Fonksiyon: TAC_fnc_wpnAttach
    Çalışma yeri: İstemci

    Oyuncu birimine "Fired" olayını bağlar, eskisinden kaldırır. Yalnızca oyuncuya bağlı:
    yapay zekâ için maliyet yok.

    Parametreler:
        0: OBJECT - yeni birim
        1: OBJECT - eski birim (olmayabilir)

    Dönüş: yok
*/

params [["_newUnit", objNull, [objNull]], ["_oldUnit", objNull, [objNull]]];

if (!isNull _oldUnit) then {
    private _id = _oldUnit getVariable ["TAC_wpn_ehFired", -1];

    if (_id >= 0) then {_oldUnit removeEventHandler ["Fired", _id]};
    _oldUnit setVariable ["TAC_wpn_ehFired", -1];
};

if (isNull _newUnit || {(_newUnit getVariable ["TAC_wpn_ehFired", -1]) >= 0}) exitWith {};

// Fired: [unit, weapon, muzzle, mode, ammo, magazine, projectile, gunner]
_newUnit setVariable ["TAC_wpn_ehFired", _newUnit addEventHandler ["Fired", {
    _this call TAC_fnc_wpnOnFired;
}]];
