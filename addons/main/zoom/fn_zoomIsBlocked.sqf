/*
    Fonksiyon: TAC_fnc_zoomIsBlocked
    Çalışma yeri: İstemci

    Çıplak göz zoom'u şu an engellenmeli mi? Sağ tık / zoom tuşu basıldığında çağrılır.
    Koşullar (hepsi): ayar açık · oyuncu hayatta ve yaya · elde silah yok (currentWeapon boş).
    Dürbün da bir "silah" olduğu için (currentWeapon <> "") dürbün zoom'u etkilenmez; silah çekilince
    sağ tık normal nişan alır.

    Parametreler: yok
    Dönüş: BOOL
*/

if (!TAC_zoom_blockBare) exitWith {false};

private _unit = ACE_player;

alive _unit && {isNull objectParent _unit} && {(currentWeapon _unit) isEqualTo ""}
