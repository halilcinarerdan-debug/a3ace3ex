/*
    Fonksiyon: TAC_fnc_crackTrack
    Çalışma yeri: İstemci

    Patlayıcı bir mermiyi (el bombası, 40mm, roket, havan...) yok olana kadar izler; yok olduğu
    son konum patlama noktasıdır. Oyuncuya uzaklığı ve araya engel girip girmediği hesaplanıp
    TAC_fnc_crackBlast'a verilir. Yalnızca patlayıcı mermi varken çalışan tek bir kare-başı
    işleyici kullanılır; mermi bitince veya süre dolunca kendini kaldırır.

    Patlayıcı sayılma (sonuç mermi sınıfı başına bir kez önbelleğe alınır):
        (indirectHit >= 5 ve indirectHitRange >= 2) veya explosive >= 0.5
    Etki mesafesi, mermi menzili (indirectHitRange) 8 m'ye oranlanarak ayardaki mesafeyi 0.5x-3x
    arasında ölçekler: büyük mermi daha uzaktan hissedilir.

    ACE Gelişmiş Fırlatma: ACE vanilla bombayı atılır atılmaz silip kendi nesnesini yaratır.
    Bu yüzden el bombası (GrenadeCore) için, atan biliniyorsa, 0.15 sn sonra atanın çevresinde aynı
    sınıftan nesne aranıp o da izlenir (ACE olayının adı/içeriği değişse bile çalışır). 0.4 sn'den
    kısa ömürlü el bombası (silinen vanilla bomba) patlama sayılmaz.

    Parametreler:
        0: OBJECT  - mermi nesnesi (null olabilir: yalnızca çevre taraması yapılır)
        1: STRING  - mühimmat sınıfı
        2: OBJECT  - (isteğe bağlı) atan; el bombası için çevre taramasını açar
        3: BOOL    - (isteğe bağlı) çevre taramasına izin ver; tarama kendini tekrar çağırmasın diye iç kullanım

    Dönüş: yok
*/

params [["_projectile", objNull, [objNull]], ["_ammo", "", [""]], ["_firer", objNull, [objNull]], ["_scan", true, [true]]];

if (!TAC_crack_blast || {_ammo isEqualTo ""}) exitWith {};

// Mermi sinifi basina bir kez config okunur: [patlayici mi, menzil carpani]
private _info = TAC_crack_ammoCache get _ammo;

if (isNil "_info") then {
    private _cfg = configFile >> "CfgAmmo" >> _ammo;
    private _hit = getNumber (_cfg >> "indirectHit");
    private _range = getNumber (_cfg >> "indirectHitRange");
    private _explosive = getNumber (_cfg >> "explosive");

    _info = [
        (_hit >= 5 && {_range >= 2}) || {_explosive >= 0.5},
        ((_range / 8) max 0.5) min 3
    ];
    TAC_crack_ammoCache set [_ammo, _info];

    if (TAC_crack_debug) then {
        systemChat format [
            "[TAC crack] mermi sinifi %1 | indirectHit %2 | indirectHitRange %3 | explosive %4 | patlayici: %5",
            _ammo, _hit, _range, _explosive, _info select 0
        ];
    };
};

if !(_info select 0) exitWith {};

private _isGrenade = _ammo isKindOf "GrenadeCore";

// ACE gelismis firlatma: vanilla bomba silindi, ACE'nin yarattigi nesneyi atanin cevresinde ara.
if (_scan && {_isGrenade} && {!isNull _firer}) then {
    [{
        params ["_firer", "_ammo"];

        {
            [_x, _ammo, objNull, false] call TAC_fnc_crackTrack;
        } forEach (nearestObjects [_firer, [_ammo], 15]);
    }, [_firer, _ammo], 0.15] call CBA_fnc_waitAndExecute;
};

if (isNull _projectile) exitWith {};

// Ayni mermi iki kez izlenmesin (vanilla Fired + ACE olayi + tarama ayni nesneyi verebilir).
if (_projectile getVariable ["TAC_crack_tracked", false]) exitWith {};
_projectile setVariable ["TAC_crack_tracked", true];

if (TAC_crack_debug) then {
    systemChat format ["[TAC crack] patlayici izleniyor: %1", _ammo];
};

private _minLife = [0, 0.4] select _isGrenade;

[{
    params ["_args", "_handle"];
    _args params ["_projectile", "_lastPos", "_rangeMul", "_start", "_minLife", "_ammo"];

    // Mermi hala havada: son konumu guncelle (60 sn'den uzun surerse birak).
    if (!isNull _projectile && {(time - _start) < 60}) exitWith {
        private _pos = getPosASL _projectile;
        _lastPos set [0, _pos select 0];
        _lastPos set [1, _pos select 1];
        _lastPos set [2, _pos select 2];
    };

    [_handle] call CBA_fnc_removePerFrameHandler;

    if (!isNull _projectile) exitWith {};

    // Cok kisa omurlu el bombasi = ACE'nin sildigi vanilla nesne, patlama degil.
    if ((time - _start) < _minLife) exitWith {};

    private _unit = ACE_player;
    if (!alive _unit) exitWith {};

    private _origin = _lastPos vectorAdd [0, 0, 0.5];
    private _eyePos = eyePos _unit;
    private _distance = _origin vectorDistance _eyePos;
    private _range = TAC_crack_blastDist * _rangeMul;

    if (TAC_crack_debug) then {
        systemChat format [
            "[TAC crack] %1 patladi | mesafe %2 m | etki mesafesi %3 m | omur %4 sn",
            _ammo,
            (round (_distance * 10)) / 10,
            round _range,
            (round ((time - _start) * 10)) / 10
        ];
    };

    if (_distance >= _range) exitWith {};

    // Engel: patlama noktasi ile goz arasinda yuzey var mi (duvar, zemin, arac).
    private _occluded = count (lineIntersectsSurfaces [_origin, _eyePos, _unit, vehicle _unit, true, 1, "FIRE", "NONE"]) > 0;

    [_distance, _range, _occluded] call TAC_fnc_crackBlast;
}, 0, [_projectile, getPosASL _projectile, _info select 1, time, _minLife, _ammo]] call CBA_fnc_addPerFrameHandler;
