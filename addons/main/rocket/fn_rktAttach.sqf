/*
    Fonksiyon: TAC_fnc_rktAttach
    Çalışma yeri: İstemci

    Oyuncu birimine bağlar, eskisinden kaldırır:
      - "Fired" ve "Reloaded" olayları (atış sayacı, zar sıfırlama)
      - ACE "DefaultAction" eylem dinleyicisi: tetik çekilirken ateşlenmeme zarı
        (ace_common_fnc_addActionEventHandler; ACE'nin kendi arıza sisteminin kullandığı mekanizma,
        yalnızca oyuncu kontrolündeki birimde çalışır). Dinleyici kimliği birimde saklanır.

    Parametreler:
        0: OBJECT - yeni birim
        1: OBJECT - eski birim (olmayabilir)

    Dönüş: yok
*/

params [["_newUnit", objNull, [objNull]], ["_oldUnit", objNull, [objNull]]];

if (!isNull _oldUnit) then {
    {
        _x params ["_event", "_var"];
        private _id = _oldUnit getVariable [_var, -1];

        if (_id >= 0) then {_oldUnit removeEventHandler [_event, _id]};
        _oldUnit setVariable [_var, -1];
    } forEach [["Fired", "TAC_rkt_ehFired"], ["Reloaded", "TAC_rkt_ehReloaded"], ["Take", "TAC_rkt_ehTake"], ["Put", "TAC_rkt_ehPut"]];

    private _actionId = _oldUnit getVariable ["TAC_rkt_actionId", -1];

    if (_actionId != -1) then {
        [_oldUnit, "DefaultAction", _actionId] call ace_common_fnc_removeActionEventHandler;
    };

    _oldUnit setVariable ["TAC_rkt_actionId", -1];
};

if (isNull _newUnit || {(_newUnit getVariable ["TAC_rkt_ehFired", -1]) >= 0}) exitWith {};

_newUnit setVariable ["TAC_rkt_ehFired", _newUnit addEventHandler ["Fired", {
    _this call TAC_fnc_rktOnFired;
}]];

_newUnit setVariable ["TAC_rkt_ehReloaded", _newUnit addEventHandler ["Reloaded", {
    _this call TAC_fnc_rktOnReloaded;
}]];

_newUnit setVariable ["TAC_rkt_ehTake", _newUnit addEventHandler ["Take", {
    _this call TAC_fnc_rktOnTake;
}]];

_newUnit setVariable ["TAC_rkt_ehPut", _newUnit addEventHandler ["Put", {
    _this call TAC_fnc_rktOnPut;
}]];

_newUnit setVariable ["TAC_rkt_actionId", [
    _newUnit,
    "DefaultAction",
    {_this call TAC_fnc_rktMisfireCheck},
    {_this call TAC_fnc_rktMisfireDo}
] call ace_common_fnc_addActionEventHandler];
