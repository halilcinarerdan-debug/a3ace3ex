/*
    Fonksiyon: TAC_fnc_crackInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    "Mermi yakın geçiş (crack)" ayarlarını CBA_settings_fnc_init ile kaydeder. Ses hızından
    (varsayılan 343 m/s) hızlı bir mermi oyuncunun kafasından birkaç metre yakından geçerse
    1-2 sn'lik tam ekran bulanıklık + kenar kararması oluşur ve (ayarlıysa) tüm HUD geçici
    kapanır.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["TAC - Gerçekçilik Paketi", "Mermi yakın geçiş (crack)"];

[
    "TAC_crack_enabled",
    "CHECKBOX",
    ["Mermi crack efekti aktif", "Ses üstü mermi çok yakından geçince şok dalgası efekti (blur + vignette) uygular."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_crack_dist",
    "SLIDER",
    ["Tetik mesafesi (m)", "Mermi kafaya bu mesafeden daha yakın geçerse efekt tetiklenir. 2-3 m önerilir."],
    _category,
    [0.5, 10, 3, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_crack_minSpeed",
    "SLIDER",
    ["Minimum mermi hızı (m/s)", "Yalnızca bu hızdan hızlı mermiler tetikler. 343 = ses hızı."],
    _category,
    [100, 1000, 343, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_crack_duration",
    "SLIDER",
    ["Efekt süresi (sn)", "Efektin toplam süresi (yaklaşık ilk %40'ı tam şiddet, kalanı sönümlenir)."],
    _category,
    [0.5, 5, 1.6, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_crack_blur",
    "SLIDER",
    ["Bulanıklık şiddeti", "Tam ekran bulanıklık (DynamicBlur). 0 = kapalı."],
    _category,
    [0, 5, 2.5, 2],
    true
] call CBA_settings_fnc_init;

[
    "TAC_crack_vignette",
    "SLIDER",
    ["Kenar kararması (vignette) şiddeti", "Ekran kenarlarının kararma yoğunluğu (0..1). 0 = kapalı."],
    _category,
    [0, 1, 0.7, 2],
    true
] call CBA_settings_fnc_init;

[
    "TAC_crack_blast",
    "CHECKBOX",
    ["Patlama efekti aktif", "El bombası, 40mm, roket, havan/top mermisi gibi yakın patlamalarda ve patlamadan hasar alınca aynı şok dalgası efekti (blur + vignette + HUD) uygulanır."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_crack_blastDist",
    "SLIDER",
    ["Patlama etki mesafesi (m)", "Standart el bombası için temel mesafe; büyük mermiler (config indirectHitRange) 3 katına kadar, küçükler yarısına kadar ölçeklenir. Şiddet mesafeyle azalır, arada engel varsa yarıya iner."],
    _category,
    [5, 80, 25, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_crack_blastDuration",
    "SLIDER",
    ["Patlama efekti süresi (sn)", "En güçlü (bitişik) patlamanın efekt süresi; uzak patlamalarda kısalır."],
    _category,
    [1, 10, 3.5, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_crack_layers",
    "SLIDER",
    ["Vignette kalitesi (katman sayısı)", "Yüksek = daha yumuşak geçiş (bantlaşma azalır) ama daha çok ekran kontrolü. Blur ile birleşince kare kare görünüyorsa artır, takılma olursa azalt. (Kişisel tercih)"],
    _category,
    [16, 96, 48, 0],
    false
] call CBA_settings_fnc_init;

[
    "TAC_crack_hideHud",
    "CHECKBOX",
    ["Efekt sırasında HUD'u kapat", "Efekt süresince tüm HUD öğeleri gizlenir, bitince eski haline döner."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_crack_cooldown",
    "SLIDER",
    ["Bekleme süresi (sn)", "Efekt başladıktan sonra yenisinin tetiklenebilmesi için geçmesi gereken süre. Seri ateşte sürekli bulanıklığı önler."],
    _category,
    [0, 15, 3, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_crack_friendly",
    "CHECKBOX",
    ["Dost atışı da tetiklesin", "Kapalıysa yalnızca düşman/tarafsız mermiler tetikler."],
    _category,
    false,
    true
] call CBA_settings_fnc_init;

[
    "TAC_crack_debug",
    "CHECKBOX",
    ["Test göstergesi", "Tetiklenen/atlanan geçişleri (hız, mesafe, neden) ekranda gösterir. (Kişisel tercih)"],
    _category,
    false,
    false
] call CBA_settings_fnc_init;
