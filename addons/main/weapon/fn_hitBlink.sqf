/*
    Fonksiyon: TAC_fnc_hitBlink
    Çalışma yeri: İstemci

    Mermi yenince göz kapanması (sesler de kesilir; kararma açılırken fade-in ile geri gelir): ekran çok hızlı kararır (0.06 sn), tepe noktasında kısa tutar ve yavaşça
    açılır. Şiddet (TAC_hit_blinkStrength) varsayılan olarak her isabette TAM uygulanır; TAC_hit_blinkScaleDamage açıksa
    isabet eden hasarla ölçeklenir (hasar 0.5 ve üzeri = tam şiddet; en az %30); süre (TAC_hit_blinkTime x TAC_hit_blinkScale çarpanı) hasarla ölçeklenir (en az %60); tepede tutma süresi de aynı çarpanla uzar. Siyah kontrol display 46'da bir kez
    kurulur ve kalıcıdır. Arka arkaya isabetlerde en kuvvetli etki geçerli kalır; döngü yoktur.

    Parametreler:
        0: NUMBER - isabetin toplam hasarı (0 ya da bilinmiyorsa orta şiddet)

    Dönüş: yok
*/

params [["_damage", 0, [0]]];

if (!hasInterface) exitWith {};

private _display = findDisplay 46;
if (isNull _display) exitWith {};

private _ctrl = uiNamespace getVariable ["TAC_hit_blinkCtrl", controlNull];

if (isNull _ctrl) then {
    _ctrl = _display ctrlCreate ["RscText", -1];
    _ctrl ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
    _ctrl ctrlSetBackgroundColor [0, 0, 0, 1];
    _ctrl ctrlSetFade 1;
    _ctrl ctrlCommit 0;
    uiNamespace setVariable ["TAC_hit_blinkCtrl", _ctrl];
};

// Hasara gore olcekleme kapaliysa her isabette tam siddet / tam sure (k = 1)
private _k = if (!TAC_hit_blinkScaleDamage) then {1} else {if (_damage <= 0) then {0.6} else {((_damage / 0.5) max 0.3) min 1}};
private _alpha = (TAC_hit_blinkStrength / 100) * _k;
private _time = TAC_hit_blinkTime * TAC_hit_blinkScale * (_k max 0.6);

private _token = (uiNamespace getVariable ["TAC_hit_blinkToken", 0]) + 1;
uiNamespace setVariable ["TAC_hit_blinkToken", _token];

// Karar: alfa = 1 - fade
_ctrl ctrlSetFade (1 - _alpha);
_ctrl ctrlCommit 0.06;

// Sesler: kararma boyunca kesilir (ACE'nin kulak sistemiyle uyumlu: en dusuk ses ayari gecerli), acilirken fade-in
if (TAC_hit_blinkMute) then {
    private _level = (1 - (TAC_hit_blinkMuteLevel / 100)) max 0;

    if (isNil "ace_common_fnc_setHearingCapability") then {
        0.05 fadeSound _level;
        0.05 fadeRadio _level;
    } else {
        ["tac_hit", _level, true, 0.05] call ace_common_fnc_setHearingCapability;
    };
};

[{
    params ["_token", "_time"];

    if (_token != (uiNamespace getVariable ["TAC_hit_blinkToken", 0])) exitWith {};

    private _c = uiNamespace getVariable ["TAC_hit_blinkCtrl", controlNull];

    if (!isNull _c) then {
        _c ctrlSetFade 1;
        _c ctrlCommit _time;
    };

    // Sesler: kararmayla ayni surede yumusakca geri acilir (fade-in)
    if (TAC_hit_blinkMute) then {
        if (isNil "ace_common_fnc_setHearingCapability") then {
            _time fadeSound 1;
            _time fadeRadio 1;
        } else {
            ["tac_hit", 1, false, _time] call ace_common_fnc_setHearingCapability;
        };
    };
}, [_token, _time], 0.06 + (TAC_hit_blinkHold * TAC_hit_blinkScale)] call CBA_fnc_waitAndExecute;
