/*
    Fonksiyon: TAC_fnc_optStop
    Çalışma yeri: İstemci

    İzleme döngüsünü durdurur ve ekran etkilerini kapatır. Çalışmıyorsa zararsızdır.
    Son güncelleme zamanı durumda kalır: bir sonraki bakışta toparlanma hesaplanır.

    Parametreler: yok
    Dönüş: yok
*/

private _pfh = missionNamespace getVariable ["TAC_opt_pfh", -1];

if (_pfh >= 0) then {
    [_pfh] call CBA_fnc_removePerFrameHandler;
    missionNamespace setVariable ["TAC_opt_pfh", -1];

    private _unit = ACE_player;
    private _state = [_unit, currentWeapon _unit] call TAC_fnc_optGetState;

    _state set [2, time];
};

call TAC_fnc_optClearEffects;
