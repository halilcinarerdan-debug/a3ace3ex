/*
    Fonksiyon: TAC_fnc_wpnIsBeltFed
    Çalışma yeri: İstemci

    Silah kayışlı / besleme kapaklı bir MG mi? (besleme kapağı adımı yalnızca bunlara uygulanır)
    Ölçüt (sınıf başına bir kez, önbellekli): MG kategorisi VE ACE'nin namlu değiştirilebilir MG olarak işaretlediği
    silah (config ace_overheating_allowSwapBarrel = 1: M249, M240, PKM, MG3, Mk200, MMG...) VE adı tamburlu
    / MX SW tipi olmayan ("drum", "mx_sw"). Tüfekler, tabancalar, tamburlu SW'ler ve diğer MG'ler dışarıda kalır.

    Parametreler:
        0: STRING - silah classname

    Dönüş: BOOL
*/

params [["_weapon", "", [""]]];

if (_weapon isEqualTo "") exitWith {false};

if (isNil "TAC_wpn_beltCache") then {TAC_wpn_beltCache = createHashMap};

private _key = toLower _weapon;
private _result = TAC_wpn_beltCache get _key;

if (isNil "_result") then {
    private _cat = [_weapon] call TAC_fnc_wpnCategory;

    _result = !(_cat isEqualTo [])
        && {_cat select 3}
        && {(getNumber (configFile >> "CfgWeapons" >> _weapon >> "ace_overheating_allowSwapBarrel")) == 1}
        && {(_key find "drum") < 0}
        && {(_key find "mx_sw") < 0};

    TAC_wpn_beltCache set [_key, _result];
};

_result
