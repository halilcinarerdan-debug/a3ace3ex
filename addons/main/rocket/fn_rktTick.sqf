/*
    Fonksiyon: TAC_fnc_rktTick
    Çalışma yeri: İstemci (CBA PFH, 10 sn'de bir)

    Taşınan roket / füze mühimmatının NEMİ (0..100, birimde): havaya maruz kalma zamanla birikir.
      yağmur (açıkta)  : + 0.2 x yağmur şiddeti / sn  (şiddetli yağmurda ~8 dk açıkta kalınca tam nemli)
      sığ su / yüzme   : + 1 / sn
      kuru hava        : - 0.1 / sn (yağmur yoksa, sığınaktayken veya araçtayken)
    Test modunda (silah bakımı test çarpanı) hızlanır. Fırlatıcı yoksa hiçbir şey yapmaz (ucuz çıkış).
    Ateşlenmeme ihtimali nemle artar (TAC_fnc_rktMisfireCheck). "Mühimmatı kurula" nemi %10'a indirir.

    Parametreler (CBA PFH): [_args, _handle]
    Dönüş: yok
*/

private _unit = ACE_player;
private _now = time;
private _dt = ((_now - (missionNamespace getVariable ["TAC_rkt_lastTick", _now])) max 0) min 30;

missionNamespace setVariable ["TAC_rkt_lastTick", _now];

if (!TAC_rkt_enabled || {!alive _unit} || {(secondaryWeapon _unit) isEqualTo ""}) exitWith {};

private _pos = getPosATL _unit;
private _sheltered = (insideBuilding _unit) >= 0.5 || {!isNull objectParent _unit};
private _accel = if (TAC_wpn_testMode) then {TAC_wpn_testMult} else {1};

private _rate = if (surfaceIsWater _pos && {(_pos select 2) < 0.4}) then {
    1
} else {
    if (!_sheltered && {rain > 0.1}) then {0.2 * (rain min 1)} else {-0.1}
};

private _moist = (((_unit getVariable ["TAC_rkt_moist", 0]) + (_rate * _dt * ([1, _accel] select (_rate > 0)))) max 0) min 100;

_unit setVariable ["TAC_rkt_moist", _moist];
