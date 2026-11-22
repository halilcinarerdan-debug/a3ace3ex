/*
    Fonksiyon: TAC_fnc_hitOnSuppressed
    Çalışma yeri: İstemci (CBA yerel olayı "TAC_suppressed")

    Silah nesnesine isabet testi, olay yolu (TAC_hit_detect 1 veya 2): mermi oyuncunun yanından geçerken (vanilla
    "Suppressed"), mermi yolu (konum + hız vektörü doğrusu, +/- 3 m) ile elindeki silahın doğrusu arasındaki
    en yakın mesafe TAC_fnc_hitWeaponHit ile değerlendirilir. Mermi konumu / hızı yoksa test yapılmaz
    (ProjectileCreated tabanlı izleme, TAC_fnc_hitProjectile, ayrıca çalışır).

    Parametreler (olay): [unit, mesafe, atıcı, mühimmat, hız, mermi konumu ASL, hız vektörü]
    Dönüş: yok
*/

params ["_unit", "_distance", "_shooter", "_ammo", ["_speed", -1], ["_pos", []], ["_vel", []]];

if (!hasInterface) exitWith {};

private _dbg = {if (TAC_wpn_debug) then {systemChat format ["[TAC isabet] gecen mermi: %1", _this]}};

if (TAC_wpn_debug && {_unit isEqualTo ACE_player}) then {
    systemChat format ["[TAC isabet] gecen mermi olayi geldi | mesafe %1 m | mermi nesnesi %2 | hiz vektoru %3", (round (_distance * 10)) / 10, !(_pos isEqualTo []), !(_vel isEqualTo [])];
};

if (!TAC_hit_enabled) exitWith {"atlandi: ozellik kapali" call _dbg};
if (TAC_hit_detect == 0) exitWith {"atlandi: yontem 'kol / el isabeti' (geometri kapali)" call _dbg};
if (!TAC_hit_unusable && {!TAC_hit_drop}) exitWith {"atlandi: 'kullanilamaz' ve 'dussun' ikisi de kapali" call _dbg};
if (!(_unit isEqualTo ACE_player) || {!alive _unit}) exitWith {};
if (_pos isEqualTo [] || {_vel isEqualTo []}) exitWith {"atlandi: olayda mermi konumu / hizi yok (izleme yontemi devrede)" call _dbg};
if (_distance > 3) exitWith {"atlandi: mesafe > 3 m" call _dbg};

private _weapon = currentWeapon _unit;

if (_weapon isEqualTo "" || {!(_weapon in [primaryWeapon _unit, handgunWeapon _unit])}) exitWith {"atlandi: elde birincil silah / tabanca yok" call _dbg};
if (([_weapon] call TAC_fnc_wpnCategory) isEqualTo []) exitWith {"atlandi: silah takip edilmiyor" call _dbg};
if !((toLower (getText (configFile >> "CfgAmmo" >> _ammo >> "simulation"))) isEqualTo "shotbullet") exitWith {"atlandi: mermi turu kursun degil" call _dbg};

private _vn = vectorNormalized _vel;
if ((vectorMagnitude _vel) < 50) exitWith {"atlandi: mermi hizi < 50 m/s" call _dbg};

private _seg = [_unit, _weapon] call TAC_fnc_hitWeaponSeg;
private _closest = [_seg select 0, _seg select 1, _pos vectorAdd (_vn vectorMultiply -3), _pos vectorAdd (_vn vectorMultiply 3)] call TAC_fnc_hitSegDist;

[_unit, _closest, "olay", _seg select 2] call TAC_fnc_hitWeaponHit;
