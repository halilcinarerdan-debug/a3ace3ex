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
    ["Yanık sıcaklık eşiği (°C)", "Çıkarılan namlunun ACE sıcaklığı bu değerin üstündeyse yanık oluşur. Gerçekte ~60 °C'de deri yanar. Test göstergesini açıp namlu değiştirince ACE'nin verdiği gerçek sıcaklığı görebilirsin."],
    _category,
    [50, 500, 100, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_mg_burnDamage",
    "SLIDER",
    ["Maksimum yanık hasarı", "Eşiğin 350 °C üstündeki sıcaklıkta verilen hasar (ACE tıbbı, sağ kol). Eşikte bunun %50'si. ACE tıbbı menüsünde sağ kolda termal yanık yarası olarak görünür."],
    _category,
    [0, 1, 0.6, 2],
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
