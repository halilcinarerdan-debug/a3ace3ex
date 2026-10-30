/*
    Fonksiyon: TAC_fnc_recoilRefresh
    Çalışma yeri: İstemci (CBA ayar değişiminde çağrılır)

    Önbelleği sıfırlayıp mevcut silah için çarpanı yeniden hesaplar. Ayarlar mission/menü
    açılırken oyuncu henüz yokken de çağrılabilir; o durumda sessizce çıkar.

    Parametreler: yok
    Dönüş: yok
*/

if (!hasInterface || {!(missionNamespace getVariable ["TAC_recoil_ready", false])}) exitWith {};

private _unit = ACE_player;
if (isNull _unit) exitWith {};

_unit setVariable ["TAC_recoil_ammo", "<yok>"];
[_unit] call TAC_fnc_recoilUpdate;
