/*
    Fonksiyon: TAC_fnc_wpnIsBeltFed
    Çalışma yeri: İstemci

    Silah kayışlı / besleme kapaklı bir MG mi? (besleme kapağı adımı yalnızca bunlara uygulanır)
    Ölçüt (sınıf başına bir kez, önbellekli): MG kategorisi VE (ACE'nin namlu değiştirilebilir MG olarak işaretlediği
    silah: config ace_overheating_allowSwapBarrel = 1; VEYA güvenilirlik profili kayışlı bir aileden: M60, M240, M249 / Minimi, PKM, MG3) VE en büyük şarjör / kayış kapasitesi >= 75 (60-70 mermilik tambur / şarjör taşıyan tüfekler kayışlı sayılmaz) VE adı vanilla "arifle_*" (MX, MX SW...) olmayan, tamburlu
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

    // ACE namlu degistirilebilir MG olarak isaretlediyse VEYA guvenilirlik profili kayisli bir aileden ise
    // (M60, M240, M249 / Minimi, PKM / PKP, MG3 / MG42): ACE isareti olmayan modlarin (TMT vb.) MG'leri de kayisli sayilir.
    private _belt = ["M60", "M240 / Mk48", "M249 / Minimi", "PKM / PKP", "MG3 / MG42"];
    private _label = ([_weapon] call TAC_fnc_wpnProfile) select 3;

    _result = !(_cat isEqualTo [])
        && {_cat select 3}
        && {(_cat param [4, 0]) >= 75}
        && {(getNumber (configFile >> "CfgWeapons" >> _weapon >> "ace_overheating_allowSwapBarrel")) == 1 || {_label in _belt}}
        && {(_key find "drum") < 0}
        && {(_key find "mx_sw") < 0}
        && {(_key select [0, 7]) != "arifle_"};

    TAC_wpn_beltCache set [_key, _result];
};

_result
