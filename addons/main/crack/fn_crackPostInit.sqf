/*
    Fonksiyon: TAC_fnc_crackPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    - CBA yerel olayı "TAC_suppressed" (4. özellikteki Suppressed dinleyicisi üretir):
      [unit, mesafe, atıcı, mühimmat, hız]. Her mermi geçişinde koşulları kontrol eder.
    - CBA "unit" oyuncu olayı: birim değişince (respawn) efekti anında temizler.
    Döngü yok; efekt yalnızca tetiklenince, zamanlayıcılarla çalışır.

    Parametreler: yok
    Dönüş: yok
*/

["TAC_suppressed", {
    _this call TAC_fnc_crackOnSuppressed;
}] call CBA_fnc_addEventHandler;

["unit", {
    [-1] call TAC_fnc_crackEnd;
}] call CBA_fnc_addPlayerEventHandler;

diag_log "[TAC][CRACK] hazir";
