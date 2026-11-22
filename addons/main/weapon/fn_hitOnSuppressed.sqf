/*
    Fonksiyon: TAC_fnc_hitOnSuppressed
    Çalışma yeri: İstemci (CBA yerel olayı "TAC_suppressed")

    Silah nesnesine isabet testi (TAC_hit_mode 1 veya 2): mermi oyuncunun yanından geçerken (vanilla "Suppressed"),
    mermi yolu (konum + hız vektörü doğrusu) ile elindeki silahın doğrusu (dipçik - namlu parçası) arasındaki en
    yakın mesafe TAC_hit_weaponRadius cm'den azsa silah vurulmuş sayılır; TAC_hit_chance ihtimalle silah hasar görür
    ve elden düşer (TAC_fnc_hitDisable). Silah mermiyi motor düzeyinde durdursa bile olay tetiklenir.
    Silah parçası: elin (RightHand) yanından weaponDirection yönünde; birincil silah dipçik 0.30 m geri, namlu 0.55 m
    ileri; tabanca 0.05 m geri, 0.15 m ileri (yaklaşık). Mermi konumu / hızı yoksa test yapılmaz.

    Parametreler (olay): [unit, mesafe, atıcı, mühimmat, hız, mermi konumu ASL, hız vektörü]
    Dönüş: yok
*/

params ["_unit", "_distance", "_shooter", "_ammo", ["_speed", -1], ["_pos", []], ["_vel", []]];

if (!hasInterface || {!TAC_hit_enabled} || {TAC_hit_mode == 0} || {!TAC_hit_unusable && {!TAC_hit_drop}}) exitWith {};
if (!(_unit isEqualTo ACE_player) || {!alive _unit} || {_pos isEqualTo []} || {_vel isEqualTo []}) exitWith {};
if (_distance > 3) exitWith {};
if (time < (_unit getVariable ["TAC_hit_next", 0])) exitWith {};

private _weapon = currentWeapon _unit;

if (_weapon isEqualTo "" || {!(_weapon in [primaryWeapon _unit, handgunWeapon _unit])}) exitWith {};
if (([_weapon] call TAC_fnc_wpnCategory) isEqualTo []) exitWith {};
if !((toLower (getText (configFile >> "CfgAmmo" >> _ammo >> "simulation"))) isEqualTo "shotbullet") exitWith {};

private _speedMag = vectorMagnitude _vel;
if (_speedMag < 50) exitWith {};

private _handgun = _weapon isEqualTo (handgunWeapon _unit);
private _dir = vectorNormalized (_unit weaponDirection _weapon);
private _grip = _unit modelToWorldVisualWorld (_unit selectionPosition "RightHand");

// Silah parcasi A -> B (ASL)
private _a = _grip vectorAdd (_dir vectorMultiply ([-0.30, -0.05] select _handgun));
private _b = _grip vectorAdd (_dir vectorMultiply ([0.55, 0.15] select _handgun));

// Mermi parcasi C -> D (+/- 3 m, ASL)
private _vn = vectorNormalized _vel;
private _c = _pos vectorAdd (_vn vectorMultiply -3);
private _d = _pos vectorAdd (_vn vectorMultiply 3);

// Iki dogru parcasi arasindaki en kisa mesafe (Ericson)
private _u = _b vectorDiff _a;
private _v = _d vectorDiff _c;
private _w = _a vectorDiff _c;
private _aa = _u vectorDotProduct _u;
private _bb = _u vectorDotProduct _v;
private _cc = _v vectorDotProduct _v;
private _dd = _u vectorDotProduct _w;
private _ee = _v vectorDotProduct _w;
private _det = (_aa * _cc) - (_bb * _bb);

private _s = if (_det < 1e-6) then {0} else {(((_bb * _ee) - (_cc * _dd)) / _det) max 0 min 1};
private _t = ((_bb * _s) + _ee) / (_cc max 1e-6);

if (_t < 0) then {_t = 0; _s = ((-_dd) / (_aa max 1e-6)) max 0 min 1};
if (_t > 1) then {_t = 1; _s = ((_bb - _dd) / (_aa max 1e-6)) max 0 min 1};

private _closest = vectorMagnitude ((_a vectorAdd (_u vectorMultiply _s)) vectorDiff (_c vectorAdd (_v vectorMultiply _t)));

if (TAC_wpn_debug) then {
    systemChat format ["[TAC silah] mermi yolu - silah mesafesi %1 cm (esik %2 cm)", (round (_closest * 1000)) / 10, TAC_hit_weaponRadius];
};

if (_closest > (TAC_hit_weaponRadius / 100)) exitWith {};
if ((random 100) >= TAC_hit_chance) exitWith {};

_unit setVariable ["TAC_hit_next", time + 3];
[_unit, _weapon] call TAC_fnc_hitDisable;
