/*
    Fonksiyon: TAC_fnc_mgInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Makineli tüfek modülünün CBA ayarları: sıcak namlu değiştirirken yanık.
    Yedek namlu ağırlıkları config'tedir (mg/CfgMagazines.hpp), CBA ayarı yoktur.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["TAC - Gerçekçilik Paketi", "Makineli tüfek (namlu)"];

[
    "TAC_mg_burn",
    "CHECKBOX",
    ["Sıcak namluda yanık", "Sıcak bir namlu (sıcaklık eşiğinin üstü) ACE ile değiştirilirken, namluyu tutan oyuncuda 'Isı Eldiveni' yoksa elinde yanık oluşur. Oyuncuya ayrıca bildirim verilmez."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_mg_burnTemp",
    "SLIDER",
    ["Yanık sıcaklık eşiği (°C)", "Çıkarılan namlunun ACE sıcaklığı bu değerin üstündeyse yanık oluşur. Gerçekte ~60 °C'de deri yanar; ACE namluları kısa ateşte hızla 100-200 °C'yi geçer."],
    _category,
    [50, 500, 150, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_mg_burnDamage",
    "SLIDER",
    ["Maksimum yanık hasarı", "Eşiğin 350 °C üstündeki sıcaklıkta verilen hasar (ACE tıbbı, sağ kol). Eşikte bunun %30'u. Hasar sıcaklıkla doğrusal artar."],
    _category,
    [0, 1, 0.35, 2],
    true
] call CBA_settings_fnc_init;

[
    "TAC_mg_feedStep",
    "CHECKBOX",
    ["Besleme kapağı adımı", "Açıksa MG'ye şarjör / kayış takıldıktan sonra ACE self-menü > Silah Bakımı > 'Kayışı yerleştir, kapağı kapat' yapılmalı; yapılmazsa ilk atışta besleme arızası çıkar. (Silah bakım sistemi açık olmalı.)"],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_mg_chargingStep",
    "CHECKBOX",
    ["Sürgü / şarj kolu adımı", "Açıksa MG besleme prosedürüne 'sürgüyü / kolu çek' adımları da girer. Varsayılan kapalı: reload animasyonu sürgüyü zaten çeker."],
    _category,
    false,
    true
] call CBA_settings_fnc_init;

[
    "TAC_mg_debug",
    "CHECKBOX",
    ["Test göstergesi", "Namlu değiştirilince sıcaklık, eşik ve yanık kararını ekrana yazar. (Kişisel tercih)"],
    _category,
    false,
    false
] call CBA_settings_fnc_init;
