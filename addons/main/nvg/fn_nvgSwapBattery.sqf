/*
    Fonksiyon: TAC_fnc_nvgSwapBattery
    Çalışma yeri: İstemci

    "NVG Pil Değiştir" eyleminin gövdesi. Cihaz açıksa önce kapatılır (pil değiştirirken
    güç kesilir), sonra ayardaki süre kadar ACE ilerleme çubuğu gösterilir. Süre dolunca
    envanterden bir pil düşülür ve şarj %100 olur; eski pil atılır.
    Süre 0 ise anında yapılır.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {_unit getVariable ["TAC_nvg_swapping", false]}) exitWith {};

if (currentVisionMode _unit == 1) then {
    _unit action ["NVGogglesOff", _unit];
};

if (TAC_nvg_swapTime <= 0) exitWith {
    [_unit] call TAC_fnc_nvgSwapFinish;
};

_unit setVariable ["TAC_nvg_swapping", true];

[
    TAC_nvg_swapTime,
    [_unit],
    {
        params ["_args"];
        _args params ["_unit"];

        [_unit] call TAC_fnc_nvgSwapFinish;
    },
    {
        params ["_args"];
        (_args select 0) setVariable ["TAC_nvg_swapping", false];
    },
    "NVG pili değiştiriliyor...",
    {
        params ["_args"];
        private _unit = _args select 0;

        alive _unit && {!(_unit getVariable ["ACE_isUnconscious", false])}
    },
    ["isNotInside"]
] call ace_common_fnc_progressBar;
