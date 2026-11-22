/*
    Fonksiyon: TAC_fnc_hitBlink
    Çalışma yeri: İstemci

    Mermi yenince göz kapanması: ekran çok hızlı kararır (0.06 sn), tepe noktasında kısa tutar ve yavaşça
    açılır. Şiddet (TAC_hit_blinkPower) isabet eden hasarla ölçeklenir (hasar 0.5 ve üzeri = tam şiddet;
    en az %30); süre (TAC_hit_blinkTime) hasarla ölçeklenir (en az %40). Siyah kontrol display 46'da bir kez
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

private _k = if (_damage <= 0) then {0.6} else {((_damage / 0.5) max 0.3) min 1};
private _alpha = (TAC_hit_blinkPower / 100) * _k;
private _time = TAC_hit_blinkTime * (_k max 0.4);

private _token = (uiNamespace getVariable ["TAC_hit_blinkToken", 0]) + 1;
uiNamespace setVariable ["TAC_hit_blinkToken", _token];

// Karar: alfa = 1 - fade
_ctrl ctrlSetFade (1 - _alpha);
_ctrl ctrlCommit 0.06;

[{
    params ["_token", "_time"];

    if (_token != (uiNamespace getVariable ["TAC_hit_blinkToken", 0])) exitWith {};

    private _c = uiNamespace getVariable ["TAC_hit_blinkCtrl", controlNull];

    if (!isNull _c) then {
        _c ctrlSetFade 1;
        _c ctrlCommit _time;
    };
}, [_token, _time], 0.06 + TAC_hit_blinkHold] call CBA_fnc_waitAndExecute;
