/*
    Fonksiyon: TAC_fnc_hitProjectile
    Çalışma yeri: İstemci (mission olayı "ProjectileCreated": yalnızca bu makinede YEREL mermiler = bu makinedeki atıcıların mermileri)

    Silah nesnesine isabet testi, İZLEME yolu (TAC_hit_detect 1 veya 2). Her yerel mermi için TÜM oyunculara (kendimiz ve
    diğer oyuncular; Zeus ile kontrol edilen birim dahil) bakılır: yolu o oyuncunun göğsünden 2 m içinden geçen, 2 sn
    içinde ulaşan, elinde birincil silah / tabanca olan hedefler için mermi izlenir (TAC_fnc_hitTrackTick: her karede
    önceki-şimdiki konum "süpürmesi" hedefin silah doğrusuyla test edilir; mermi silinirse son hız yönünde bir kare daha).
    Böylece ARKADAŞIN ateş edince de çalışır: mermi atıcının makinesinde yerel olduğundan test atıcının makinesinde yapılır;
    isabet olursa silah sahibine olay gider (TAC_hit_weapon: silahı hasarla + düşür). Yapay zekâ mermileri (sunucuda yerel)
    sunucudaki mod ile hedef oyunculara aynı yolla iletilir (hedef, oyuncunun kendi makinesi).
    Filtre ucuzdur: çoğu mermi ilk çağrıda elenir; izleme döngüsü yalnızca izlenen mermi varken çalışır.

    Parametreler (olay): [mermi]
    Dönüş: yok
*/

params ["_projectile"];

if (!hasInterface && {!isServer}) exitWith {};
if (!TAC_hit_enabled || {TAC_hit_detect == 0} || {!TAC_hit_unusable && {!TAC_hit_drop}}) exitWith {};

private _v = velocity _projectile;
private _vv = _v vectorDotProduct _v;

if (_vv < 2500) exitWith {};   // < 50 m/s

if !((toLower (getText (configFile >> "CfgAmmo" >> typeOf _projectile >> "simulation"))) isEqualTo "shotbullet") exitWith {};

private _p = getPosASL _projectile;
private _shooter = (getShotParents _projectile) param [1, objNull];

// Hedefler: tum oyuncular (+ kontrol ettigimiz birim: Zeus remote control)
private _targets = +allPlayers;
if (hasInterface && {!isNull ACE_player}) then {_targets pushBackUnique ACE_player};

private _list = missionNamespace getVariable ["TAC_hit_tracked", []];
private _added = 0;

{
    private _t = _x;

    if (alive _t && {!(_t isEqualTo _shooter)} && {(_p distance _t) < 400}) then {
        private _w = currentWeapon _t;

        if (!(_w isEqualTo "") && {_w in [primaryWeapon _t, handgunWeapon _t]}) then {
            private _chest = (getPosASL _t) vectorAdd [0, 0, 1.1];
            private _time = (((_chest vectorDiff _p) vectorDotProduct _v) / _vv);

            if (_time >= 0 && {_time <= 2} && {(vectorMagnitude ((_p vectorAdd (_v vectorMultiply _time)) vectorDiff _chest)) <= 2}) then {
                _list pushBack [_projectile, _p, _v, time, _t];
                _added = _added + 1;
            };
        };
    };
} forEach _targets;

if (_added == 0) exitWith {};

missionNamespace setVariable ["TAC_hit_tracked", _list];

if (TAC_wpn_debug) then {
    systemChat format ["[TAC isabet] izlenen mermi eklendi | uzaklik %1 m | hiz %2 m/s | hedef sayisi %3 | atici %4", round (_p distance ACE_player), round (sqrt _vv), _added, if (isNull _shooter) then {"?"} else {name _shooter}];
};

if ((missionNamespace getVariable ["TAC_hit_pfh", -1]) < 0) then {
    missionNamespace setVariable ["TAC_hit_pfh", [TAC_fnc_hitTrackTick, 0] call CBA_fnc_addPerFrameHandler];
};
