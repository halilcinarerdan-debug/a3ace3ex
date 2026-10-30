/*
    Fonksiyon: TAC_fnc_recoilInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Dinamik recoil ayarlarını CBA_settings_fnc_init ile kaydeder. Her kalibre için ayrı ayar
    yerine 5 KATEGORİ vardır; kategori, mermi kinetik enerjisinden (Joule) belirlenir:

        1 Tabanca / PDW          enerji <  t1
        2 Hafif (5.56 / 5.45)    t1 <= enerji < t2
        3 Orta (7.62x39 / 6.5)   t2 <= enerji < t3
        4 Ağır (7.62x51 / 54R)   t3 <= enerji < t4
        5 Aşırı (.338 / .50)     enerji >= t4

    Her kategori için bir çarpan vardır. Çarpan, silahın MEVCUT recoil'inin (config + ACE + A3RO)
    ÜSTÜNE biner (setUnitRecoilCoefficient). Son çarpan "Maksimum çarpan" ile sınırlanır:
    silah ekrana/kameraya girmesin diye tavan.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["TAC - Gerçekçilik Paketi", "Recoil"];
private _refresh = {call TAC_fnc_recoilRefresh};

[
    "TAC_recoil_enabled",
    "CHECKBOX",
    ["Dinamik recoil aktif", "Kalibre/enerji kategorisine göre recoil çarpanı uygular."],
    _category,
    true,
    true,
    _refresh
] call CBA_settings_fnc_init;

[
    "TAC_recoil_scale",
    "SLIDER",
    ["Genel ölçek", "Tüm kategori çarpanlarına uygulanan ek ölçek. 1 = olduğu gibi."],
    _category,
    [0.1, 3, 1, 2],
    true,
    _refresh
] call CBA_settings_fnc_init;

[
    "TAC_recoil_maxCoef",
    "SLIDER",
    ["Maksimum çarpan (tavan)", "Hiçbir silah bu çarpanı aşamaz. Silah ekrana/kameraya giriyorsa düşür."],
    _category,
    [1, 8, 3, 2],
    true,
    _refresh
] call CBA_settings_fnc_init;

// Kategori sınırları (Joule). Sıra karışırsa kodda otomatik sıralanır.
private _thresholds = [
    ["TAC_recoil_t1", "Sınır 1: Tabanca/PDW <-> Hafif (J)", 1000],
    ["TAC_recoil_t2", "Sınır 2: Hafif <-> Orta (J)", 1950],
    ["TAC_recoil_t3", "Sınır 3: Orta <-> Ağır (J)", 3000],
    ["TAC_recoil_t4", "Sınır 4: Ağır <-> Aşırı (J)", 5500]
];

{
    _x params ["_name", "_title", "_default"];

    [
        _name,
        "SLIDER",
        [_title, "Mermi kinetik enerjisi eşiği (Joule). Örnek: 5.56 ~1700, 7.62x39 ~2100, 7.62x51 ~3300, .338 ~6500."],
        _category,
        [100, 20000, _default, 0],
        true,
        _refresh
    ] call CBA_settings_fnc_init;
} forEach _thresholds;

// Kategori çarpanları. Varsayılanlar bilerek yüksek: geri tepme hissi belirgin ama tavan korur.
private _multipliers = [
    ["TAC_recoil_m1", "Çarpan 1: Tabanca / PDW", 1.2],
    ["TAC_recoil_m2", "Çarpan 2: Hafif (5.56 / 5.45)", 1.5],
    ["TAC_recoil_m3", "Çarpan 3: Orta (7.62x39 / 6.5)", 1.9],
    ["TAC_recoil_m4", "Çarpan 4: Ağır (7.62x51 / 7.62x54R)", 2.4],
    ["TAC_recoil_m5", "Çarpan 5: Aşırı (.338 / .50)", 2.9]
];

{
    _x params ["_name", "_title", "_default"];

    [
        _name,
        "SLIDER",
        [_title, "Bu kategorideki silahların mevcut recoil'i bu sayıyla çarpılır. 1 = değişmez."],
        _category,
        [0.1, 6, _default, 2],
        true,
        _refresh
    ] call CBA_settings_fnc_init;
} forEach _multipliers;

[
    "TAC_recoil_overrides",
    "EDITBOX",
    ["Kategori istisnaları (mühimmat=kategori, ...)", "Yanlış sınıflanan mühimmatı elle ata. Kategori 1-5, 0 = bu mühimmatta recoil değişmesin. Örn: B_762x51_Ball=4, rhs_ammo_556x45_M855A1_Ball=2"],
    _category,
    "",
    true,
    {
        params ["_value"];
        [_value] call TAC_fnc_recoilParseOverrides;
        call TAC_fnc_recoilRefresh;
    }
] call CBA_settings_fnc_init;

[
    "TAC_recoil_debug",
    "CHECKBOX",
    ["Test göstergesi", "Silah/mühimmat değiştikçe ekranda enerji, kategori ve çarpanı gösterir. (Kişisel tercih)"],
    _category,
    false,
    false
] call CBA_settings_fnc_init;
