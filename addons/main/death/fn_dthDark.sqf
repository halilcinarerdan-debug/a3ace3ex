/*
    Fonksiyon: TAC_fnc_dthDark
    Çalışma yeri: İstemci (TAC_fnc_dthStart çağırır)

    Ekranı ve sesi karartır. ANI KARARMA açıksa (TAC_dth_instant): ölümcül isabet anında ekran TAM siyah olur ve sesler kesilir
    (TAC_dth_instantTime sn, varsayılan 0.05), neden "death" ise TAC_dth_deathHold, "incap" (revive'de yere düşme) ise
    TAC_dth_incapHold sn tam karanlıkta kalır, sonra TAC_dth_fadeIn sürede ölüm / yaralı ekranına (ölümde TAC_dth_dark %,
    yere düşmede TAC_dth_incapDark %, varsayılan 100 = simsiyah; ses: TAC_dth_muffle %) yumuşakça geçer. Kapalıysa doğrudan TAC_dth_fadeIn sürede o seviyeye gelir.
    Bekleme zamanlayıcısı jeton (TAC_dth_token) taşır: efekt arada söndürülürse (revive, yeniden doğma) hiçbir şey yapmaz.
    Karartma kontrolü display 46'da bir kez kurulur ve kalıcıdır. Döngü yoktur.

    Parametreler:
        0: STRING - "death" ya da "incap"

    Dönüş: yok
*/

params [["_reason", "death", [""]]];

if (!hasInterface) exitWith {};

private _ctrl = uiNamespace getVariable ["TAC_dth_ctrl", controlNull];

if (isNull _ctrl) then {
    private _display = findDisplay 46;

    if (!isNull _display) then {
        _ctrl = _display ctrlCreate ["RscText", -1];
        _ctrl ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
        _ctrl ctrlSetBackgroundColor [0, 0, 0, 1];
        _ctrl ctrlSetFade 1;
        _ctrl ctrlCommit 0;
        uiNamespace setVariable ["TAC_dth_ctrl", _ctrl];
    };
};

// Ses seviyesi yardimcisi: ACE kulak sistemi varsa onunla (en dusuk seviye gecerli), yoksa fadeSound / fadeRadio
private _setSound = {
    params ["_level", "_time"];

    if (isNil "ace_common_fnc_setHearingCapability") then {
        _time fadeSound _level;
        _time fadeRadio _level;
    } else {
        ["tac_death", _level, true, _time] call ace_common_fnc_setHearingCapability;
    };
};

private _finalAlpha = (if (_reason isEqualTo "incap") then {TAC_dth_incapDark} else {TAC_dth_dark}) / 100;
private _finalSound = (1 - (TAC_dth_muffle / 100)) max 0;

if (!TAC_dth_instant) exitWith {
    if (!isNull _ctrl) then {
        _ctrl ctrlSetFade (1 - _finalAlpha);
        _ctrl ctrlCommit TAC_dth_fadeIn;
    };

    [_finalSound, TAC_dth_fadeIn] call _setSound;
};

// --- Ani kararma: tam siyah + sesler kesik ---
if (!isNull _ctrl) then {
    _ctrl ctrlSetFade 0;
    _ctrl ctrlCommit TAC_dth_instantTime;
};

[(1 - (TAC_dth_instantMute / 100)) max 0, TAC_dth_instantTime] call _setSound;

// --- Bekleme bitince olum / yarali ekranina gecis ---
private _hold = if (_reason isEqualTo "death") then {TAC_dth_deathHold} else {TAC_dth_incapHold};

[{
    params ["_token", "_alpha", "_sound"];

    if (_token != (missionNamespace getVariable ["TAC_dth_token", 0]) || {!(missionNamespace getVariable ["TAC_dth_active", false])}) exitWith {};

    private _c = uiNamespace getVariable ["TAC_dth_ctrl", controlNull];

    if (!isNull _c) then {
        _c ctrlSetFade (1 - _alpha);
        _c ctrlCommit TAC_dth_fadeIn;
    };

    if (isNil "ace_common_fnc_setHearingCapability") then {
        TAC_dth_fadeIn fadeSound _sound;
        TAC_dth_fadeIn fadeRadio _sound;
    } else {
        ["tac_death", _sound, true, TAC_dth_fadeIn] call ace_common_fnc_setHearingCapability;
    };
}, [TAC_dth_token, _finalAlpha, _finalSound], TAC_dth_instantTime + _hold] call CBA_fnc_waitAndExecute;

if (TAC_wpn_debug) then {systemChat format ["[TAC olum ekrani] ani kararma (%1) | bekleme %2 sn", _reason, _hold]};
