/*
    Fonksiyon: TAC_fnc_wpnSearchKey
    Çalışma yeri: İstemci

    Silahı tanımak için arama metni: küçük harfli "classname + görünen ad" (örn. "rhs_weap_m249_pip_s m249 pip s").
    RHS / CUP / diğer modların classname'leri bazen anlaşılmazdır; prosedür ve profil tabloları (MG besleme,
    atış hazırlığı, ateşlenmeme) hem classname hem görünen ad üzerinde alt dize arar. Sınıf başına bir kez
    hesaplanır (önbellekli).

    Parametreler:
        0: STRING - silah classname

    Dönüş: STRING
*/

params [["_weapon", "", [""]]];

if (isNil "TAC_wpn_searchCache") then {TAC_wpn_searchCache = createHashMap};

private _key = toLower _weapon;
private _result = TAC_wpn_searchCache get _key;

if (isNil "_result") then {
    _result = _key + " " + toLower (getText (configFile >> "CfgWeapons" >> _weapon >> "displayName"));
    TAC_wpn_searchCache set [_key, _result];
};

_result
