/*
    Fonksiyon: TAC_fnc_optGetState
    Çalışma yeri: İstemci

    Birimin bir silahındaki optiğin durumunu verir; yoksa varsayılanla oluşturur (referans döner).
    Birimin üzerinde yerel tutulur, respawn'da sıfırlanır. Durum silah sınıfına bağlıdır
    (optik değişirse ayrı sayılmaz).

    Durum dizisi: [buğu 0..100, kir 0..100, son güncelleme zamanı (time, -1 = hiç)]
    Varsayılan: [0, 5, -1]

    Parametreler:
        0: OBJECT - birim
        1: STRING - silah classname

    Dönüş: ARRAY - durum (referans)
*/

params [["_unit", objNull, [objNull]], ["_weapon", "", [""]]];

private _all = _unit getVariable "TAC_opt_state";

if (isNil "_all") then {
    _all = createHashMap;
    _unit setVariable ["TAC_opt_state", _all];
};

private _key = toLower _weapon;
private _state = _all get _key;

if (isNil "_state") then {
    _state = [0, 5, -1];
    _all set [_key, _state];
};

_state
