/*
    Fonksiyon: TAC_fnc_nvgSwapBattery
    Çalışma yeri: İstemci

    "NVG Pil Değiştir" eyleminin gövdesi. Envanterde pil yoksa uyarır. Cihaz açıksa önce
    kapatılır (pil değiştirirken güç kesilir), sonra ayardaki süre kadar ACE ilerleme çubuğu
    gösterilir. Süre dolunca TAC_fnc_nvgSwapFinish pili düşer ve şarjı %100 yapar.
    Süre 0 ise anında yapılır.

    Çift başlatmayı önleyen "meşgul" işareti bir zaman damgasıdır (TAC_nvg_swapUntil): ilerleme
    çubuğu herhangi bir nedenle hiç bitmese bile süre dolunca kendiliğinden temizlenir, eylem
    sonsuza kadar gizli kalmaz.

    Her adım RPT'ye "[TAC][NVG]" önekiyle yazılır.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};

if (time < (_unit getVariable ["TAC_nvg_swapUntil", 0])) exitWith {};

private _class = [_unit] call TAC_fnc_nvgFindBattery;

diag_log format [
    "[TAC][NVG] pil degistirme istendi | bulunan pil: '%1' | hmd: '%2' | sure: %3 sn",
    _class,
    hmd _unit,
    TAC_nvg_swapTime
];

if (_class isEqualTo "") exitWith {
    ["Envanterde NVG bataryası yok.", true] call TAC_fnc_nvgNotify;
};

if (currentVisionMode _unit == 1) then {
    _unit action ["NVGogglesOff", _unit];
};

if (TAC_nvg_swapTime <= 0) exitWith {
    [_unit] call TAC_fnc_nvgSwapFinish;
};

_unit setVariable ["TAC_nvg_swapUntil", time + TAC_nvg_swapTime + 3];

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

        (_args select 0) setVariable ["TAC_nvg_swapUntil", 0];
        diag_log "[TAC][NVG] pil degistirme iptal edildi / kesildi";
    },
    "NVG pili değiştiriliyor...",
    {
        params ["_args"];
        private _unit = _args select 0;

        alive _unit && {!(_unit getVariable ["ACE_isUnconscious", false])}
    },
    ["isNotInside"]
] call ace_common_fnc_progressBar;
