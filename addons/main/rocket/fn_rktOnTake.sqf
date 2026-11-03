/*
    Fonksiyon: TAC_fnc_rktOnTake
    Çalışma yeri: İstemci (oyuncunun "Take" olayı)

    1) Durum taşıma: kapta o sınıftan saklı fırlatıcı durumu varsa (TAC_fnc_rktOnPut ile bırakılmış) oyuncuya
       aktarılır ve kayıt kaptan silinir; yoksa (arsenal, yeni fırlatıcı) kalıntı durum silinir, sıfırdan başlar.
    2) Hava: hava koşulları yalnızca OYUNCUNUN TAŞIDIĞI fırlatıcı mühimmatını etkiler (nem döngüsü fırlatıcı
       taşınmıyorsa hiçbir şey yapmaz). Araç, mühimmat sandığı, depo gibi envanterlerdeki eşyalar etkilenmez ve
       kuru saklanmış sayılır: oradan alınan fırlatıcıda mühimmat nemi en fazla %10 olur. Yerdeki
       (GroundWeaponHolder / WeaponHolder) eşyalar dışarıda sayılır, nem sıfırlanmaz.

    Parametreler: Take olayı: [unit, container, item]
    Dönüş: yok
*/

params ["_unit", "_container", "_item"];

if (!TAC_rkt_enabled || {(getNumber (configFile >> "CfgWeapons" >> _item >> "type")) != 4}) exitWith {};

private _key = toLower _item;
private _all = _unit getVariable "TAC_rkt_state";

if (isNil "_all") then {
    _all = createHashMap;
    _unit setVariable ["TAC_rkt_state", _all];
};

private _stash = _container getVariable ["TAC_rkt_stash", []];
private _index = _stash findIf {(_x select 0) isEqualTo _key};

if (TAC_rkt_debug) then {
    systemChat format [
        "[TAC roket] ALINDI %1 | kap %2 | kapta kayit %3%4",
        _item,
        typeOf _container,
        ["YOK -> sifirdan basliyor", "VAR -> devralindi"] select (_index >= 0),
        if (_index >= 0) then {format [" (ATESLENMEME %1, zar atildi %2)", ((_stash select _index) select 1) select 2, ((_stash select _index) select 1) select 1]} else {""}
    ];
};

if (_index < 0) then {
    _all deleteAt _key;
} else {
    _all set [_key, (_stash select _index) select 1];
    _stash deleteAt _index;
    _container setVariable ["TAC_rkt_stash", _stash, true];
};

if !(_container isKindOf "WeaponHolder") then {
    _unit setVariable ["TAC_rkt_moist", (_unit getVariable ["TAC_rkt_moist", 0]) min 10];
};
