/*
    Fonksiyon: TAC_fnc_wpnTargetWeapon
    Çalışma yeri: İstemci

    Bakım eylemlerinin hedef silahı: elindeki silah takip ediliyorsa o, değilse birincil silah.
    Takip edilen silah yoksa "".

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: STRING - silah classname, yoksa ""
*/

params [["_unit", objNull, [objNull]]];

private _weapon = currentWeapon _unit;

if (!(_weapon isEqualTo "") && {!(([_weapon] call TAC_fnc_wpnCategory) isEqualTo [])}) exitWith {_weapon};

_weapon = primaryWeapon _unit;

if (!(_weapon isEqualTo "") && {!(([_weapon] call TAC_fnc_wpnCategory) isEqualTo [])}) exitWith {_weapon};

""
