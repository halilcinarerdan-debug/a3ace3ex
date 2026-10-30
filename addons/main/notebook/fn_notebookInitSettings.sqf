/*
    Fonksiyon: TAC_fnc_notebookInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    CBA ayarlarını CBA_settings_fnc_init ile kaydeder (CBA_fnc_addSetting ile aynı fonksiyon).
    Sunucu da kaydetmek ZORUNDA: "global" ayarlar sunucudan istemcilere senkronlanır ve
    sunucu yöneticisi "force" ile kilitleyebilir.

    Parametreler (sırayla):
        0: ayar adı (global değişken adı olur)
        1: tür  - "CHECKBOX" | "SLIDER" | "EDITBOX" | "LIST" | "COLOR" | "TIME"
        2: [başlık, ipucu]
        3: [kategori, alt kategori]
        4: varsayılan değer (türe göre; SLIDER için [min, max, varsayılan, ondalık])
        5: isGlobal - true: sunucu ayarı, istemcilere senkron + force edilebilir
                      false: her oyuncunun kendi tercihi
*/

private _category = ["TAC - Gerçekçilik Paketi", "Taktiksel Not Defteri"];

[
    "TAC_notebook_enabled",
    "CHECKBOX",
    ["Not defteri aktif", "Kapalıysa ACE menüsünde 'Taktiksel Not Defteri' görünmez."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_notebook_itemClass",
    "EDITBOX",
    ["Gerekli eşya (classname)", "Bu eşya envanterde/atanmış eşyalarda varsa menü açılır. Varsayılan: ItemCompass"],
    _category,
    "ItemCompass",
    true
] call CBA_settings_fnc_init;

[
    "TAC_notebook_mode",
    "LIST",
    ["Not defteri modu", "Basit: 'Not Al' / 'Notları Oku' (otomatik zaman + koordinat). Gelişmiş: oyuncu Notepad gibi serbest metin yazar."],
    _category,
    [[0, 1], ["Basit (zaman + koordinat)", "Gelişmiş (serbest yazı)"], 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_notebook_maxChars",
    "SLIDER",
    ["[Gelişmiş] Maksimum karakter", "Serbest yazı modunda not defterine yazılabilecek toplam karakter. Aşılırsa fazlası kesilir."],
    _category,
    [500, 20000, 5000, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_notebook_maxEntries",
    "SLIDER",
    ["[Basit] Maksimum not sayısı", "Aşılırsa en eski notlar silinir."],
    _category,
    [5, 100, 40, 0],
    true
] call CBA_settings_fnc_init;

[
    "TAC_notebook_writeTime",
    "SLIDER",
    ["[Basit] Not yazma süresi (sn)", "ACE ilerleme çubuğu süresi. 0 = anında."],
    _category,
    [0, 10, 2, 1],
    true
] call CBA_settings_fnc_init;

[
    "TAC_notebook_clearOnDeath",
    "CHECKBOX",
    ["Ölünce notlar silinsin", "Açıksa yeniden doğan oyuncunun not defteri boş başlar."],
    _category,
    false,
    true
] call CBA_settings_fnc_init;

[
    "TAC_notebook_notify",
    "CHECKBOX",
    ["Kayıt bildirimi göster", "Not alınınca ekranda onay mesajı çıkar. (Kişisel tercih)"],
    _category,
    true,
    false
] call CBA_settings_fnc_init;
