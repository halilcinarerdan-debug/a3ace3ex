/*
    Fonksiyon: TAC_fnc_stressReset
    Çalışma yeri: İstemci

    Stresi sıfırlar: temel sway değerini geri yazar, döngüyü (PFH) kaldırır, göstergeyi temizler.
    Stres yokken çağrılması zararsızdır (respawn, ayar kapanması, stresin bitmesi).

    Parametreler: yok
    Dönüş: yok
*/

private _pfh = missionNamespace getVariable ["TAC_stress_pfh", -1];

if (_pfh >= 0) then {
    [_pfh] call CBA_fnc_removePerFrameHandler;
    missionNamespace setVariable ["TAC_stress_pfh", -1];
};

if ((missionNamespace getVariable ["TAC_stress_level", 0]) > 0) then {
    private _var = missionNamespace getVariable ["TAC_stress_var", ""];
    private _base = missionNamespace getVariable ["TAC_stress_base", 1];

    if (_var isEqualTo "") then {
        ACE_player setCustomAimCoef _base;
    } else {
        missionNamespace setVariable [_var, _base];
    };

    if (TAC_stress_debug) then {hintSilent ""};
};

missionNamespace setVariable ["TAC_stress_level", 0];
