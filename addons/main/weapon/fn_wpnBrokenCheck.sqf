/*
    Fonksiyon: TAC_fnc_wpnBrokenCheck
    Çalışma yeri: İstemci (ACE "DefaultAction" koşulu)

    Elindeki silah hasarlıysa (isabet; bakım durumu indeks 10) ateş engellenir: true döner.
    Hızlı çıkışlar: sistem kapalı, silah birincil / tabanca değil, durum yok.

    Parametreler (ACE koşulu): [hedef, birim]
    Dönüş: BOOL - true = ateş engellenir
*/

params ["", "_unit"];

if (!TAC_hit_enabled || {!TAC_hit_unusable}) exitWith {false};

private _weapon = currentWeapon _unit;
if (_weapon isEqualTo "" || {!(_weapon in [primaryWeapon _unit, handgunWeapon _unit])}) exitWith {false};

private _all = _unit getVariable "TAC_wpn_state";
if (isNil "_all") exitWith {false};

private _state = _all get (toLower _weapon);
if (isNil "_state") exitWith {false};

_state param [10, false]
