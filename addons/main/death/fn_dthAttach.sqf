/*
    Fonksiyon: TAC_fnc_dthAttach
    Çalışma yeri: İstemci (CBA "unit" oyuncu olayı)

    Oyuncu birimine "Killed" (ölünce efekt başlar) ve "AnimStateChanged" (yere düşünce / kalkınca) olaylarını bağlar,
    eskisinden kaldırır. YENİDEN DOĞMA: birim değişince ve efekt sürüyorsa efekt KESİLMEZ; yeni (canlı) bedende
    TAC_dth_respawnFade sürede yumuşakça söndürülür (sesler de aynı sürede geri açılır).

    Parametreler:
        0: OBJECT - yeni birim
        1: OBJECT - eski birim

    Dönüş: yok
*/

params [["_newUnit", objNull, [objNull]], ["_oldUnit", objNull, [objNull]]];

if (!isNull _oldUnit) then {
    {
        _x params ["_event", "_var"];
        private _id = _oldUnit getVariable [_var, -1];

        if (_id >= 0) then {_oldUnit removeEventHandler [_event, _id]};
        _oldUnit setVariable [_var, -1];
    } forEach [["Killed", "TAC_dth_ehKilled"], ["AnimStateChanged", "TAC_dth_ehAnim"]];
};

if (isNull _newUnit) exitWith {};

// Yeniden dogma / birim degisimi: efekt kesilmez, yumusakca soner
if ((missionNamespace getVariable ["TAC_dth_active", false]) && {alive _newUnit}) then {
    [TAC_dth_respawnFade] call TAC_fnc_dthEnd;
};

if ((_newUnit getVariable ["TAC_dth_ehKilled", -1]) >= 0) exitWith {};

_newUnit setVariable ["TAC_dth_ehKilled", _newUnit addEventHandler ["Killed", {
    ["death"] call TAC_fnc_dthStart;
}]];

_newUnit setVariable ["TAC_dth_ehAnim", _newUnit addEventHandler ["AnimStateChanged", {
    _this call TAC_fnc_dthOnAnim;
}]];
