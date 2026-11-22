/*
    Fonksiyon: TAC_fnc_rktOnTake
    Çalışma yeri: İstemci (oyuncunun "Take" olayı)

    1) Durum taşıma: o fırlatıcı için kayıtlı durum varsa (kaptan ya da yedek genel listeden, TAC_fnc_stashPop)
       oyuncuya aktarılır; yoksa kalıntı durum silinir, sıfırdan başlar.
    2) Hava: hava koşulları yalnızca OYUNCUNUN TAŞIDIĞI fırlatıcı mühimmatını etkiler. Araç, mühimmat sandığı,
       depo gibi envanterlerdeki eşyalar etkilenmez ve kuru saklanmış sayılır: oradan alınan fırlatıcıda mühimmat
       nemi en fazla %10 olur. Yerdeki (WeaponHolder) eşyalar dışarıda sayılır, nem sıfırlanmaz.

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

private _state = [_container, _unit, "r:" + _key] call TAC_fnc_stashPop;

if (TAC_rkt_debug) then {
    systemChat format [
        "[TAC roket] ALINDI %1 | kap %2 | kayit %3%4",
        _item,
        typeOf _container,
        ["YOK -> sifirdan basliyor", "VAR -> devralindi"] select !(_state isEqualTo []),
        if (_state isEqualTo []) then {""} else {format [" (ATESLENMEME %1, zar atildi %2)", _state select 2, _state select 1]}
    ];
};

if (_state isEqualTo []) then {
    _all deleteAt _key;
} else {
    _all set [_key, _state];
};

if !(_container isKindOf "WeaponHolder") then {
    _unit setVariable ["TAC_rkt_moist", (_unit getVariable ["TAC_rkt_moist", 0]) min 10];
};
