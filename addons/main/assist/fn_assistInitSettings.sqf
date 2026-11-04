/*
    Fonksiyon: TAC_fnc_assistInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Koop yardımı (yardımcı / arkadaş) ayarları.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["TAC - Gerçekçilik Paketi", "Koop yardımı"];

[
    "TAC_assist_enabled",
    "CHECKBOX",
    ["Arkadaşa hazırlık yardımı", "Yakındaki bir arkadaşın MG besleme prosedürünü ve roketatar atış hazırlığını onun adına yapabilirsin (ACE etkileşim menüsü > Silah yardımı)."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_assist_speed",
    "SLIDER",
    ["Yardımlı adım süre çarpanı", "Arkadaş yardım edince her adım bu çarpanla kısalır (ikili çalışma daha hızlı). 1 = yardım hız kazandırmaz."],
    _category,
    [0.2, 1, 0.7, 2],
    true
] call CBA_settings_fnc_init;
