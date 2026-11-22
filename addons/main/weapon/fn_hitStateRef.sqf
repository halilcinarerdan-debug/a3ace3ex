/*
    Fonksiyon: TAC_fnc_hitStateRef
    Çalışma yeri: İstemci

    Silahın "hasarlı" işaretinin tutulduğu durum dizisini ve dizindeki yerini verir:
      - birincil silah / tabanca: bakım durumu (TAC_fnc_wpnGetState), dizin 10
      - roketatar: roketatar durumu (TAC_fnc_rktGetState), dizin 11
    Parametreler:
        0: OBJECT - birim
        1: STRING - silah classname

    Dönüş: ARRAY - [durum dizisi (referans), dizin]
*/

params ["_unit", "_weapon"];

if (_weapon isEqualTo (secondaryWeapon _unit)) then {
    [[_unit, _weapon] call TAC_fnc_rktGetState, 11]
} else {
    [[_unit, _weapon] call TAC_fnc_wpnGetState, 10]
}
