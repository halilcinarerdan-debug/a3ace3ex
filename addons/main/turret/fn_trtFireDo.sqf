/*
    Fonksiyon: TAC_fnc_trtFireDo
    Çalışma yeri: İstemci (ACE "DefaultAction" ifadesi; yalnızca TAC_fnc_trtFireCheck true iken)

    Kuru tık sesi. Hazırlık / arıza engeli ise başka bir şey yapmaz; ateşlenmemede (güdümlü) bekleme süresi
    başlar (tetiğe tekrar basılırsa yeniden başlar).

    Parametreler (ACE ifadesi): [hedef, birim, ...]
    Dönüş: yok
*/

params ["", "_unit"];

private _veh = vehicle _unit;

playSound3D ["a3\sounds_f\weapons\Other\dry9.wss", objNull, false, getPosASL _veh, 1, 1, 30];

if (missionNamespace getVariable ["TAC_trt_blockPrep", false]) exitWith {};

private _weapon = _veh currentWeaponTurret [0];
private _state = [_veh, _weapon] call TAC_fnc_trtState;

_state set [3, time + TAC_rkt_waitTime];
_state set [4, (_state select 4) + 1];
[_veh, _weapon, _state] call TAC_fnc_trtState;
