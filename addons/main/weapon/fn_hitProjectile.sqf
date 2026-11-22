/*
    Fonksiyon: TAC_fnc_hitProjectile
    Çalışma yeri: İstemci (mission olayı "ProjectileCreated": yalnızca bu makinede yerel mermiler)

    Silah nesnesine isabet testi, İZLEME yolu (TAC_hit_mode 1 veya 2). "Suppressed" olayı mermi nesnesini vermese ya da
    mermi silahta durup silinse bile çalışır: oyuncuya doğru gelen (yolu göğsünden 2 m içinden geçen, 2 sn içinde ulaşan)
    mermiler izlenir (TAC_fnc_hitTrackTick: her karede önceki ve şimdiki konum arasındaki "süpürme" parçası silah
    doğrusuyla test edilir; mermi silinirse son hız yönünde bir kare daha). Tek başına / sunucuda (yapay zekâ mermileri
    sunucuda yerel) çalışır; başka oyuncunun merminde yalnızca "Suppressed" yolu vardır.
    Filtre ucuzdur: ilk çağrıda çoğu mermi elenir; izleme döngüsü yalnızca izlenen mermi varken çalışır.

    Parametreler (olay): [mermi]
    Dönüş: yok
*/

params ["_projectile"];

if (!hasInterface || {!TAC_hit_enabled} || {TAC_hit_mode == 0} || {!TAC_hit_unusable && {!TAC_hit_drop}}) exitWith {};

private _unit = ACE_player;

if (isNull _unit || {!alive _unit}) exitWith {};

private _weapon = currentWeapon _unit;

if (_weapon isEqualTo "" || {!(_weapon in [primaryWeapon _unit, handgunWeapon _unit])}) exitWith {};

private _v = velocity _projectile;
private _vv = _v vectorDotProduct _v;

if (_vv < 2500) exitWith {};   // < 50 m/s

private _p = getPosASL _projectile;

if ((_p distance _unit) > 400) exitWith {};

// Kendi mermimizi izleme
if (((getShotParents _projectile) param [1, objNull]) isEqualTo _unit) exitWith {};

// Yol, gogsumuzden 2 m icinden gecmeli ve en gec 2 sn icinde ulasmali
private _chest = (getPosASL _unit) vectorAdd [0, 0, 1.1];
private _t = (((_chest vectorDiff _p) vectorDotProduct _v) / _vv);

if (_t < 0 || {_t > 2}) exitWith {};
if ((vectorMagnitude ((_p vectorAdd (_v vectorMultiply _t)) vectorDiff _chest)) > 2) exitWith {};

if !((toLower (getText (configFile >> "CfgAmmo" >> typeOf _projectile >> "simulation"))) isEqualTo "shotbullet") exitWith {};

private _list = missionNamespace getVariable ["TAC_hit_tracked", []];
_list pushBack [_projectile, _p, _v, time];
missionNamespace setVariable ["TAC_hit_tracked", _list];

if (TAC_wpn_debug) then {
    systemChat format ["[TAC isabet] izlenen mermi eklendi | uzaklik %1 m | hiz %2 m/s", round (_p distance _unit), round (sqrt _vv)];
};

if ((missionNamespace getVariable ["TAC_hit_pfh", -1]) < 0) then {
    missionNamespace setVariable ["TAC_hit_pfh", [TAC_fnc_hitTrackTick, 0] call CBA_fnc_addPerFrameHandler];
};
