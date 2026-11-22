/*
    Fonksiyon: TAC_fnc_hitBrokenTake
    Çalışma yeri: İstemci (TAC_fnc_wpnOnTake çağırır)

    Hasarlı (mermi isabetli) silah kaydı için DAYANIKLI yedek defter: TAC_hit_brokenList = [[sınıf (küçük harf), konum ASL, zaman], ...],
    herkese yayınlanır (en çok 300 kayıt; silah kapları silinse, yerler birleşse, TAC_stash / TAC_stashGlobal sınırı
    dolsa bile hasar silinmesin diye). Bir silah alınırken: aynı sınıftan, kapın / oyuncunun 6 m içindeki EN YENİ kayıt varsa
    silah hâlâ hasarlıdır; kayıt tüketilir ve true döner. Normal kayıt hasarı zaten devraldıysa (devralindi = true)
    yalnızca eşleşen defter kaydı silinir (çift saymayı önler).

    Parametreler:
        0: OBJECT - silahı alan birim
        1: OBJECT - kap (yer kabı, sandık, araç, ceset)
        2: STRING - silah classname
        3: BOOL   - (isteğe bağlı) hasar zaten kayıttan devralındı mı (varsayılan false)

    Dönüş: BOOL - defterde eşleşen hasar kaydı bulundu mu
*/

params ["_unit", "_container", "_item", ["_inherited", false]];

private _list = missionNamespace getVariable ["TAC_hit_brokenList", []];
if (_list isEqualTo []) exitWith {false};

private _key = toLower _item;
private _here = [getPosASL _unit, if (isNull _container) then {getPosASL _unit} else {getPosASL _container}];
private _best = -1;

for "_i" from (count _list - 1) to 0 step -1 do {
    private _e = _list select _i;

    if ((_e select 0) isEqualTo _key && {(_here findIf {(_x distance (_e select 1)) <= 6}) >= 0}) exitWith {_best = _i};
};

if (_best < 0) exitWith {false};

_list deleteAt _best;
missionNamespace setVariable ["TAC_hit_brokenList", _list, true];

if (TAC_wpn_debug) then {
    systemChat format ["[TAC isabet] %1: hasar defterde bulundu%2 (kalan kayit %3)", _item, [" -> hasarli", " (normal kayit zaten devraldi)"] select _inherited, count _list];
};

!_inherited
