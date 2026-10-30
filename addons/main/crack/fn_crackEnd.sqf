/*
    Fonksiyon: TAC_fnc_crackEnd
    Çalışma yeri: İstemci

    Efekti temizler: bulanıklığı yok eder, vignette kontrollerini siler ve HUD'u efektten önceki
    haline döndürür. Jeton eşleşmiyorsa (efekt arada yeniden tetiklenmiş) hiçbir şey yapmaz.
    Jeton -1 ise zorla temizler (respawn, birim değişimi).

    Parametreler:
        0: NUMBER - zamanlayıcı jetonu, -1 = zorla

    Dönüş: yok
*/

params [["_token", -1, [0]]];

if (_token >= 0 && {_token != (missionNamespace getVariable ["TAC_crack_token", 0])}) exitWith {};

private _blur = missionNamespace getVariable ["TAC_crack_ppBlur", -1];

if (_blur >= 0) then {
    _blur ppEffectEnable false;
    ppEffectDestroy _blur;
    missionNamespace setVariable ["TAC_crack_ppBlur", -1];
};

{ctrlDelete _x} forEach (missionNamespace getVariable ["TAC_crack_ctrls", []]);
missionNamespace setVariable ["TAC_crack_ctrls", []];

if (missionNamespace getVariable ["TAC_crack_hudHidden", false]) then {
    showHUD (missionNamespace getVariable ["TAC_crack_hudSaved", true]);
    missionNamespace setVariable ["TAC_crack_hudHidden", false];
};
