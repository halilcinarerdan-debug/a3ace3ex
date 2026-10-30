/*
    Fonksiyon: TAC_fnc_nvgClearEffects
    Çalışma yeri: İstemci

    NVG düşük pil efektlerini (parazit, kararma) kapatır ve PP efektlerini yok eder.
    Efekt yoksa zararsızdır.

    Parametreler: yok
    Dönüş: yok
*/

{
    private _handle = missionNamespace getVariable [_x, -1];

    if (_handle >= 0) then {
        _handle ppEffectEnable false;
        ppEffectDestroy _handle;
        missionNamespace setVariable [_x, -1];
    };
} forEach ["TAC_nvg_ppGrain", "TAC_nvg_ppColor"];
