/*
    Fonksiyon: TAC_fnc_trtAttach
    Çalışma yeri: İstemci

    Oyuncu birimine bağlar, eskisinden kaldırır:
      - "FiredMan": sabit silahtan atış (TAC_fnc_trtOnFired)
      - ACE "DefaultAction" dinleyicisi: sabit silahta tetik çekilirken engel / zar (TAC_fnc_trtFireCheck / Do)

    Parametreler:
        0: OBJECT - yeni birim
        1: OBJECT - eski birim (olmayabilir)

    Dönüş: yok
*/

params [["_newUnit", objNull, [objNull]], ["_oldUnit", objNull, [objNull]]];

if (!isNull _oldUnit) then {
    private _id = _oldUnit getVariable ["TAC_trt_ehFired", -1];

    if (_id >= 0) then {_oldUnit removeEventHandler ["FiredMan", _id]};
    _oldUnit setVariable ["TAC_trt_ehFired", -1];

    private _actionId = _oldUnit getVariable ["TAC_trt_actionId", -1];

    if (_actionId != -1) then {
        [_oldUnit, "DefaultAction", _actionId] call ace_common_fnc_removeActionEventHandler;
    };

    _oldUnit setVariable ["TAC_trt_actionId", -1];
};

if (isNull _newUnit || {(_newUnit getVariable ["TAC_trt_ehFired", -1]) >= 0}) exitWith {};

_newUnit setVariable ["TAC_trt_ehFired", _newUnit addEventHandler ["FiredMan", {
    _this call TAC_fnc_trtOnFired;
}]];

_newUnit setVariable ["TAC_trt_actionId", [
    _newUnit,
    "DefaultAction",
    {_this call TAC_fnc_trtFireCheck},
    {_this call TAC_fnc_trtFireDo}
] call ace_common_fnc_addActionEventHandler];
