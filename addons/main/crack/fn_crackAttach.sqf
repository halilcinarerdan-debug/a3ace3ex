/*
    Fonksiyon: TAC_fnc_crackAttach
    Çalışma yeri: İstemci

    Oyuncu birimine patlama algılama olaylarını bağlar, eskisinden kaldırır:
      - "Explosion": oyuncu patlamadan hasar aldı (yakın patlama, doğrudan etki) -> crackBlast(0)
      - "Fired": oyuncunun kendi fırlattığı/attığı patlayıcı (kendi bombası yakınına düşebilir) -> izleme
      - "FiredNear": çevredeki (~69 m) birimlerin attığı patlayıcılar -> izleme
    FiredNear her yakın atışta çalışır; ilk iş önbellekli bir hashmap araması yapar ve patlayıcı
    olmayan mermiyi (kurşun) hemen bırakır. Yalnızca oyuncuya bağlı; yapay zekâ için maliyet yok.

    Parametreler:
        0: OBJECT - yeni birim
        1: OBJECT - eski birim (olmayabilir)

    Dönüş: yok
*/

params [["_newUnit", objNull, [objNull]], ["_oldUnit", objNull, [objNull]]];

if (!isNull _oldUnit) then {
    {
        _x params ["_event", "_var"];
        private _id = _oldUnit getVariable [_var, -1];

        if (_id >= 0) then {_oldUnit removeEventHandler [_event, _id]};
        _oldUnit setVariable [_var, -1];
    } forEach [
        ["Explosion", "TAC_crack_ehExplosion"],
        ["Fired", "TAC_crack_ehFired"],
        ["FiredNear", "TAC_crack_ehFiredNear"]
    ];
};

if (isNull _newUnit || {(_newUnit getVariable ["TAC_crack_ehExplosion", -1]) >= 0}) exitWith {};

// Explosion: [vehicle, damage]
_newUnit setVariable ["TAC_crack_ehExplosion", _newUnit addEventHandler ["Explosion", {
    [0] call TAC_fnc_crackBlast;
}]];

// Fired: [unit, weapon, muzzle, mode, ammo, magazine, projectile, gunner]
_newUnit setVariable ["TAC_crack_ehFired", _newUnit addEventHandler ["Fired", {
    params ["_unit", "", "", "", "_ammo", "", "_projectile"];
    [_projectile, _ammo, _unit] call TAC_fnc_crackTrack;
}]];

// FiredNear: [unit, firer, distance, weapon, muzzle, mode, ammo, gunner]  (mermi nesnesi verilmez)
_newUnit setVariable ["TAC_crack_ehFiredNear", _newUnit addEventHandler ["FiredNear", {
    params ["_unit", "_firer", "", "", "", "", "_ammo"];

    if (_firer isEqualTo _unit) exitWith {};

    // Kurşunları hemen ele (önbellek crackTrack'te dolar; ilk atışta bir kez config okunur).
    private _info = TAC_crack_ammoCache get _ammo;
    if (!isNil "_info" && {!(_info select 0)}) exitWith {};

    private _projectile = nearestObject [_firer, _ammo];
    [_projectile, _ammo, _firer] call TAC_fnc_crackTrack;
}]];
