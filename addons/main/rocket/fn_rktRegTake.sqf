/*
    Fonksiyon: TAC_fnc_rktRegTake
    Çalışma yeri: İstemci (TAC_fnc_rktOnTake çağırır)

    Roketatar alınırken dayanıklı defterden (TAC_rkt_regList) aynı sınıfın, alanın / kabın 8 m içindeki EN YENİ kaydını
    arar. Bulursa kaydı tüketir (defterden siler) ve durumu döner; normal kayıt zaten devralındıysa (devralindi = true)
    yalnızca eşleşen defter kaydı silinir (çift devralmayı önler) ve [] döner.

    Parametreler:
        0: OBJECT - alan birim
        1: OBJECT - kap
        2: STRING - anahtar ("r:" + sınıf)
        3: BOOL   - normal kayıttan durum zaten devralındı mı

    Dönüş: ARRAY - durum ya da []
*/

params ["_unit", "_container", "_key", ["_inherited", false]];

private _reg = missionNamespace getVariable ["TAC_rkt_regList", []];
if (_reg isEqualTo []) exitWith {[]};

private _here = [getPosASL _unit, if (isNull _container) then {getPosASL _unit} else {getPosASL _container}];
private _best = -1;

for "_i" from (count _reg - 1) to 0 step -1 do {
    private _e = _reg select _i;

    if ((_e select 0) isEqualTo _key && {(_here findIf {(_x distance (_e select 2)) <= 8}) >= 0}) exitWith {_best = _i};
};

if (_best < 0) exitWith {[]};

private _state = (_reg select _best) select 1;
_reg deleteAt _best;
missionNamespace setVariable ["TAC_rkt_regList", _reg, true];

if (TAC_rkt_debug) then {
    systemChat format ["[TAC roket] %1: dayanikli defterde bulundu%2 (kalan kayit %3)", _key, [" -> durum devralindi", " (normal kayit zaten devraldi)"] select _inherited, count _reg];
};

if (_inherited) then {[]} else {+_state}
