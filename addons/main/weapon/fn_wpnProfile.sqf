/*
    Fonksiyon: TAC_fnc_wpnProfile
    Çalışma yeri: İstemci

    Silahın gerçekçi güvenilirlik profili (sınıf başına bir kez hesaplanır, önbellekli):
        [MRBS, kir duyarlılığı, yağ duyarlılığı, etiket, kalite]

    MRBS = "Mean Rounds Between Stoppages": temiz, yağlı, normal koşulda iki tıkanma arası ortalama atış.
    Atış başına temel arıza ihtimali = 1 / MRBS (TAC_fnc_wpnJamChance bunu kir/yağ/aşınma/ortam ile çarpar).

    Kir duyarlılığı: tam kirli silahta MRBS'in ne kadar düştüğünü belirler: çarpan = 1 + duyarlılık x 40.
      40, ABD Ordusu 2007 aşırı toz testinden türetildi (60.000 atış, her modelden 10 silah): M4 yaklaşık
      68-195 MRBS (temizde ~3600); HK416 ~257; FN SCAR-L ~265; XM8 ~470.
        M4/M16 (doğrudan gaz) = 1.0  ->  3600 / 41 = ~88 MRBS (aralıkta)
        HK416 = 0.41 (4500 / 17.4 = 257), SCAR = 0.35 (4000 / 15 = 265), XM8 = 0.24 (5000 / 10.6 = 472)
    Yağ duyarlılığı: kuru silahta (yağ 0) MRBS'in düşüşü: çarpan = 1 + duyarlılık x 10.

    Sıra önemlidir: ilk eşleşen kayıt geçerli. Eşleşme, classname'in küçük harfli halinde alt dize arar;
    "=ad" biçimindeki kayıt tam eşitlik ister (kısa adların başka silahlara çarpmasını önlemek için).
    Kayıt yoksa kalibreye (ilk şarjörün mühimmat adından) ve kategoriye (tüfek / MG / tabanca) göre
    genel değer kullanılır. Ayardaki "MRBS tablosu" (classname=MRBS) MRBS'i ezer.

    Kalite: "kaynak" = yayımlanmış test verisi var; "tahmin" = yayımlanmış sayı bulunamadı, bilinen
    itibar / aile benzerliğine göre ayarlandı (README'deki tabloya bak).

    Parametreler:
        0: STRING - silah classname

    Dönüş: ARRAY - [mrbs, kir duyarlılığı, yağ duyarlılığı, etiket, kalite]
*/

params [["_weapon", "", [""]]];

if (isNil "TAC_wpn_profileCache") then {TAC_wpn_profileCache = createHashMap};
if (isNil "TAC_wpn_mrbsMap") then {[TAC_wpn_mrbsTable] call TAC_fnc_wpnParseMrbsTable};

private _key = toLower _weapon;
private _result = TAC_wpn_profileCache get _key;

if (!isNil "_result") exitWith {_result};

// [alt dizeler, MRBS, kir duyarliligi, yag duyarliligi, etiket, kalite]
private _table = [
    // --- Surgulu tufekler (ilk: "mosin_sbr", "cz750" gibi adlar baska satirlara carpmasin) ---
    [["remington700", "awm", "cz550", "cz750", "leeenfield", "mosin", "kar98", "m38", "t5000", "orsis", "m2010", "xm2010", "lrr", "m24sws", "cup_srifle_m24", "m40a"], 15000, 0.2, 0.3, "Sürgülü tüfek", "tahmin"],
    // --- Makineli tufekler ---
    [["m60"], 850, 0.6, 0.6, "M60", "kaynak"],
    [["m240", "mk48"], 2900, 0.55, 0.5, "M240 / Mk48", "kaynak"],
    [["m249", "minimi", "mk46", "saw_base", "lmg_03"], 1000, 0.6, 0.6, "M249 / Minimi", "tahmin"],
    [["pkm", "pkp", "pecheneg", "zafir"], 3000, 0.35, 0.4, "PKM / PKP", "tahmin"],
    [["lmg_mg3", "mg42", "uk59"], 2500, 0.5, 0.5, "MG3 / MG42", "tahmin"],
    [["rpk"], 4500, 0.3, 0.3, "RPK", "tahmin"],
    [["arifle_mx_sw"], 1800, 0.6, 0.6, "MX SW", "tahmin"],
    // --- Dogrudan gazli AR (M16 / M4 / AR-15 ailesi) ---
    [["m16a1", "xm16e1"], 1500, 1.2, 1.0, "M16A1", "tahmin"],
    [["m16"], 3600, 1.0, 1.0, "M16A2 / A4", "kaynak"],
    [["m4a1", "m4a3", "m4_", "mk18", "mk12", "colt727", "_sbr"], 3600, 1.0, 1.0, "M4 / M4A1", "kaynak"],
    [["sr25", "m110", "mk11", "l129a1", "rsass", "dmr_02", "dmr_03"], 3200, 0.9, 0.9, "SR-25 / AR-10 tipi", "tahmin"],
    // --- Piston / modern ---
    [["hk416", "m27", "hk_m27"], 4500, 0.41, 0.5, "HK416 / M27", "kaynak"],
    [["scar", "mk16", "mk17", "cup_arifle_mk20"], 4000, 0.35, 0.5, "FN SCAR", "kaynak"],
    [["xm8"], 5000, 0.24, 0.4, "XM8", "kaynak"],
    [["g36", "mg36"], 4000, 0.45, 0.5, "G36", "tahmin"],
    [["l85", "l86"], 2500, 0.6, 0.6, "L85A2", "tahmin"],
    [["hk417", "g3_", "_g3", "rhs_weap_g3"], 4000, 0.4, 0.5, "G3 / HK417", "tahmin"],
    [["fal", "l1a1", "fnfal", "gewehr1", "stg58", "stgw57", "dsa_sa58"], 3500, 0.6, 0.6, "FAL", "tahmin"],
    [["m14", "cup_srifle_m21", "ebr", "dmr_06"], 3000, 0.6, 0.6, "M14", "tahmin"],
    [["famas", "aug", "acr", "tavor", "x95", "cz805", "bren2", "vhs2", "vhsd2", "vhsk2", "xm29", "m29_ke", "arifle_spar", "arifle_ctar", "arifle_arx", "arifle_trg", "arifle_mk20"], 4000, 0.45, 0.5, "Modern 5.56 (piston/bullpup)", "tahmin"],
    // --- AK ve turevleri ---
    [["_ak", "ak74", "akm", "ak47", "groza", "romat", "type_56", "type56", "sa58", "sa56", "vz58", "saiga", "siage", "galil", "arifle_katiba", "rhs_weap_m21", "rhs_weap_m70", "rhs_weap_m92"], 5000, 0.25, 0.3, "AK ailesi", "tahmin"],
    [["mp44"], 3500, 0.5, 0.5, "StG 44", "tahmin"],
    // --- MX ---
    [["arifle_mx"], 3600, 0.6, 0.6, "MX", "tahmin"],
    // --- Keskin nisanci ---
    [["svd", "vss", "vikhr", "asval", "as_val", "ksvk", "rhs_weap_m76"], 4000, 0.4, 0.4, "SVD / VSS / AS Val", "tahmin"],
    [["m107", "gm6", "as50"], 2000, 0.5, 0.5, "Ağır keskin nişancı", "tahmin"],
    [["m1garand", "sks"], 3000, 0.5, 0.5, "Eski yarı otomatik", "tahmin"],
    // --- Pompali / SMG ---
    [["m590", "izh18", "hunter"], 8000, 0.3, 0.3, "Pompalı", "tahmin"],
    [["m1014", "spas12", "aa12", "sgun"], 3000, 0.5, 0.5, "Yarı otomatik pompalı", "tahmin"],
    [["mp5", "mp7", "p90", "ps90", "smg_0"], 4000, 0.5, 0.5, "MP5 / MP7 / P90 / modern SMG", "tahmin"],
    [["uzi", "mac10", "tec9", "m3a1", "bizon", "vityaz", "sa61", "smg_evo"], 3000, 0.7, 0.6, "Eski / ucuz SMG", "tahmin"],
    // --- Tabancalar ---
    [["=rhsusf_weap_m9", "=cup_hgun_m9", "92fs", "beretta"], 5000, 0.5, 0.5, "Beretta M9", "tahmin"],
    [["glock"], 6000, 0.4, 0.4, "Glock", "tahmin"],
    [["p07", "p30", "p99", "rook40", "cz75", "browning_hp", "hgun_compact", "duty", "m17"], 5000, 0.45, 0.45, "Modern 9 mm tabanca", "tahmin"],
    [["1911", "acpc2", "mk23", "heavy_01"], 2500, 0.7, 0.7, "M1911 / .45 ACP", "tahmin"],
    [["deagle"], 1500, 0.8, 0.8, "Desert Eagle", "tahmin"],
    [["makarov", "_pm", "pya", "pb6p9", "_tt"], 4000, 0.3, 0.3, "Makarov / TT", "tahmin"],
    [["zubr", "swm327", "taurus", "revolver", "pistol_heavy_02"], 12000, 0.2, 0.2, "Revolver", "tahmin"]
];

private _profile = [];

{
    _x params ["_patterns", "_mrbs", "_dirtSens", "_lubeSens", "_label", "_quality"];

    if (_patterns findIf {
        // "=ad" tam esitlik (kisa adlarin yanlis eslesmesini onler), digerleri alt dize
        if ((_x select [0, 1]) isEqualTo "=") then {_key isEqualTo (_x select [1])} else {(_key find _x) >= 0}
    } >= 0) exitWith {
        _profile = [_mrbs, _dirtSens, _lubeSens, _label, _quality];
    };
} forEach _table;

// --- Kayit yoksa: kalibre + kategori --------------------------------------
if (_profile isEqualTo []) then {
    private _cfg = configFile >> "CfgWeapons" >> _weapon;
    private _cat = [_weapon] call TAC_fnc_wpnCategory;
    private _catName = if (_cat isEqualTo []) then {"rifle"} else {_cat select 0};

    private _mags = getArray (_cfg >> "magazines");
    {
        {
            _mags append (getArray _x);
        } forEach (configProperties [configFile >> "CfgMagazineWells" >> _x, "isArray _x", true]);
    } forEach (getArray (_cfg >> "magazineWell"));

    private _ammo = if (_mags isEqualTo []) then {""} else {toLower (getText (configFile >> "CfgMagazines" >> (_mags select 0) >> "ammo"))};
    private _has = {params ["_list"]; _list findIf {(_ammo find _x) >= 0} >= 0};

    _profile = switch (true) do {
        case (_catName isEqualTo "pistol"): {[4000, 0.5, 0.5, "Tabanca (kalibreye göre)", "tahmin"]};
        case (["338", "93x64", "127x", "12.7", "50bmg", "408"] call _has): {[2000, 0.5, 0.5, "Ağır kalibre", "tahmin"]};
        case (["762x39", "7.62x39"] call _has): {[4500, 0.3, 0.3, "7.62x39 (kalibreye göre)", "tahmin"]};
        case (["762x51", "762x54", "7.62x51", "7.62x54", "65x39", "65x47", "68x43", "58x42", "308"] call _has): {
            if (_catName isEqualTo "mg") then {[2500, 0.5, 0.5, "7.62/6.5 MG (kalibreye göre)", "tahmin"]} else {[3500, 0.55, 0.55, "7.62/6.5 tüfek (kalibreye göre)", "tahmin"]}
        };
        case (["545", "556", "5.56", "5.45", "223", "58x"] call _has): {
            if (_catName isEqualTo "mg") then {[1000, 0.6, 0.6, "5.56 MG (kalibreye göre)", "tahmin"]} else {[3200, 0.6, 0.6, "5.56/5.45 tüfek (kalibreye göre)", "tahmin"]}
        };
        case (["9x", "45", "357", "40sw", "57x28", "46x30", "10mm"] call _has): {[3500, 0.5, 0.5, "Tabanca kalibreli (SMG)", "tahmin"]};
        default {[3000, 0.6, 0.6, "Genel", "tahmin"]};
    };
};

// Ayardaki tablo MRBS'i ezer.
private _override = TAC_wpn_mrbsMap getOrDefault [_key, -1];
if (_override > 0) then {
    _profile set [0, _override];
    _profile set [3, (_profile select 3) + " (elle)"];
    _profile set [4, "ayar"];
};

TAC_wpn_profileCache set [_key, _profile];

_profile
