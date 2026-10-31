/*
    Fonksiyon: TAC_fnc_zoomInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    "Sağ tık zoom" modülünün CBA ayarları. Silah nişan zoom'unu kaldıran kısım config'dedir
    (zoom/CfgWeapons.hpp, derleme anında #define ile açılıp kapanır); buradaki ayarlar yalnızca
    script ile yapılan kısmı (silahsız çıplak göz zoom'u) yönetir.

    Parametreler: yok
    Dönüş: yok
*/

private _category = ["TAC - Gerçekçilik Paketi", "Sağ tık zoom (No Zoom)"];

[
    "TAC_zoom_blockBare",
    "CHECKBOX",
    ["Silahsızken çıplak göz zoom'unu engelle", "Elinde silah yokken (currentWeapon boş, yaya) sağ tık / zoom tuşu ile yapılan zoom engellenir. Dürbün ve silah nişanı etkilenmez."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TAC_zoom_debug",
    "CHECKBOX",
    ["Test göstergesi", "Engellenen her zoom girişimini ekranda gösterir. (Kişisel tercih)"],
    _category,
    false,
    false
] call CBA_settings_fnc_init;
