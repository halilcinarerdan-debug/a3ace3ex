/*
    Fonksiyon: TAC_fnc_hitEligible
    Çalışma yeri: İstemci / sunucu

    Silah isabeti özelliği bu silah için geçerli mi? Elde seçili silah:
      - birincil silah ya da tabanca (bakım sisteminde takip edilen), VEYA
      - roketatar (ikincil silah; TAC_hit_launchers açıksa)
    Parametreler:
        0: OBJECT - birim
        1: STRING - silah classname

    Dönüş: BOOL
*/

params ["_unit", "_weapon"];

if (_weapon isEqualTo "") exitWith {false};

if (_weapon in [primaryWeapon _unit, handgunWeapon _unit]) exitWith {
    !(([_weapon] call TAC_fnc_wpnCategory) isEqualTo [])
};

TAC_hit_launchers && {_weapon isEqualTo (secondaryWeapon _unit)}
