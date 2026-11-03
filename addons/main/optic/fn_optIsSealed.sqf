/*
    Fonksiyon: TAC_fnc_optIsSealed
    Çalışma yeri: İstemci

    Optik kapalı lensli (büyütmeli) mi? Config: ItemInfo >> OpticsModes altında en az bir mod
    useModelOptics = 1 ise evet. Kırmızı nokta / holografik nişangahlar ve boş sınıf: hayır.
    Sınıf başına bir kez okunur (önbellekli).

    Parametreler:
        0: STRING - optik classname

    Dönüş: BOOL
*/

params [["_optic", "", [""]]];

if (_optic isEqualTo "") exitWith {false};

if (isNil "TAC_opt_sealedCache") then {TAC_opt_sealedCache = createHashMap};

private _key = toLower _optic;
private _sealed = TAC_opt_sealedCache get _key;

if (isNil "_sealed") then {
    _sealed = ("true" configClasses (configFile >> "CfgWeapons" >> _optic >> "ItemInfo" >> "OpticsModes")) findIf {getNumber (_x >> "useModelOptics") == 1} >= 0;
    TAC_opt_sealedCache set [_key, _sealed];
};

_sealed
