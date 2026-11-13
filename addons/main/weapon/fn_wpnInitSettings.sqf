/*
    Fonksiyon: TAC_fnc_wpnInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Silah bakım / arıza sisteminin CBA ayarları. Sunucu da kaydetmek zorunda: global ayarlar
    sunucudan istemcilere senkronlanır ve sunucu "force" edebilir.

    Model: her silahın (birim + silah sınıfı) kir, yağ ve aşınma durumu vardır. Kir ve yağ atışla,
    ortama göre değişir; arıza ihtimali silahın gerçek güvenilirlik verisinden (MRBS, TAC_fnc_wpnProfile)
    ve bu durumdan hesaplanır ve ACE'nin kendi arıza sistemine
    (ace_overheating_fnc_jamWeapon) verilir. ACE'nin ısıya bağlı arızası ayrıca çalışmaya devam eder.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["TAC - Gerçekçilik Paketi", "Silah bakım ve arıza"];

[
    "TAC_wpn_enabled",
    "CHECKBOX",
    ["Silah bakım sistemi aktif", "Kapalıysa kir/yağ/aşınma takip edilmez ve bu sistemden arıza çıkmaz. ACE'nin kendi ısı arızası etkilenmez."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_coldWar",
    "CHECKBOX",
    ["Soğuk Savaş modu", "Açıksa sistem dönemin teknolojisine uyar: erken M16 ailesi (M16A1 / XM177 güvenilirliği, Vietnam dönemi), lityum AA pil dönem dışı sayılır (alkalin gibi davranır). S.O.G. Prairie Fire, Global Mobilization ve CSLA gibi Soğuk Savaş içerikleriyle kullanmak içindir. Sunucu zorlayabilir."],
    _category,
    false,
    true,
    {
        // dönem değişince önbellekleri temizle (profil, pil bilgisi)
        TAC_wpn_profileCache = nil;
        TAC_nvg_infoCache = nil;
    }
] call CBA_settings_fnc_init;

[
    "TAC_wpn_dirtRate",
    "SLIDER",
    ["Kirlenme hızı (1000 atışta %)", "Tüfek için 1000 atışta biriken kir yüzdesi. 60 = yaklaşık 1700 atışta tam kirli. MG x1.3, tabanca x0.5, susturucu ve ortam ayrıca çarpar."],
    _category,
    [5, 300, 60, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_wpn_lubeLoss",
    "SLIDER",
    ["Yağ kaybı (1000 atışta %)", "Atışla yağlayıcı yanıp azalır. 50 = 1000 atışta yağın yarısı gider. Yağ %30'un altına inince sürtünme arızaları başlar."],
    _category,
    [0, 300, 50, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_wpn_jamScale",
    "SLIDER",
    ["Arıza ihtimali ölçeği", "1 = gerçek güvenilirlik verisi (temiz silahta M4 ~3600, AK ~5000, M240 ~2900, M60 ~850 atışta bir tıkanma). Oyunu zorlaştırmak için artır (5 = 5 kat sık arıza). Kir/yağ/aşınma etkisi de bu ölçekle çarpılır."],
    _category,
    [0.1, 20, 1, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_wpn_jamCooldown",
    "SLIDER",
    ["Arızalar arası asgari atış", "Bu sistemden çıkan iki arıza arasında en az bu kadar atış olur (kirli silahta peş peşe tutukluk zinciri engellenir). 0 = kapalı. ACE'nin kendi ısı arızası bundan bağımsızdır."],
    _category,
    [0, 300, 60, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_wpn_mrbsTable",
    "EDITBOX",
    ["MRBS tablosu (classname=MRBS, ...)", "Bir silahın temiz-yağlı iki tıkanma arası ortalama atışını (MRBS) elle ata; yerleşik tabloyu ezer. Virgülle ayır. Örn: rhs_weap_m4a1=2500, CUP_arifle_AK74=4000"],
    _category,
    "",
    true,
    {
        params ["_value"];
        [_value] call TAC_fnc_wpnParseMrbsTable;
    }
] call CBA_settings_fnc_init;

[
    "TAC_wpn_wearLife",
    "SLIDER",
    ["Parça ömrü (atış)", "Kovan çıkarıcı/yay gibi parçaların ömrü. Aşınma arıza ihtimaline eklenir. Parça değiştirme (silahçı) sıfırlar."],
    _category,
    [1000, 100000, 15000, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_wpn_suppressorMult",
    "SLIDER",
    ["Susturucu kirlenme çarpanı", "Susturucu takılıyken kirlenme bu sayıyla çarpılır (gaz geri tepmesi). 1 = etkisiz."],
    _category,
    [1, 4, 1.6, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_wpn_env",
    "CHECKBOX",
    ["Ortam etkisi", "Yağmur, sığ suda durma ve toz/çamurlu zeminde yatma/çömelme kirlenmeyi ve arıza ihtimalini artırır. (Atış anında okunur, döngü yok.)"],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_wpn_mgThreshold",
    "SLIDER",
    ["MG sayılma eşiği (şarjör/kayış kapasitesi)", "Şarjör kapasitesi bu sayıdan büyük olan birincil silah makineli tüfek sayılır: daha çok kirlenir, daha uzun temizlenir."],
    _category,
    [30, 200, 60, 0],
    true,
    {
        missionNamespace setVariable ["TAC_wpn_catCache", createHashMap];
    }
] call CBA_settings_fnc_init;

[
    "TAC_wpn_mgTable",
    "EDITBOX",
    ["MG olarak zorla (classname, ...)", "Eşikle yanlış sınıflanan silahları elle MG yap. Virgülle ayır. Örn: arifle_MX_SW_F, rhs_weap_m249_pip_S"],
    _category,
    "",
    true,
    {
        params ["_value"];
        [_value] call TAC_fnc_wpnParseMgTable;
    }
] call CBA_settings_fnc_init;

[
    "TAC_wpn_needKit",
    "CHECKBOX",
    ["Bakım malzemesi gerekli", "Açıksa temizlik için 'Silah Bakım Kiti', yağlama için 'Silah Yağı' (her seferinde 1 tükenir) envanterde olmalı. Kapalıysa bakım eylemleri malzemesiz yapılır."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_wpn_cleanTimeMult",
    "SLIDER",
    ["Bakım süresi çarpanı", "Temizlik, yağlama, arıza giderme, parça değiştirme sürelerini çarpar. 0 = anında."],
    _category,
    [0, 5, 1, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_wpn_fx",
    "CHECKBOX",
    ["Bakım hareketi ve sesi", "Temizlik, yağlama, arıza giderme ve parça değiştirirken silah hareketi oynatılır ve ses çalınır (yakındaki oyuncular da duyar)."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_wpn_testMode",
    "CHECKBOX",
    ["Test modu", "Kirlenme, yağ kaybı ve aşınma 'Test çarpanı' kadar hızlanır ve herkes silahçı sayılır (sayısal değerleri görür, parça değiştirir). Üretimde kapalı tut."],
    _category,
    false,
    true
] call CBA_settings_fnc_init;

[
    "TAC_wpn_testMult",
    "SLIDER",
    ["Test çarpanı", "Test modunda kirlenme / yağ kaybı / aşınma hızı çarpanı. 20 ile ~85 atışta tam kirli."],
    _category,
    [1, 200, 20, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_wpn_debug",
    "CHECKBOX",
    ["Test göstergesi", "Bir arıza tetiklenince nedenini (kir/yağ/aşınma/ihtimal) ekrana yazar. Normalde oyuncuya bilgi verilmez. (Kişisel tercih)"],
    _category,
    false,
    false
] call CBA_settings_fnc_init;
