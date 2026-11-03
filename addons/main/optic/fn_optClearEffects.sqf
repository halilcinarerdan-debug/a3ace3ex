/*
    Fonksiyon: TAC_fnc_optClearEffects
    Çalışma yeri: İstemci

    Optik etkilerini kapatır (efektler silinmez, kalıcıdır). Çalışmıyorsa zararsızdır.

    Parametreler: yok
    Dönüş: yok
*/

{
    private _handle = missionNamespace getVariable [_x, -1];

    if (_handle >= 0) then {
        _handle ppEffectEnable false;
    };
} forEach ["TAC_opt_ppBlur", "TAC_opt_ppColor"];
