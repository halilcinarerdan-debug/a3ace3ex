/*
    Fonksiyon: TAC_fnc_nvgInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    NVG pili modülünün CBA ayarlarını CBA_settings_fnc_init ile kaydeder.
    Sunucu da kaydetmek zorunda: global ayarlar sunucudan istemcilere senkronlanır ve
    sunucu "force" edebilir.

    Pil ömrü (gerçek dakika) = pil_saati * TAC_nvg_minutesPerHour    ( / test hızlandırması )
    pil_saati, takılı pilin classname'ine göre "Pil tablosu"ndan okunur.
    Örnek: 40 saat * 1 dk = 40 dakika NVG kullanımı (1 "pil saati" = 1 gerçek dakika).

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["TAC - Gerçekçilik Paketi", "NVG Pili"];

[
    "TAC_nvg_enabled",
    "CHECKBOX",
    ["NVG pili sistemi aktif", "Kapalıysa NVG sınırsız çalışır ve pil değiştirme eylemi görünmez."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_nvg_batteryHours",
    "SLIDER",
    ["Varsayılan pil ömrü (gerçek hayatta saat)", "Oyuncunun başlangıçtaki takılı piline ve tabloda olmayan pillere uygulanır. AN/PVS-14 tek AA pille yaklaşık 40 saat çalışır."],
    _category,
    [1, 100, 40, 0],
    true
] call CBA_settings_fnc_init;

// classname=saat çiftleri, ',' ile ayrılır (';' CBA ayar dosyasında komut ayracı: import'u bozar). Sıra = öncelik: pil değiştirirken envanterde bulunan
// ilk pil kullanılır. Başka modların eşyaları da yazılabilir.
[
    "TAC_nvg_batteryTable",
    "EDITBOX",
    ["Pil tablosu (classname=saat, ...)", "Her pil türünün gerçek hayattaki ömrü (saat). Örn: TAC_NVGBattery=40, TAC_NVGBattery_Lithium=60. Sıra öncelik sırasıdır."],
    _category,
    "TAC_NVGBattery=40, TAC_NVGBattery_Lithium=60",
    true,
    {
        params ["_value"];
        [_value] call TAC_fnc_nvgParseBatteryTable;
    }
] call CBA_settings_fnc_init;

// classname=çarpan çiftleri, ',' ile ayrılır. Takılı NVG (hmd) sınıfının pil tüketimini ölçekler.
// Tabloda olmayan cihaz 1. Başka modların (RHS, CUP, TMT) gözlükleri de yazılabilir.
[
    "TAC_nvg_deviceTable",
    "EDITBOX",
    ["Cihaz tüketim çarpanı (classname=çarpan, ...)", "Takılı NVG'nin pil tüketimini ölçekler: 1 = normal, 1.5 = %50 fazla. Termal/füzyon gözlükler gibi daha çok çeken cihazlar için. Tabloda olmayan cihaz 1. Örn: NVGogglesB_blk_F=1.5"],
    _category,
    "NVGogglesB_blk_F=1.5, NVGogglesB_grn_F=1.5, NVGogglesB_gry_F=1.5",
    true,
    {
        params ["_value"];
        [_value] call TAC_fnc_nvgParseDeviceTable;
    }
] call CBA_settings_fnc_init;

[
    "TAC_nvg_cold",
    "CHECKBOX",
    ["Soğukta pil kapasitesi düşsün", "ACE hava durumu açıksa 20 °C altında pil daha hızlı boşalır. Alkalin AA soğuktan çok etkilenir, lityum az. (ACE hava durumu yoksa 20 °C sayılır, etki olmaz.)"],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_nvg_sag",
    "CHECKBOX",
    ["Voltaj düşümü (son %15'te hızlı boşalma)", "Şarjın son %15'inde tüketim 1x'ten 2x'e hızlanır; pil bitmeden önce daha gerçekçi sert bir düşüş olur."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_nvg_minutesPerHour",
    "SLIDER",
    ["1 pil saati = kaç gerçek dakika", "Tüketim hızı. 1 = 1 pil saati 1 gerçek dakikada biter. Pil ömrü (dk) = pil saati * bu değer."],
    _category,
    [0.1, 60, 1, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_nvg_lowThreshold",
    "SLIDER",
    ["Düşük pil eşiği (%)", "Şarj bu yüzdenin altına inince parazit ve kararma/flicker başlar, şarj azaldıkça şiddetlenir."],
    _category,
    [1, 100, 20, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_nvg_noiseMax",
    "SLIDER",
    ["Maksimum parazit şiddeti", "Şarj 0'a yaklaşırken görüntüdeki parazitin (film grain) üst sınırı. 0 = parazit yok."],
    _category,
    [0, 2, 0.8, 2],
    true
] call CBA_settings_fnc_init;

[
    "TAC_nvg_flickerMax",
    "SLIDER",
    ["Maksimum kararma/flicker şiddeti", "Şarj 0'a yaklaşırken ani sönme ve kararmanın üst sınırı. 0 = kararma yok."],
    _category,
    [0, 1, 0.7, 2],
    true
] call CBA_settings_fnc_init;

[
    "TAC_nvg_swapTime",
    "SLIDER",
    ["Pil değiştirme süresi (sn)", "ACE ilerleme çubuğu süresi. 0 = anında."],
    _category,
    [0, 15, 3, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_nvg_testMode",
    "CHECKBOX",
    ["Test modu", "Saatlerce beklememek için pil tüketimini hızlandırır ve NVG açıkken ekranda şarj/pil sınıfı/kalan süre bilgisini gösterir. Sınıflar arası ömür farkı korunur."],
    _category,
    false,
    true
] call CBA_settings_fnc_init;

[
    "TAC_nvg_testSpeed",
    "SLIDER",
    ["Test hızlandırma çarpanı", "Test modunda pil ömrü bu sayıya bölünür. 60 ile: 40 sa * 1 dk/sa = 40 dk -> 40 sn."],
    _category,
    [1, 600, 60, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_nvg_notify",
    "CHECKBOX",
    ["Pil bildirimleri", "NVG açılınca şarj yüzdesini, düşük/biten pil uyarılarını ekranda göster. (Kişisel tercih)"],
    _category,
    true,
    false
] call CBA_settings_fnc_init;
