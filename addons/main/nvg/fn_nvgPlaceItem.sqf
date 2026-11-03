/*
    Fonksiyon: TAC_fnc_nvgPlaceItem
    Çalışma yeri: İstemci

    Eşyayı oyuncunun envanterine ekler; yer yoksa oyuncunun ayağının dibine bırakır.

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: STRING - eşya classname ("" ise hiçbir şey yapmaz)

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_class", "", [""]]];

if (isNull _unit || {_class isEqualTo ""}) exitWith {};

if (_unit canAdd _class) then {
    _unit addItem _class;
} else {
    private _holder = createVehicle ["GroundWeaponHolder", getPosATL _unit, [], 0, "CAN_COLLIDE"];

    _holder addItemCargoGlobal [_class, 1];
};
