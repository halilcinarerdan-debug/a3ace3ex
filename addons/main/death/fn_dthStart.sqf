/*
    Fonksiyon: TAC_fnc_dthStart
    Çalışma yeri: İstemci

    Ölüm / yaralı ekranını başlatır: sesler kısılır (ACE kulak sistemi ya da fadeSound), ekran bulanıklaşır
    (DynamicBlur), griye döner (ColorCorrections) ve kararır (display 46'da siyah kontrol). Efekt TAC_dth_fadeIn
    sürede tam şiddete gelir. Post-process efektleri ve kontrol bir kez kurulur, kalıcıdır (birim değişince silinmez:
    yeniden doğunca efekt KESİLMEZ, TAC_fnc_dthEnd yumuşakça söndürür). Durum: TAC_dth_active, TAC_dth_reason.

    Parametreler:
        0: STRING - "death" (öldü) ya da "incap" (yere düştü / bilinçsiz)

    Dönüş: yok
*/

params [["_reason", "death", [""]]];

if (!hasInterface || {!TAC_dth_enabled}) exitWith {};
if (_reason isEqualTo "incap" && {!TAC_dth_incap}) exitWith {};
if (_reason isEqualTo "death" && {!TAC_dth_death}) exitWith {};

// Zaten etkin: yalnizca neden "olum"e yukselir (yaralidan olume gecerken kesilmez)
if (missionNamespace getVariable ["TAC_dth_active", false]) exitWith {
    if (_reason isEqualTo "death") then {TAC_dth_reason = "death"};
};

TAC_dth_active = true;
TAC_dth_reason = _reason;
TAC_dth_token = (missionNamespace getVariable ["TAC_dth_token", 0]) + 1;

private _fade = TAC_dth_fadeIn;

// --- Post-process efektleri (bir kez kurulur) ---
private _blur = missionNamespace getVariable ["TAC_dth_ppBlur", -1];

if (_blur < 0) then {
    for "_i" from 0 to 100 do {
        _blur = ppEffectCreate ["DynamicBlur", 470 + _i];
        if (_blur >= 0) exitWith {};
    };
    missionNamespace setVariable ["TAC_dth_ppBlur", _blur];
};

private _color = missionNamespace getVariable ["TAC_dth_ppColor", -1];

if (_color < 0) then {
    for "_i" from 0 to 100 do {
        _color = ppEffectCreate ["ColorCorrections", 650 + _i];
        if (_color >= 0) exitWith {};
    };
    missionNamespace setVariable ["TAC_dth_ppColor", _color];
};

if (_blur >= 0) then {
    _blur ppEffectEnable true;
    _blur ppEffectForceInNVG true;
    _blur ppEffectAdjust [TAC_dth_blur];
    _blur ppEffectCommit _fade;
};

if (_color >= 0) then {
    _color ppEffectEnable true;
    _color ppEffectForceInNVG true;
    _color ppEffectAdjust [1, 1, 0, [0, 0, 0, 0], [1, 1, 1, TAC_dth_gray / 100], [0.299, 0.587, 0.114, 0]];
    _color ppEffectCommit _fade;
};

// --- Karartma kontrolu (display 46; kalici) ---
private _display = findDisplay 46;

if (!isNull _display) then {
    private _ctrl = uiNamespace getVariable ["TAC_dth_ctrl", controlNull];

    if (isNull _ctrl) then {
        _ctrl = _display ctrlCreate ["RscText", -1];
        _ctrl ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
        _ctrl ctrlSetBackgroundColor [0, 0, 0, 1];
        _ctrl ctrlSetFade 1;
        _ctrl ctrlCommit 0;
        uiNamespace setVariable ["TAC_dth_ctrl", _ctrl];
    };

    _ctrl ctrlSetFade (1 - (TAC_dth_dark / 100));
    _ctrl ctrlCommit _fade;
};

// --- Sesler ---
private _level = (1 - (TAC_dth_muffle / 100)) max 0;

if (isNil "ace_common_fnc_setHearingCapability") then {
    _fade fadeSound _level;
    _fade fadeRadio _level;
} else {
    ["tac_death", _level, true, _fade] call ace_common_fnc_setHearingCapability;
};

if (TAC_wpn_debug) then {systemChat format ["[TAC olum ekrani] basladi (%1)", _reason]};
