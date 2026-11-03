/*
    Fonksiyon: TAC_fnc_wpnEnvFactor
    Çalışma yeri: İstemci

    Ortam çarpanı (>= 1): kirlenmeyi ve arıza ihtimalini ölçekler. Sonuç 3 sn önbelleklenir
    (atış başına yeniden hesaplanmaz, döngü yok).
        yağmur         : + 0.4 x yağmur şiddeti
        sığ suda       : + 0.8
        toz/çamur zemin (kum, toprak, çöl, çamur, çakıl...) : yatarken + 0.6, çömelirken + 0.2
    "Ortam etkisi" ayarı kapalıysa 1.

    Parametreler:
        0: OBJECT - birim

    Dönüş: NUMBER
*/

params [["_unit", objNull, [objNull]]];

if (!TAC_wpn_env) exitWith {1};

if (time < (missionNamespace getVariable ["TAC_wpn_envUntil", -1])) exitWith {
    missionNamespace getVariable ["TAC_wpn_envValue", 1]
};

private _factor = 1 + (0.4 * (rain min 1));
private _pos = getPosATL _unit;

if (surfaceIsWater _pos && {(_pos select 2) < 0.4}) then {
    _factor = _factor + 0.8;
} else {
    private _surface = toLower (surfaceType _pos);
    private _dusty = ["sand", "desert", "dirt", "dust", "mud", "soil", "clay", "gravel"] findIf {(_surface find _x) >= 0};

    if (_dusty >= 0) then {
        switch (stance _unit) do {
            case "PRONE": {_factor = _factor + 0.6};
            case "CROUCH": {_factor = _factor + 0.2};
        };
    };
};

missionNamespace setVariable ["TAC_wpn_envUntil", time + 3];
missionNamespace setVariable ["TAC_wpn_envValue", _factor];

_factor
