/*
    Fonksiyon: TAC_fnc_stressTick
    Çalışma yeri: İstemci (CBA PFH, 0.1 sn; yalnızca stres varken)

    Stres seviyesini doğrusal düşürür (1 -> 0, "Sönüm süresi" kadar) ve sway çarpanını uygular:
        çarpan = 1 + (maksimum - 1) * seviye * (1 + nabız * sin(360 * 1.4 * zaman))
    Temel değer * çarpan, hedef değişkene (veya yedekte setCustomAimCoef'e) yazılır.
    Seviye 0'a inince temel değer geri yazılır ve döngü kaldırılır.

    Parametreler (CBA PFH): [_args, _handle]
    Dönüş: yok
*/

params ["_args", "_handle"];

private _unit = ACE_player;
private _now = time;
private _dt = ((_now - (missionNamespace getVariable ["TAC_stress_last", _now])) max 0) min 1;
missionNamespace setVariable ["TAC_stress_last", _now];

private _level = (missionNamespace getVariable ["TAC_stress_level", 0]) - (_dt / (TAC_stress_decay max 1));

if (_level <= 0 || {!TAC_stress_enabled} || {!alive _unit}) exitWith {
    call TAC_fnc_stressReset;
};

missionNamespace setVariable ["TAC_stress_level", _level];

// 1.4 Hz ~ 84 atim/dk: sakin ama belirgin nabiz dalgasi
private _pulse = 1 + (TAC_stress_pulse * (sin (360 * 1.4 * _now)));
private _factor = (1 + ((TAC_stress_maxMult - 1) * _level * _pulse)) max 1;

private _var = missionNamespace getVariable ["TAC_stress_var", ""];
private _base = missionNamespace getVariable ["TAC_stress_base", 1];

if (_var isEqualTo "") then {
    _unit setCustomAimCoef (_base * _factor);
} else {
    missionNamespace setVariable [_var, _base * _factor];
};

if (TAC_stress_debug) then {
    hintSilent parseText format [
        "<t color='#ffcc00'>[TEST] Stres</t><br/>Seviye: %1<br/>Sway çarpanı: x%2<br/>Hedef: %3 (temel %4)",
        (round (_level * 100)) / 100,
        (round (_factor * 100)) / 100,
        if (_var isEqualTo "") then {"setCustomAimCoef"} else {_var},
        (round (_base * 100)) / 100
    ];
};
