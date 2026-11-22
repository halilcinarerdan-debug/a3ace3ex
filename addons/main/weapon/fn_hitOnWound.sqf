/*
    Fonksiyon: TAC_fnc_hitOnWound
    Çalışma yeri: İstemci (isabet alan oyuncu; ACE "ace_medical_woundReceived" ya da vanilla HandleDamage)

    Oyuncuya mermi isabet edince:
      1) Göz kapanması (TAC_hit_blink): hasar >= asgari ise ekran kararır (TAC_fnc_hitBlink).
      2) Silah isabeti (TAC_hit_enabled): isabet KOL / EL ise ve elde birincil silah ya da tabanca varsa
         TAC_hit_chance ihtimalle silah hasar görür ve elden düşer (TAC_fnc_hitDisable).
    Yalnızca mermi (simülasyon shotBullet) sayılır; patlama / düşme vb. etkilemez. Aynı isabetin birden çok
    yara kaydı için 0.25 sn kilit vardır.

    Parametreler: [unit, hasarlar ([[hasar, bölge, ...]] ya da bölge adı), atıcı, mühimmat]
    Dönüş: yok
*/

params ["_unit", ["_damages", []], ["_shooter", objNull], ["_ammo", ""]];

if (!hasInterface || {!(_unit isEqualTo ACE_player)} || {!alive _unit}) exitWith {};

if (TAC_wpn_debug) then {
    systemChat format ["[TAC isabet] yara olayi geldi | muhimmat %1 | hasarlar %2", _ammo, _damages];
};

if !(_ammo isEqualType "") exitWith {};
if !((toLower (getText (configFile >> "CfgAmmo" >> _ammo >> "simulation"))) isEqualTo "shotbullet") exitWith {
    if (TAC_wpn_debug) then {systemChat "[TAC isabet] yara atlandi: mermi turu kursun degil"};
};

if (time < (_unit getVariable ["TAC_hit_lock", 0])) exitWith {};
_unit setVariable ["TAC_hit_lock", time + 0.25];

// Hasar toplami ve kol isabeti
private _total = 0;
private _arm = false;

// Hangi bolgeler silahi vurur (CBA "Silah isabeti: hangi bolge"): 0 kol / el, 1 kol + govde, 2 hepsi
private _zones = [
    ["leftarm", "rightarm"],
    ["leftarm", "rightarm", "body", "torso"],
    ["leftarm", "rightarm", "body", "torso", "head", "leftleg", "rightleg"]
] select (TAC_hit_zone max 0 min 2);

if (_damages isEqualType "") then {
    _arm = (toLower _damages) in _zones;
} else {
    {
        if (_x isEqualType [] && {count _x > 1}) then {
            private _part = _x select 1;
            if (_part isEqualType "" && {(toLower _part) in _zones}) then {_arm = true};
            if ((_x select 0) isEqualType 0) then {_total = _total + (_x select 0)};
        };
    } forEach _damages;
};

// 1) Goz kapanmasi
if (TAC_hit_blink && {_total >= TAC_hit_blinkMinHit || {_damages isEqualType ""}}) then {
    [_total] call TAC_fnc_hitBlink;
};

// 2) Silah isabeti
if (!TAC_hit_enabled || {TAC_hit_mode == 1} || {!_arm} || {!TAC_hit_unusable && {!TAC_hit_drop}}) exitWith {};
if (time < (_unit getVariable ["TAC_hit_next", 0])) exitWith {};

private _weapon = currentWeapon _unit;

if (_weapon isEqualTo "" || {!(_weapon in [primaryWeapon _unit, handgunWeapon _unit])}) exitWith {};
if (([_weapon] call TAC_fnc_wpnCategory) isEqualTo []) exitWith {};
if ((random 100) >= TAC_hit_chance) exitWith {};

_unit setVariable ["TAC_hit_next", time + 3];
[_unit, _weapon] call TAC_fnc_hitDisable;
