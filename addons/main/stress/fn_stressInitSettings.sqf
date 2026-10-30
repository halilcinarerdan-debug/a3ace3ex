/*
    Fonksiyon: TAC_fnc_stressInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    "Baskı altında artan sway" ayarlarını CBA_settings_fnc_init ile kaydeder.
    Oyuncunun yakınından geçen her mermi stres seviyesini (0..1) yükseltir; seviye
    "Sönüm süresi" boyunca doğrusal azalır. Sway çarpanı:
        çarpan = 1 + (Maksimum çarpan - 1) * seviye * (1 + nabız * sin(zaman))

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["TAC - Gerçekçilik Paketi", "Baskı altında sway"];

[
    "TAC_stress_enabled",
    "CHECKBOX",
    ["Baskı altında sway aktif", "Yakınından mermi geçince sway geçici olarak artar."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_stress_maxMult",
    "SLIDER",
    ["Maksimum sway çarpanı", "Stres seviyesi 1 iken sway'in kaç katına çıkacağı."],
    _category,
    [1, 10, 3, 2],
    true
] call CBA_settings_fnc_init;

[
    "TAC_stress_range",
    "SLIDER",
    ["Stres eşiği: mermi mesafesi (m)", "Mermi bu mesafeden daha yakın geçerse stres yükselir. Daha uzaktan geçenler sayılmaz."],
    _category,
    [2, 50, 12, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_stress_gain",
    "SLIDER",
    ["Mermi başına stres artışı", "Çok yakın bir geçişin ekleyeceği stres (0..1). Mesafe arttıkça etki azalır. 1 = tek mermi tavana çıkarır."],
    _category,
    [0.05, 1, 0.3, 2],
    true
] call CBA_settings_fnc_init;

[
    "TAC_stress_decay",
    "SLIDER",
    ["Sönüm süresi (sn)", "Ateş kesildikten sonra tam stresin sıfıra inmesi için gereken süre."],
    _category,
    [3, 60, 15, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_stress_pulse",
    "SLIDER",
    ["Nabız dalgalanması", "Sway'in nabız gibi dalgalanma oranı. 0 = düz azalma."],
    _category,
    [0, 0.5, 0.15, 2],
    true
] call CBA_settings_fnc_init;

[
    "TAC_stress_friendly",
    "CHECKBOX",
    ["Dost atışı da stres yapsın", "Kapalıysa yalnızca düşman/tarafsız mermiler stres yükseltir."],
    _category,
    false,
    true
] call CBA_settings_fnc_init;

[
    "TAC_stress_swayVar",
    "EDITBOX",
    ["Sway değişkeni (auto = otomatik)", "ACE sway ayarının değişken adı. auto: ace_common_swayFactor, yoksa ace_advanced_fatigue_swayFactor, o da yoksa setCustomAimCoef."],
    _category,
    "auto",
    true
] call CBA_settings_fnc_init;

[
    "TAC_stress_debug",
    "CHECKBOX",
    ["Test göstergesi", "Stres seviyesini, uygulanan çarpanı ve hedef değişkeni ekranda gösterir. (Kişisel tercih)"],
    _category,
    false,
    false
] call CBA_settings_fnc_init;
