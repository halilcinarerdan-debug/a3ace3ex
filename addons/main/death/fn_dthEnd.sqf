/*
    Fonksiyon: TAC_fnc_dthEnd
    Çalışma yeri: İstemci

    Ölüm / yaralı ekranını YUMUŞAKÇA söndürür (kesmez): bulanıklık, renk solması, kararma ve ses kısılması verilen süre
    boyunca normale döner. Süre sonunda post-process efektleri kapatılır (silinmez; sonraki kullanımda yeniden kullanılır).
    Yeniden doğunca (respawn) bu işlev çağrılır: efekt devam eder ve yeni bedende yavaşça söner. Arada efekt yeniden
    başlarsa (jeton değişir) eski söndürme zamanlayıcısı hiçbir şey yapmaz.

    Parametreler:
        0: NUMBER - sönme süresi (sn)

    Dönüş: yok
*/

params [["_fade", 5, [0]]];

if (!hasInterface || {!(missionNamespace getVariable ["TAC_dth_active", false])}) exitWith {};

TAC_dth_active = false;
TAC_dth_reason = "";
TAC_dth_token = (missionNamespace getVariable ["TAC_dth_token", 0]) + 1;

private _blur = missionNamespace getVariable ["TAC_dth_ppBlur", -1];
private _color = missionNamespace getVariable ["TAC_dth_ppColor", -1];

if (_blur >= 0) then {
    _blur ppEffectAdjust [0];
    _blur ppEffectCommit _fade;
};

if (_color >= 0) then {
    _color ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, 0], [0.299, 0.587, 0.114, 0]];
    _color ppEffectCommit _fade;
};

private _ctrl = uiNamespace getVariable ["TAC_dth_ctrl", controlNull];

if (!isNull _ctrl) then {
    _ctrl ctrlSetFade 1;
    _ctrl ctrlCommit _fade;
};

if (isNil "ace_common_fnc_setHearingCapability") then {
    _fade fadeSound 1;
    _fade fadeRadio 1;
} else {
    ["tac_death", 1, false, _fade] call ace_common_fnc_setHearingCapability;
};

[{
    params ["_token"];

    if (_token != (missionNamespace getVariable ["TAC_dth_token", 0])) exitWith {};

    {
        private _h = missionNamespace getVariable [_x, -1];
        if (_h >= 0) then {_h ppEffectEnable false};
    } forEach ["TAC_dth_ppBlur", "TAC_dth_ppColor"];
}, [TAC_dth_token], _fade + 0.3] call CBA_fnc_waitAndExecute;

if (TAC_wpn_debug) then {systemChat format ["[TAC olum ekrani] soniyor (%1 sn)", _fade]};
