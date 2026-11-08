/*
    Fonksiyon: TAC_fnc_rktInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Roketatar / füze fırlatıcı sisteminin CBA ayarları. Model: her atışta, fırlatıcı türüne göre taban
    ateşlenmeme ihtimali (soğuk, ıslaklık ve tüp aşınmasıyla artar). Ateşlenmeme ATIŞ ANINDA değil, tetik
    çekilirken uygulanır: mermi hiç çıkmaz (geri tepme alanı da oluşmaz). Doktrin: bekle, sonra çıkar.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["TAC - Gerçekçilik Paketi", "Roketatar / füze"];

[
    "TAC_rkt_enabled",
    "CHECKBOX",
    ["Roketatar ateşlenmeme sistemi aktif", "Kapalıysa roketatarlar her zaman ateşlenir."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_rkt_prepare",
    "CHECKBOX",
    ["Atış öncesi hazırlık gerekli", "Açıksa her yüklü mühimmat için ACE self-menü > Roketatar > Atışa hazırla yapılmadan fırlatıcı ateşlenmez (tetik yalnızca tık sesi verir). Süre türe göre: tek kullanımlık 3, omuz atarı 5, güdümlü 6 sn (bakım süresi çarpanı uygulanır). Yeniden yükleme veya atıştan sonra hazırlık sıfırlanır."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_rkt_scale",
    "SLIDER",
    ["Ateşlenmeme ölçeği", "1 = yerleşik taban oranlar (RPG-7 tipi %2, tek kullanımlık %1-2, modern omuz atarı %0.8, güdümlü %2.5, Panzerfaust %5). Oyunu zorlaştırmak için artır."],
    _category,
    [0, 20, 1, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_rkt_dudChance",
    "SLIDER",
    ["Hedefte patlamama ihtimali (%)", "Güdümsüz roketin hedefe çarpıp PATLAMAMA ihtimali (taban); nem, soğuk, sıcak gibi koşullar çarpar. Patlamayan mühimmat çarptığı yerde KALICI olarak yerde kalır (görev bitene veya Zeus silene kadar). 0 = kapalı."],
    _category,
    [0, 20, 1.5, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_rkt_guided",
    "CHECKBOX",
    ["Güdümlü füze: pil ve soğutma", "Güdümlü füze atarları (Javelin, Titan, Stinger, Igla...) için: 'Atışa hazırla' sistemi açar; arayıcı soğuyana kadar ateşlenmez, soğuduktan sonra soğutucu sınırlı süre dayanır, açık kaldıkça pil boşalır."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_rkt_cooldown",
    "SLIDER",
    ["Arayıcı soğuma süresi (sn)", "Sistem açıldıktan sonra arayıcının ateşlemeye hazır olması için gereken süre. Sıcak havada (> 25 °C) en fazla %50 uzar."],
    _category,
    [0, 60, 12, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_rkt_coolantTime",
    "SLIDER",
    ["Soğutucu dayanma süresi (sn)", "Arayıcı soğuduktan sonra bu süre içinde ateşlenmezse ısınır; sistem 'Atışa hazırla' ile yeniden başlatılmalıdır (yeni soğuma)."],
    _category,
    [10, 600, 180, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_rkt_batteryMinutes",
    "SLIDER",
    ["Pil ömrü (açık kalma süresi, dk)", "Sistem açıkken tam pil bu kadar dakika dayanır. Pil boşken füze ateşlenmez; yedek pille 'Pili değiştir'."],
    _category,
    [1, 240, 30, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_rkt_hint",
    "CHECKBOX",
    ["Hazırlık: parça görseli", "Açıksa destekli fırlatıcılarda (şimdilik M136 AT4) hazırlık adımı yapılınca fırlatıcının ilgili parçaları kısa süre ekranda gösterilir (pim çıkar, omuz dayanağı açılır, gez/arpacık kalkar, horoz kolu kalkar). Yalnızca görsel geri bildirimdir; adımlar ACE menüsünden yapılır."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_rkt_hintTime",
    "SLIDER",
    ["Hazırlık görseli: süre (sn)", "Görselin ekranda kalma süresi."],
    _category,
    [1, 10, 3, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_rkt_waitTime",
    "SLIDER",
    ["Ateşlenmeme bekleme süresi (sn)", "Mühimmat ateşlenmezse (tık sesi), çıkarmadan önce beklenmesi gereken süre (gecikmeli ateşleme riski). Bekleme sırasında tetiğe tekrar basılırsa süre yeniden başlar."],
    _category,
    [0, 120, 30, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_rkt_table",
    "EDITBOX",
    ["Ateşlenmeme tablosu (classname=yüzde, ...)", "Bir fırlatıcının taban ateşlenmeme yüzdesini (atış başına) elle ata; yerleşik tabloyu ezer. Virgülle ayır. Örn: launch_RPG7_F=3, rhs_weap_rpg7=3"],
    _category,
    "",
    true,
    {
        params ["_value"];
        [_value] call TAC_fnc_rktParseTable;
    }
] call CBA_settings_fnc_init;

[
    "TAC_rkt_testChance",
    "SLIDER",
    ["Test: asgari ateşlenmeme ihtimali (%)", "Test için ateşlenmeme ihtimalini en az bu değere çeker (0 = kapalı). Tek kişilik testte 50-100 yap. Üretimde 0 bırak."],
    _category,
    [0, 100, 0, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_rkt_debug",
    "CHECKBOX",
    ["Test göstergesi", "Ateşlenmeme zarının sonucunu (ihtimal, soğuk, ıslaklık, aşınma) ve bekleme durumunu ekrana yazar. (Kişisel tercih)"],
    _category,
    false,
    false
] call CBA_settings_fnc_init;
