/*
    Fonksiyon: TAC_fnc_crackPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    - CBA yerel olayı "TAC_suppressed" (4. özellikteki Suppressed dinleyicisi üretir):
      [unit, mesafe, atıcı, mühimmat, hız]. Her mermi geçişinde koşulları kontrol eder.
    - CBA "unit" oyuncu olayı: birim değişince (respawn) efekti anında temizler ve patlama
      dinleyicilerini (Explosion / Fired / FiredNear) yeni birime bağlar.
    - ACE "ace_throwableThrown" (Gelişmiş Fırlatma): ACE'nin yarattığı gerçek bomba nesnesini izler.
    Sürekli döngü yok; kare-başı işleyici yalnızca havadaki patlayıcı varken çalışır.

    Parametreler: yok
    Dönüş: yok
*/

if (isNil "TAC_crack_ammoCache") then {TAC_crack_ammoCache = createHashMap};

["TAC_suppressed", {
    _this call TAC_fnc_crackOnSuppressed;
}] call CBA_fnc_addEventHandler;

["unit", {
    params ["_newUnit", "_oldUnit"];

    [-1] call TAC_fnc_crackEnd;
    [_newUnit, _oldUnit] call TAC_fnc_crackAttach;
}, true] call CBA_fnc_addPlayerEventHandler;

// ACE Gelismis Firlatma: [unit, projectile]. Olay yoksa/adi farkliysa sessizce hicbir sey olmaz.
["ace_throwableThrown", {
    params ["", "_projectile"];
    if (isNull _projectile) exitWith {};

    [_projectile, typeOf _projectile] call TAC_fnc_crackTrack;
}] call CBA_fnc_addEventHandler;

diag_log "[TAC][CRACK] hazir";
