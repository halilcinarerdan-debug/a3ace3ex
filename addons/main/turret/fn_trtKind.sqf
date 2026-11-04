/*
    Fonksiyon: TAC_fnc_trtKind
    Çalışma yeri: İstemci

    Sabit silahın bu sistemdeki türü (silah sınıfı başına bir kez, önbellekli):
      (tür mühimmat SİMÜLASYONUNDAN belirlenir; kurşun atan silah asla "guided" olmaz)
      "guided"   : mühimmat roket / füze ve roketatar profili güdümlü (TOW, Metis, Kornet, Konkurs, Fagot, Spike, Igla, Stinger, Titan...)
      "launcher" : güdümsüz statik fırlatıcı (SPG-9, recoilless...): mühimmat simülasyonu roket / füze
      "mg"       : kayışlı: ilk şarjör >= 50 mermi (bombaatar kayışları >= 20: Mk19, GMG, AGS-30) ve mühimmat
                   simülasyonu kurşun / bomba / topçu mermisi (shotBullet, shotGrenade, shotShell)
      "other"    : diğerleri (havan, top vb.)
    Şarjör bilgisi silah config'inde yoksa araçtaki taret şarjörüne bakılır (bazı RHS / CUP statikleri).

    Parametreler:
        0: STRING - silah classname
        1: OBJECT - (isteğe bağlı) araç; config'te şarjör yoksa yedek kaynak

    Dönüş: STRING
*/

params [["_weapon", "", [""]], ["_veh", objNull, [objNull]]];

if (_weapon isEqualTo "") exitWith {"other"};

if (isNil "TAC_trt_kindCache") then {TAC_trt_kindCache = createHashMap};

private _key = toLower _weapon;
private _kind = TAC_trt_kindCache get _key;

if (isNil "_kind") then {
    private _cfg = configFile >> "CfgWeapons" >> _weapon;
    private _mags = getArray (_cfg >> "magazines");

    {
        {
            _mags append (getArray _x);
        } forEach (configProperties [configFile >> "CfgMagazineWells" >> _x, "isArray _x", true]);
    } forEach (getArray (_cfg >> "magazineWell"));

    if (_mags isEqualTo [] && {!isNull _veh}) then {_mags = _veh magazinesTurret [0]};

    private _mag = if (_mags isEqualTo []) then {""} else {_mags select 0};
    private _count = getNumber (configFile >> "CfgMagazines" >> _mag >> "count");
    private _sim = toLower (getText (configFile >> "CfgAmmo" >> (getText (configFile >> "CfgMagazines" >> _mag >> "ammo")) >> "simulation"));
    private _category = ([_weapon] call TAC_fnc_rktProfile) select 0;

    _kind = "other";

    // Tur MUHIMMAT SIMULASYONUNDAN: kursun / bomba kayislari "mg", roket / fuze "launcher" ya da "guided"
    // (guduml mu: roketatar profili). Kursun atan silah hicbir zaman guduml sayilmaz (bazi kursunlarda
    // airLock / irLock alanlari vardir; profil yedegi onlari guduml sanmasin).
    if (_sim in ["shotrocket", "shotmissile"]) then {
        _kind = ["launcher", "guided"] select (_category isEqualTo "guided");
    } else {
        if (_sim isEqualTo "shotbullet" && {_count >= 50}) then {_kind = "mg"};
        if (_sim in ["shotgrenade", "shotshell"] && {_count >= 20}) then {_kind = "mg"};
    };

    TAC_trt_kindCache set [_key, _kind];
};

_kind
