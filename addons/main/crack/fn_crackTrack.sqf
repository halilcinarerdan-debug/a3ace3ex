/*
    Fonksiyon: TAC_fnc_crackTrack
    Çalışma yeri: İstemci

    Patlayıcı bir mermiyi (el bombası, 40mm, roket, havan...) yok olana kadar izler; yok olduğu
    son konum patlama noktasıdır. Oyuncuya uzaklığı ve araya engel girip girmediği hesaplanıp
    TAC_fnc_crackBlast'a verilir. Yalnızca patlayıcı mermi varken çalışan tek bir kare-başı
    işleyici kullanılır; mermi bitince veya süre dolunca kendini kaldırır.

    Patlayıcı sayılma: config indirectHit >= 5 ve indirectHitRange >= 2 (sonuç önbelleğe alınır).
    Etki mesafesi, mermi menzili (indirectHitRange) 8 m'ye oranlanarak ayardaki mesafeyi 0.5x-3x
    arasında ölçekler: büyük mermi daha uzaktan hissedilir.

    Sahte patlama koruması: el bombası (GrenadeCore) 0.4 sn'den önce yok olduysa patlama sayılmaz
    (ACE Gelişmiş Fırlatma vanilla bombayı atılır atılmaz silip kendisininkini yaratır).

    Parametreler:
        0: OBJECT - mermi nesnesi
        1: STRING - mühimmat sınıfı

    Dönüş: yok
*/

params [["_projectile", objNull, [objNull]], ["_ammo", "", [""]]];

if (!TAC_crack_blast || {isNull _projectile}) exitWith {};

// Mermi sinifi basina bir kez config okunur: [patlayici mi, menzil carpani]
private _info = TAC_crack_ammoCache get _ammo;

if (isNil "_info") then {
    private _cfg = configFile >> "CfgAmmo" >> _ammo;
    private _range = getNumber (_cfg >> "indirectHitRange");
    _info = [
        (getNumber (_cfg >> "indirectHit")) >= 5 && {_range >= 2},
        ((_range / 8) max 0.5) min 3
    ];
    TAC_crack_ammoCache set [_ammo, _info];
};

if !(_info select 0) exitWith {};

// Ayni mermi iki kez izlenmesin (ACE olayi + vanilla Fired ayni nesneyi verebilir).
if (_projectile getVariable ["TAC_crack_tracked", false]) exitWith {};
_projectile setVariable ["TAC_crack_tracked", true];

private _minLife = [0, 0.4] select (_ammo isKindOf "GrenadeCore");

[{
    params ["_args", "_handle"];
    _args params ["_projectile", "_lastPos", "_rangeMul", "_start", "_minLife"];

    // Mermi hala havada: son konumu guncelle (60 sn'den uzun surerse birak).
    if (!isNull _projectile && {(time - _start) < 60}) exitWith {
        private _pos = getPosASL _projectile;
        _lastPos set [0, _pos select 0];
        _lastPos set [1, _pos select 1];
        _lastPos set [2, _pos select 2];
    };

    [_handle] call CBA_fnc_removePerFrameHandler;

    if (!isNull _projectile || {(time - _start) < _minLife}) exitWith {};

    private _unit = ACE_player;
    if (!alive _unit) exitWith {};

    private _origin = _lastPos vectorAdd [0, 0, 0.5];
    private _eyePos = eyePos _unit;
    private _distance = _origin vectorDistance _eyePos;
    private _range = TAC_crack_blastDist * _rangeMul;

    if (_distance >= _range) exitWith {};

    // Engel: patlama noktasi ile goz arasinda yuzey var mi (duvar, zemin, arac).
    private _occluded = count (lineIntersectsSurfaces [_origin, _eyePos, _unit, vehicle _unit, true, 1, "FIRE", "NONE"]) > 0;

    [_distance, _range, _occluded] call TAC_fnc_crackBlast;
}, 0, [_projectile, getPosASL _projectile, _info select 1, time, _minLife]] call CBA_fnc_addPerFrameHandler;
