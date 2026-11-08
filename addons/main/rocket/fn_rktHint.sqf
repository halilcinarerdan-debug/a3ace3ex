/*
    Fonksiyon: TAC_fnc_rktHint
    Çalışma yeri: İstemci

    Roket hazırlık görselini gösterir (etkileşim yok; adımlar ACE menüsünden). Çizim TAC_fnc_rktHintLayout'tan,
    durum roket durumundan alınır; çizim ve gösterim TAC_fnc_procHint'te.

    Parametreler:
        0: OBJECT - oyuncu birimi (yalnızca ACE_player için gösterilir)

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

if (!hasInterface || {!(_unit isEqualTo ACE_player)}) exitWith {};

private _layout = [_unit] call TAC_fnc_rktHintLayout;
if (_layout isEqualTo []) exitWith {};

private _state = [_unit, secondaryWeapon _unit] call TAC_fnc_rktGetState;

[_layout, _state select 5, _state param [10, 0]] call TAC_fnc_procHint;
