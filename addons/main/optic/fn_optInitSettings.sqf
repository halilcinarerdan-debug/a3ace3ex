/*
    Fonksiyon: TAC_fnc_optInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Optik buğulanma / kirlenme sisteminin CBA ayarları. Etki yalnızca kapalı lensli (büyütmeli)
    optikten bakılırken görünür: dürbün ekranı bulanır, kontrast düşer. Kırmızı nokta / holografik
    nişangahlar (açık lens) ve demir nişan etkilenmez. Test hızlandırması silah bakım sisteminin
    test modunu kullanır (TAC_wpn_testMode / TAC_wpn_testMult).

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["TAC - Gerçekçilik Paketi", "Optik (buğu / kir)"];

[
    "TAC_opt_enabled",
    "CHECKBOX",
    ["Optik buğu / kir sistemi aktif", "Varsayılan KAPALI. Kapalıyken optik durumu takip edilmez, lens kirlenmez ve görüntü bozulmaz."],
    _category,
    false,
    true
] call CBA_settings_fnc_init;

[
    "TAC_opt_fogRate",
    "SLIDER",
    ["Buğulanma hızı (saniyede %)", "Optikten bakarken, soğukta (10 °C altı) ve yağmurda/sığ suda lensin buğulanma hızı. Tam koşulda (çok soğuk + yağmur) bu hızla artar; koşul yoksa buğu azalır."],
    _category,
    [0, 10, 1.5, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_opt_shotDirt",
    "SLIDER",
    ["Atışla kirlenme (atış başına %)", "Her atış lense toz/barut bırakır; ortam çarpanı (yağmur, tozlu zeminde yatma) çarpar. 0.05 = ~2000 atışta tam kirli."],
    _category,
    [0, 1, 0.05, 2],
    true
] call CBA_settings_fnc_init;

[
    "TAC_opt_rainDirt",
    "SLIDER",
    ["Yağmurda damlacık birikimi (saniyede %)", "Yağmurda optikten bakarken lense su damlası/leke birikir (kir sayılır; silinince gider)."],
    _category,
    [0, 2, 0.15, 2],
    true
] call CBA_settings_fnc_init;

[
    "TAC_opt_blurMax",
    "SLIDER",
    ["En fazla bulanıklık", "Lens tamamen buğulu/kirli iken görüntüye uygulanan bulanıklık (DynamicBlur). 0 = bulanıklık yok. (Kişisel tercih)"],
    _category,
    [0, 5, 2, 1],
    false
] call CBA_settings_fnc_init;

[
    "TAC_opt_haze",
    "SLIDER",
    ["Kontrast kaybı (pus)", "Buğu/kirde görüntünün kontrastı düşer ve hafif aydınlanır. 0 = yok. Optiğin siyah çerçevesi de hafif grileşebilir; rahatsız ederse düşür. (Kişisel tercih)"],
    _category,
    [0, 1, 0.3, 2],
    false
] call CBA_settings_fnc_init;
