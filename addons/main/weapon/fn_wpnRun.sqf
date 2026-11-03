/*
    Fonksiyon: TAC_fnc_wpnRun
    Çalışma yeri: İstemci

    Bakım eylemleri için ortak çalıştırıcı: meşgul kontrolü + ACE ilerleme çubuğu. Süre dolunca
    bitiş kodu çalışır; çubuk kesilirse hiçbir şey değişmez. Meşgul işareti bir zaman damgasıdır
    (TAC_wpn_busyUntil): çubuk hiç bitmese bile süre dolunca kendiliğinden açılır.
    Süre 0 ise anında yapılır. Süre, "Bakım süresi çarpanı" ile çarpılmış olarak verilmelidir.
    Başlangıçta silah hareketi (TAC_fnc_wpnGesture) ve başlangıç sesi, bitişte bitiş sesi çalınır
    (TAC_fnc_wpnFx; eylem türü _kind ile seçilir). Çubuk iptal edilirse bitiş sesi çalınmaz.

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: STRING - çubukta görünen metin
        2: NUMBER - süre (sn)
        3: CODE   - bitiş kodu, parametre: [unit, args]
        4: ARRAY  - bitiş koduna aktarılan argümanlar; ilk eleman hedef silah classname
        5: STRING - (isteğe bağlı) ses/hareket türü: "clean", "lube", "clearJam", "parts"

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_text", "", [""]], ["_duration", 0, [0]], ["_finish", {}, [{}]], ["_args", [], [[]]], ["_kind", "", [""]]];

if (isNull _unit || {time < (_unit getVariable ["TAC_wpn_busyUntil", 0])}) exitWith {};

private _weapon = if (count _args > 0 && {(_args select 0) isEqualType ""}) then {_args select 0} else {""};

if (_duration <= 0) exitWith {
    [_unit, _kind, "end", _weapon] call TAC_fnc_wpnFx;
    [_unit, _args] call _finish;
};

_unit setVariable ["TAC_wpn_busyUntil", time + _duration + 3];

[_unit, _kind, "start", _weapon] call TAC_fnc_wpnFx;
[_unit, _weapon] call TAC_fnc_wpnGesture;

[
    _duration,
    [_unit, _args, _finish, _kind, _weapon],
    {
        params ["_p"];
        _p params ["_unit", "_args", "_finish", "_kind", "_weapon"];

        _unit setVariable ["TAC_wpn_busyUntil", 0];
        [_unit, _kind, "end", _weapon] call TAC_fnc_wpnFx;
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
