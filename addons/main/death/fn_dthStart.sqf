/*
    Fonksiyon: TAC_fnc_dthStart
    Çalışma yeri: İstemci

    Ölüm / yaralı ekranını başlatır: ekran bulanıklaşır (DynamicBlur) ve griye döner (ColorCorrections); karartma ve
    sesler TAC_fnc_dthDark'ta: ANI KARARMA (TAC_dth_instant) açıksa vurulduğu an ekran tam siyah olur ve sesler kesilir,
    bekleme sonunda ölüm / yaralı ekranına geçilir; kapalıysa efekt TAC_dth_fadeIn sürede gelir. Post-process efektleri ve kontrol bir kez kurulur, kalıcıdır (birim değişince silinmez:
    yeniden doğunca efekt KESİLMEZ, TAC_fnc_dthEnd yumuşakça söndürür). Durum: TAC_dth_active, TAC_dth_reason.

    Parametreler:
        0: STRING - "death" (öldü) ya da "incap" (yere düştü / bilinçsiz)

    Dönüş: yok
*/

params [["_reason", "death", [""]]];

if (!hasInterface || {!TAC_dth_enabled}) exitWith {};
if (_reason isEqualTo "incap" && {!TAC_dth_incap}) exitWith {};
if (_reason isEqualTo "death" && {!TAC_dth_death}) exitWith {};

// Zaten etkin: neden "olum"e yukselirse (yaralidan olume) durum guncellenir; ani kararma aciksa olum icin yeniden tam siyah olur
if (missionNamespace getVariable ["TAC_dth_active", false]) exitWith {
    if (_reason isEqualTo "death" && {!(TAC_dth_reason isEqualTo "death")}) then {
        TAC_dth_reason = "death";

        if (TAC_dth_instant) then {
            TAC_dth_token = (missionNamespace getVariable ["TAC_dth_token", 0]) + 1;
            ["death"] call TAC_fnc_dthDark;
        };
    };
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

// --- Karartma + ses (ani kararma ya da yavas gelis): TAC_fnc_dthDark ---
[_reason] call TAC_fnc_dthDark;

if (TAC_wpn_debug) then {systemChat format ["[TAC olum ekrani] basladi (%1)", _reason]};
