/*
    Fonksiyon: TAC_fnc_nvgStop
    Çalışma yeri: İstemci

    Tüketim döngüsünü (PFH) kaldırır, ekran efektlerini ve test göstergesini temizler.
    Çalışmıyorsa zararsızdır; PFH'nin kendi içinden de çağrılabilir.

    Parametreler: yok
    Dönüş: yok
*/

private _pfh = missionNamespace getVariable ["TAC_nvg_pfh", -1];

if (_pfh >= 0) then {
    [_pfh] call CBA_fnc_removePerFrameHandler;
    missionNamespace setVariable ["TAC_nvg_pfh", -1];
};

call TAC_fnc_nvgClearEffects;

if (missionNamespace getVariable ["TAC_nvg_testHint", false]) then {
    hintSilent "";
    missionNamespace setVariable ["TAC_nvg_testHint", false];
};
