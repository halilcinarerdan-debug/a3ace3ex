/*
    Fonksiyon: TAC_fnc_hitWeaponSeg
    Çalışma yeri: İstemci

    Elindeki silahın doğru parçasını verir (dipçik - namlu, ASL). Tutuş noktası: sağ el kemiği; model seçimi
    geçersiz / uzaksa (selectionPosition bazı modellerde [0,0,0] verir) göz konumundan tahmin edilir (0.45 m ileri,
    0.18 m aşağı). Birincil silah: dipçik 0.30 m geri, namlu 0.55 m ileri; tabanca: 0.05 / 0.15 m.

    Parametreler:
        0: OBJECT - birim
        1: STRING - silah classname

    Dönüş: ARRAY - [A, B, tutuş kaynağı]
*/

params ["_unit", "_weapon"];

private _handgun = _weapon isEqualTo (handgunWeapon _unit);
private _dir = vectorNormalized (_unit weaponDirection _weapon);
private _eye = eyePos _unit;
private _grip = _unit modelToWorldVisualWorld (_unit selectionPosition "RightHand");
private _source = "el";

if ((_grip distance _eye) > 1.0 || {(_grip distance _eye) < 0.05}) then {
    _grip = (_eye vectorAdd (_dir vectorMultiply 0.45)) vectorAdd [0, 0, -0.18];
    _source = "goz (tahmin)";
};

[
    _grip vectorAdd (_dir vectorMultiply ([-0.30, -0.05] select _handgun)),
    _grip vectorAdd (_dir vectorMultiply ([0.55, 0.15] select _handgun)),
    _source
]
