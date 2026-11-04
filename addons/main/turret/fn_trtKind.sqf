/*
    Fonksiyon: TAC_fnc_trtKind
    Çalışma yeri: İstemci

    Sabit silahın bu sistemdeki türü (silah sınıfı başına bir kez, önbellekli):
      "guided": roketatar profili güdümlü (TOW, Metis, Titan, Igla...)
      "mg"    : ilk şarjör >= 50 mermi ve mühimmat simülasyonu kurşun (DShK, M2, KORD, statik M240...)
      "other" : diğerleri (bu sistem dışında)

    Parametreler:
        0: STRING - silah classname

    Dönüş: STRING
*/

params [["_weapon", "", [""]]];

if (_weapon isEqualTo "") exitWith {"other"};

if (isNil "TAC_trt_kindCache") then {TAC_trt_kindCache = createHashMap};

private _key = toLower _weapon;
private _kind = TAC_trt_kindCache get _key;

if (isNil "_kind") then {
    if ((([_weapon] call TAC_fnc_rktProfile) select 0) isEqualTo "guided") then {
        _kind = "guided";
    } else {
        private _cfg = configFile >> "CfgWeapons" >> _weapon;
        private _mags = getArray (_cfg >> "magazines");

        {
            {
                _mags append (getArray _x);
            } forEach (configProperties [configFile >> "CfgMagazineWells" >> _x, "isArray _x", true]);
        } forEach (getArray (_cfg >> "magazineWell"));

        private _mag = if (_mags isEqualTo []) then {""} else {_mags select 0};
        private _count = getNumber (configFile >> "CfgMagazines" >> _mag >> "count");
        private _sim = toLower (getText (configFile >> "CfgAmmo" >> (getText (configFile >> "CfgMagazines" >> _mag >> "ammo")) >> "simulation"));

        _kind = if (_count >= 50 && {_sim isEqualTo "shotbullet"}) then {"mg"} else {"other"};
    };

    TAC_trt_kindCache set [_key, _kind];
};

_kind
