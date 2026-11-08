/*
    Fonksiyon: TAC_fnc_rktPanelClick
    Çalışma yeri: İstemci (panel düğmesi)

    Parçaya tıklamayı prosedür adımı olarak uygular (TAC_fnc_rktStepApply: sıra doğruysa ilerler, değilse
    prosedür baştan başlar). Durum satırı sonucu yazar; son adım bitince panel kısa süre sonra kapanır.
    Hızlı art arda tıklamalar 0.5 sn kilidiyle yok sayılır.

    Parametreler:
        0: NUMBER - adım numarası

    Dönüş: yok
*/

params [["_index", 0, [0]]];

if (time < (uiNamespace getVariable ["TAC_panel_lock", 0])) exitWith {};
uiNamespace setVariable ["TAC_panel_lock", time + 0.5];

private _unit = ACE_player;
private _weapon = secondaryWeapon _unit;

if (_weapon isEqualTo "" || {(_unit ammo _weapon) < 1} || {!((currentWeapon _unit) isEqualTo _weapon)}) exitWith {closeDialog 0};

private _state = [_unit, _weapon] call TAC_fnc_rktGetState;
if (_state select 5) exitWith {};

private _progress = _state param [10, 0];

(uiNamespace getVariable ["TAC_panel_data", [[], controlNull]]) params ["_data"];

private _partIndex = _data findIf {(_x select 0) == _index};
private _label = if (_partIndex < 0) then {""} else {(((_data select _partIndex) select 2) select 0) select 1};

[_unit, _index, true] call TAC_fnc_rktStepApply;

private _message = "";

if (_index != _progress) then {
    _message = format ["Hatalı sıra: %1. Prosedür baştan başlamalı.", _label];
} else {
    if (_state select 5) then {
        _message = "Fırlatıcı atışa hazır.";

        [{
            if (!isNull (findDisplay 91701)) then {closeDialog 0};
        }, [], 1.2] call CBA_fnc_waitAndExecute;
    };
};

[_message, 0.2] call TAC_fnc_rktPanelRefresh;
