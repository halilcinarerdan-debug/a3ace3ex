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
