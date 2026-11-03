/*
    Fonksiyon: TAC_fnc_rktDudTrack
    Çalışma yeri: İstemci (atan oyuncu)

    "Hedefte patlamama" (dud): roketi uçuşta izler (kare başı, en çok 20 sn); önüne (hız x 0.05 sn, en az 4 m)
    bir yüzey (zemin, duvar, araç) girince roketi patlamadan SİLER ve çarptığı noktada kalıcı, donmuş bir
    patlamamış mühimmat nesnesi (UXO) yaratılmasını sunucudan ister ("TAC_rkt_createUxo"). Roket çarpmadan
    uçarsa ya da başka nedenle yok olursa hiçbir şey olmaz. Döngü yalnızca bu tek roket havadayken vardır.

    Parametreler:
        0: OBJECT - roket nesnesi
        1: STRING - mühimmat sınıfı

    Dönüş: yok
*/

params [["_projectile", objNull, [objNull]], ["_ammo", "", [""]]];

if (isNull _projectile || {_ammo isEqualTo ""}) exitWith {};

[{
    params ["_args", "_handle"];
    _args params ["_projectile", "_ammo", "_start"];

    if (isNull _projectile || {(time - _start) > 20}) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    private _posASL = getPosASL _projectile;
    private _velocity = velocity _projectile;
    private _distance = ((vectorMagnitude _velocity) * 0.05) max 4;
    private _end = _posASL vectorAdd ((vectorNormalized _velocity) vectorMultiply _distance);
    private _hit = lineIntersectsSurfaces [_posASL, _end, _projectile, objNull, true, 1, "GEOM", "NONE"];

    if (_hit isEqualTo []) exitWith {};

    [_handle] call CBA_fnc_removePerFrameHandler;

    private _hitPos = (_hit select 0) select 0;
    private _dir = vectorNormalized _velocity;

    deleteVehicle _projectile;

    ["TAC_rkt_createUxo", [_ammo, _hitPos, _dir]] call CBA_fnc_serverEvent;
}, 0, [_projectile, _ammo, time]] call CBA_fnc_addPerFrameHandler;
