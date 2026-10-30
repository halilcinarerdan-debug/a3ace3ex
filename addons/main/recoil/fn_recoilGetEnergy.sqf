/*
    Fonksiyon: TAC_fnc_recoilGetEnergy
    Çalışma yeri: İstemci

    Bir mühimmatın namlu kinetik enerjisini (Joule) config'ten hesaplar:
        E = 0.5 * kütle(kg) * hız(m/s)^2

    Kütle: CfgAmmo >> ACE_bulletMass (grain; ACE gelişmiş balistik verisi, RHS/vanilla çoğunda var).
    Hız:   CfgAmmo >> typicalSpeed (yoksa 800 m/s varsayılır).
    ACE kütlesi yoksa yaklaşık tahmin: E ~ hit^2 * 20 (5.56 ~1600, 7.62x51 ~2900 civarı).
    Mermi olmayan mühimmat (roket, el bombası, havan...) için -1 döner: recoil'e dokunulmaz.

    Sonuçlar önbelleğe alınır (mühimmat başına bir kez hesaplanır).

    Parametreler:
        0: STRING - mühimmat classname (CfgAmmo)

    Dönüş: NUMBER - Joule, mermi değilse -1
*/

params [["_ammo", "", [""]]];

if (_ammo isEqualTo "") exitWith {-1};

if (isNil "TAC_recoil_energyCache") then {
    TAC_recoil_energyCache = createHashMap;
};

private _key = toLower _ammo;
private _cached = TAC_recoil_energyCache getOrDefault [_key, -2];

if (_cached > -2) exitWith {_cached};

private _config = configFile >> "CfgAmmo" >> _ammo;
private _energy = -1;

if (isClass _config && {(toLower (getText (_config >> "simulation"))) isEqualTo "shotbullet"}) then {
    private _speed = getNumber (_config >> "typicalSpeed");
    if (_speed <= 0) then {_speed = 800};

    private _massGrains = getNumber (_config >> "ACE_bulletMass");

    _energy = if (_massGrains > 0) then {
        0.5 * (_massGrains * 0.0000647989) * (_speed ^ 2)
    } else {
        ((getNumber (_config >> "hit")) ^ 2) * 20
    };
};

TAC_recoil_energyCache set [_key, _energy];

_energy
