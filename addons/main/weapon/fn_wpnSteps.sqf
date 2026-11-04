/*
    Fonksiyon: TAC_fnc_wpnSteps
    Çalışma yeri: İstemci

    Çok adımlı hazırlık prosedürü çalıştırıcısı: adımları sırayla yürütür; her adım kendi ilerleme çubuğu,
    silah hareketi ve sesiyle (TAC_fnc_wpnRun) çalışır. Bir adım iptal edilirse prosedür kesilir (baştan
    başlanır). Son adım bitince bitiş kodu çalışır. Süreler "Bakım süresi çarpanı" ile çarpılır.

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: ARRAY  - adımlar [[metin, süre sn], ...]
        2: STRING - hareket / ses türü (TAC_fnc_wpnRun "kind": "feed", "rocket"...)
        3: STRING - hedef silah classname
        4: CODE   - bitiş kodu, parametre: [unit, args]
        5: ARRAY  - bitiş koduna aktarılan argümanlar

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_steps", [], [[]]], ["_kind", "", [""]], ["_weapon", "", [""]], ["_onDone", {}, [{}]], ["_args", [], [[]]]];

if (_steps isEqualTo []) exitWith {
    [_unit, _args] call _onDone;
};

(_steps select 0) params ["_label", "_seconds"];

private _rest = _steps select [1, count _steps - 1];

[_unit, _label + "...", _seconds * TAC_wpn_cleanTimeMult, {
    params ["_unit", "_a"];
    _a params ["_weapon", "_rest", "_kind", "_onDone", "_args"];

    if (_rest isEqualTo []) then {
        [_unit, _args] call _onDone;
    } else {
        [_unit, _rest, _kind, _weapon, _onDone, _args] call TAC_fnc_wpnSteps;
    };
}, [_weapon, _rest, _kind, _onDone, _args], _kind] call TAC_fnc_wpnRun;
