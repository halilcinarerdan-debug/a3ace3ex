/*
    Fonksiyon: TAC_fnc_nvgBatteryInfo
    Çalışma yeri: İstemci

    Bir pil eşyasının config'ten bilgisini verir (sınıf başına bir kez okunur, önbellekli):
        TAC_base   : ana sınıf (pil tablosundaki ad); yoksa sınıfın kendisi (başka modların pilleri)
        TAC_charge : eşyanın taşıdığı şarj 0..1; yoksa 1 (dolu)
        TAC_coldK  : soğuk hassasiyeti; yoksa 0.012 (alkalin AA)

    Parametreler:
        0: STRING - pil classname

    Dönüş: ARRAY - [ana sınıf, şarj 0..1, soğuk katsayısı]
*/

params [["_class", "", [""]]];

if (isNil "TAC_nvg_infoCache") then {TAC_nvg_infoCache = createHashMap};

private _key = toLower _class;
private _info = TAC_nvg_infoCache get _key;

if (isNil "_info") then {
    private _cfg = configFile >> "CfgWeapons" >> _class;
    private _base = getText (_cfg >> "TAC_base");

    if (_base isEqualTo "") then {_base = _class};

    _info = [
        _base,
        if (isNumber (_cfg >> "TAC_charge")) then {getNumber (_cfg >> "TAC_charge")} else {1},
        if (isNumber (_cfg >> "TAC_coldK")) then {getNumber (_cfg >> "TAC_coldK")} else {0.012}
    ];

    TAC_nvg_infoCache set [_key, _info];
};

_info
