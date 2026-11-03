/*
    Fonksiyon: TAC_fnc_optStart
    Çalışma yeri: İstemci

    İzleme döngüsünü başlatır (0.5 sn'lik CBA PerFrameHandler). Başlamadan önce, bakılmadığı süre
    boyunca lensin kendiliğinden toparlanması uygulanır: buğu saniyede %1.5 azalır (kir azalmaz).
    Zaten çalışıyorsa bir şey yapmaz.

    Parametreler: yok
    Dönüş: yok
*/

if ((missionNamespace getVariable ["TAC_opt_pfh", -1]) >= 0) exitWith {};

private _unit = ACE_player;
private _state = [_unit, currentWeapon _unit] call TAC_fnc_optGetState;

if ((_state select 2) >= 0) then {
    _state set [0, ((_state select 0) - (1.5 * ((time - (_state select 2)) max 0))) max 0];
};

_state set [2, time];

missionNamespace setVariable ["TAC_opt_pfh", [TAC_fnc_optTick, 0.5] call CBA_fnc_addPerFrameHandler];
