/*
    Fonksiyon: TAC_fnc_stressPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    - CBA "unit" oyuncu olayı: birim değişince (respawn) "Suppressed" dinleyicisini yeniden bağlar,
      stresi sıfırlar.
    - CBA yerel olayı "TAC_suppressed": [unit, mesafe, atıcı, mühimmat]. Mermi geçişi buradan
      dağıtılır; stres bu olayı dinler (5. özellik de aynı olayı kullanacak).
    Döngü yalnızca stres varken çalışır.

    Parametreler: yok
    Dönüş: yok
*/

["TAC_suppressed", {
    _this call TAC_fnc_stressOnSuppressed;
}] call CBA_fnc_addEventHandler;

["unit", {
    params ["_newUnit", "_oldUnit"];

    call TAC_fnc_stressReset;
    [_newUnit, _oldUnit] call TAC_fnc_stressAttach;
}, true] call CBA_fnc_addPlayerEventHandler;

diag_log "[TAC][STRESS] hazir";
