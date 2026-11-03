/*
    Fonksiyon: TAC_fnc_nvgRemoveBattery
    Çalışma yeri: İstemci

    "Pili çıkar" eyleminin gövdesi. Cihaz açıksa kapatılır, ilerleme çubuğu (pil değiştirme
    süresinin yarısı) dolunca takılı pil kalan şarjına uygun kademede envantere döner
    (yer yoksa yere düşer) ve NVG pilsiz kalır: yeni pil takılana kadar açılmaz.
    Çok düşük şarjlı pil "bitik pil" olur.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!(_unit getVariable ["TAC_nvg_hasBattery", true])}) exitWith {};
if (time < (_unit getVariable ["TAC_nvg_swapUntil", 0])) exitWith {};

if (currentVisionMode _unit == 1) then {
    _unit action ["NVGogglesOff", _unit];
};

private _duration = TAC_nvg_swapTime * 0.5;

private _finish = {
    params ["_args"];
    _args params ["_unit"];

    _unit setVariable ["TAC_nvg_swapUntil", 0];

    if !(_unit getVariable ["TAC_nvg_hasBattery", true]) exitWith {};

    private _class = [_unit getVariable ["TAC_nvg_installedClass", ""], (_unit getVariable ["TAC_nvg_charge", 100]) / 100] call TAC_fnc_nvgTierClass;

    [_unit, _class] call TAC_fnc_nvgPlaceItem;

    _unit setVariable ["TAC_nvg_hasBattery", false];
    _unit setVariable ["TAC_nvg_charge", 0];
    _unit setVariable ["TAC_nvg_installedClass", ""];
    call TAC_fnc_nvgClearEffects;

    diag_log format ["[TAC][NVG] pil cikarildi, envantere donen: '%1'", _class];

    [if (_class isEqualTo "") then {"Pil çıkarıldı (tükenmiş, atıldı)."} else {"Pil çıkarıldı: " + getText (configFile >> "CfgWeapons" >> _class >> "displayName")}] call TAC_fnc_nvgNotify;
};

if (_duration <= 0) exitWith {
    [[_unit]] call _finish;
};

_unit setVariable ["TAC_nvg_swapUntil", time + _duration + 3];

[
    _duration,
    [_unit],
    _finish,
    {
        params ["_args"];
        (_args select 0) setVariable ["TAC_nvg_swapUntil", 0];
    },
    "NVG pili çıkarılıyor...",
    {
        params ["_args"];
        private _unit = _args select 0;

        alive _unit && {!(_unit getVariable ["ACE_isUnconscious", false])}
    },
    ["isNotInside"]
] call ace_common_fnc_progressBar;
