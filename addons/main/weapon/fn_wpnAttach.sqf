/*
    Fonksiyon: TAC_fnc_wpnAttach
    Çalışma yeri: İstemci

    Oyuncu birimine olayları bağlar, eskisinden kaldırır. Yalnızca oyuncuya bağlı: yapay zekâ için
    maliyet yok.
      - "Fired": atış başına kir / yağ / aşınma ve arıza zarı (TAC_fnc_wpnOnFired)
      - "Put" / "Take": silah yere bırakılınca / alınınca bakım durumu silahla birlikte gider
        (TAC_fnc_wpnOnPut / TAC_fnc_wpnOnTake)

    Parametreler:
        0: OBJECT - yeni birim
        1: OBJECT - eski birim (olmayabilir)

    Dönüş: yok
*/

params [["_newUnit", objNull, [objNull]], ["_oldUnit", objNull, [objNull]]];

private _events = [
    ["Fired", "TAC_wpn_ehFired"],
    ["Put", "TAC_wpn_ehPut"],
    ["Take", "TAC_wpn_ehTake"]
];

if (!isNull _oldUnit) then {
    {
        _x params ["_event", "_var"];
        private _id = _oldUnit getVariable [_var, -1];

        if (_id >= 0) then {_oldUnit removeEventHandler [_event, _id]};
        _oldUnit setVariable [_var, -1];
    } forEach _events;
};

if (isNull _newUnit || {(_newUnit getVariable ["TAC_wpn_ehFired", -1]) >= 0}) exitWith {};

// Fired: [unit, weapon, muzzle, mode, ammo, magazine, projectile, gunner]
_newUnit setVariable ["TAC_wpn_ehFired", _newUnit addEventHandler ["Fired", {
    _this call TAC_fnc_wpnOnFired;
}]];

// Put / Take: [unit, container, item]
_newUnit setVariable ["TAC_wpn_ehPut", _newUnit addEventHandler ["Put", {
    _this call TAC_fnc_wpnOnPut;
}]];

_newUnit setVariable ["TAC_wpn_ehTake", _newUnit addEventHandler ["Take", {
    _this call TAC_fnc_wpnOnTake;
}]];
