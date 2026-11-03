/*
    Fonksiyon: TAC_fnc_rktGetState
    Çalışma yeri: İstemci

    Birimin bir fırlatıcısının durumunu verir (silah sınıfı başına, birimde yerel; referans döner).
    Durum: [atış sayısı, zar atıldı mı, ateşlenmeme var mı, bekleme bitişi (time), ateşlenmeme sayısı, atışa hazır mı]
    Varsayılan: [0, false, false, 0, 0, false]

    Parametreler:
        0: OBJECT - birim
        1: STRING - silah classname

    Dönüş: ARRAY
*/

params [["_unit", objNull, [objNull]], ["_weapon", "", [""]]];

private _all = _unit getVariable "TAC_rkt_state";

if (isNil "_all") then {
    _all = createHashMap;
    _unit setVariable ["TAC_rkt_state", _all];
};

private _key = toLower _weapon;
private _state = _all get _key;

if (isNil "_state") then {
    _state = [0, false, false, 0, 0, false];
    _all set [_key, _state];
};

_state
