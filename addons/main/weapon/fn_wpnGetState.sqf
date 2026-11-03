/*
    Fonksiyon: TAC_fnc_wpnGetState
    Çalışma yeri: İstemci

    Birimin bir silahının (silah sınıfı başına) bakım durumunu verir; yoksa varsayılanla oluşturur.
    Diziyi doğrudan değiştirmek durumu günceller (referans döner). Birimin üzerinde yerel tutulur:
    ağa yayılmaz, respawn'da yeni beden varsayılanla başlar. Aynı sınıftan iki silah aynı durumu paylaşır.

    Durum dizisi: [kir 0..100, yağ 0..100, aşınma (atış), son temizlikten atış, son arıza türü,
                   son arıza zamanı (time), arıza sayısı, besleme hazır mı (MG)]
    Varsayılan: [5, 70, 0, 0, "", -1000, 0, true]

    Parametreler:
        0: OBJECT - birim
        1: STRING - silah classname

    Dönüş: ARRAY - durum (referans)
*/

params [["_unit", objNull, [objNull]], ["_weapon", "", [""]]];

private _all = _unit getVariable "TAC_wpn_state";

if (isNil "_all") then {
    _all = createHashMap;
    _unit setVariable ["TAC_wpn_state", _all];
};

private _key = toLower _weapon;
private _state = _all get _key;

if (isNil "_state") then {
    _state = [5, 70, 0, 0, "", -1000, 0, true];
    _all set [_key, _state];
};

_state
