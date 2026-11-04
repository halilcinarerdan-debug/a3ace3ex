/*
    Fonksiyon: TAC_fnc_trtInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Sabit silah / taret (StaticWeapon: DShK, M2, KORD, TOW, Metis, Titan statik...) sistemi ayarı.
    Kapsam: kayışlı statik MG'lerde besleme prosedürü + kir / yağ / aşınma / arıza; güdümlü statik
    fırlatıcılarda (TOW, Metis, Titan...) atış hazırlığı prosedürü + pil / soğutma + ateşlenmeme.
    Diğer ayarlar (arıza ölçeği, bakım süresi, hazırlık gerekli mi...) ilgili modüllerin ayarlarını paylaşır.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["TAC - Gerçekçilik Paketi", "Sabit silah / taret"];

[
    "TAC_trt_enabled",
    "CHECKBOX",
    ["Sabit silah / taret sistemi aktif", "Kapalıysa statik silahlar (DShK, M2, KORD, TOW...) bakım / hazırlık / arıza sistemi dışında kalır."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;
