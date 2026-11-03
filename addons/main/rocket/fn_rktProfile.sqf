/*
    Fonksiyon: TAC_fnc_rktProfile
    Çalışma yeri: İstemci

    Fırlatıcının ateşlenmeme profili (sınıf başına bir kez, önbellekli): [kategori, taban ihtimal, etiket, kalite]
      kategori: "disposable" (tek kullanımlık: ateşlenmezse fırlatıcı atılır),
                "reloadable" (yeniden doldurulabilir omuz atarı: mühimmat çıkarılır),
                "guided"     (güdümlü füze: mühimmat çıkarılır)
    Taban ihtimaller TAHMİNDİR (yayımlanmış tek bir sayı bulunamadı): eski / Doğu bloku mühimmatı
    ve eski silahlarda yüksek, modern sistemlerde düşük alındı. Eşleşme classname alt dizesiyle;
    kayıt yoksa mühimmatın yönlendirme alanlarına bakılır (manualControl / lock / maxControlRange -> güdümlü).
    Ayardaki tablo ihtimali ezer.

    Parametreler:
        0: STRING - fırlatıcı classname

    Dönüş: ARRAY - [kategori, ihtimal 0..1, etiket, kalite]
*/

params [["_weapon", "", [""]]];

if (isNil "TAC_rkt_profileCache") then {TAC_rkt_profileCache = createHashMap};
if (isNil "TAC_rkt_map") then {[TAC_rkt_table] call TAC_fnc_rktParseTable};

private _key = toLower _weapon;
private _result = TAC_rkt_profileCache get _key;

if (!isNil "_result") exitWith {_result};

// [alt dizeler, kategori, ihtimal, etiket]
private _table = [
    [["m72", "rpg18", "rpg22", "rpg26", "rpg75", "rshg"], "disposable", 0.02, "Tek kullanımlık (eski / Doğu)"],
    [["m136", "at4", "nlaw", "apilas"], "disposable", 0.01, "Tek kullanımlık (modern)"],
    [["panzerfaust", "pf60"], "disposable", 0.05, "Panzerfaust (eski)"],
    [["rpg7", "rpg32"], "reloadable", 0.02, "RPG-7 tipi"],
    [["smaw", "maaws", "mk153", "mraws", "carl"], "reloadable", 0.008, "Modern omuz atarı"],
    [["javelin", "titan", "stinger", "fim92", "igla", "strela", "metis", "vorona", "tow", "9k"], "guided", 0.025, "Güdümlü füze"]
];

private _profile = [];

{
    _x params ["_patterns", "_category", "_chance", "_label"];

    if (_patterns findIf {(_key find _x) >= 0} >= 0) exitWith {
        _profile = [_category, _chance, _label, "tahmin"];
    };
} forEach _table;

if (_profile isEqualTo []) then {
    private _cfg = configFile >> "CfgWeapons" >> _weapon;
    private _mags = getArray (_cfg >> "magazines");
    private _ammo = if (_mags isEqualTo []) then {""} else {getText (configFile >> "CfgMagazines" >> (_mags select 0) >> "ammo")};
    private _ammoCfg = configFile >> "CfgAmmo" >> _ammo;
    private _guided = _ammo != "" && {
        (getNumber (_ammoCfg >> "manualControl")) > 0
        || {(getNumber (_ammoCfg >> "maxControlRange")) > 0}
        || {(getNumber (_ammoCfg >> "irLock")) > 0}
        || {(getNumber (_ammoCfg >> "laserLock")) > 0}
        || {(getNumber (_ammoCfg >> "airLock")) > 0}
    };

    _profile = if (_guided) then {
        ["guided", 0.025, "Güdümlü (genel)", "tahmin"]
    } else {
        ["reloadable", 0.02, "Omuz atarı (genel)", "tahmin"]
    };
};

private _override = TAC_rkt_map getOrDefault [_key, -1];

if (_override >= 0) then {
    _profile set [1, _override];
    _profile set [2, (_profile select 2) + " (elle)"];
    _profile set [3, "ayar"];
};

TAC_rkt_profileCache set [_key, _profile];

_profile
