/*
    Fonksiyon: TAC_fnc_wpnTargetWeapon
    Çalışma yeri: İstemci

    Bakım eylemlerinin hedef silahı: YALNIZCA ELDE SEÇİLİ silah, o da takip ediliyorsa (tüfek / MG / tabanca).
    Elde silah yoksa (sırtta, seçili değil, fırlatıcı seçili vb.) "" döner ve bakım menüsü açılmaz.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: STRING - silah classname, yoksa ""
*/

params [["_unit", objNull, [objNull]]];

private _weapon = currentWeapon _unit;

if (!(_weapon isEqualTo "") && {!(([_weapon] call TAC_fnc_wpnCategory) isEqualTo [])}) exitWith {_weapon};

""
