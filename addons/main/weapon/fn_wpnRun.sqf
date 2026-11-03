/*
    Fonksiyon: TAC_fnc_wpnRun
    Çalışma yeri: İstemci

    Bakım eylemleri için ortak çalıştırıcı: meşgul kontrolü + ACE ilerleme çubuğu. Süre dolunca
    bitiş kodu çalışır; çubuk kesilirse hiçbir şey değişmez. Meşgul işareti bir zaman damgasıdır
    (TAC_wpn_busyUntil): çubuk hiç bitmese bile süre dolunca kendiliğinden açılır.
    Süre 0 ise anında yapılır. Süre, "Bakım süresi çarpanı" ile çarpılmış olarak verilmelidir.

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: STRING - çubukta görünen metin
        2: NUMBER - süre (sn)
        3: CODE   - bitiş kodu, parametre: [unit, args]
        4: ARRAY  - bitiş koduna aktarılan argümanlar

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_text", "", [""]], ["_duration", 0, [0]], ["_finish", {}, [{}]], ["_args", [], [[]]]];

if (isNull _unit || {time < (_unit getVariable ["TAC_wpn_busyUntil", 0])}) exitWith {};

if (_duration <= 0) exitWith {
    [_unit, _args] call _finish;
};

_unit setVariable ["TAC_wpn_busyUntil", time + _duration + 3];

[
    _duration,
    [_unit, _args, _finish],
    {
        params ["_p"];
        _p params ["_unit", "_args", "_finish"];

        _unit setVariable ["TAC_wpn_busyUntil", 0];
        [_unit, _args] call _finish;
    },
    {
        params ["_p"];
        (_p select 0) setVariable ["TAC_wpn_busyUntil", 0];
    },
    _text,
    {
        params ["_p"];
        private _unit = _p select 0;

        alive _unit && {!(_unit getVariable ["ACE_isUnconscious", false])}
    },
    ["isNotInside"]
] call ace_common_fnc_progressBar;
