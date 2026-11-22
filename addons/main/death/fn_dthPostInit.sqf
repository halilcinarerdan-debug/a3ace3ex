/*
    Fonksiyon: TAC_fnc_dthPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    CBA "unit" oyuncu olayı: birim değişince (respawn dahil) TAC_fnc_dthAttach. Sürekli döngü yok.

    Parametreler: yok
    Dönüş: yok
*/

["unit", {
    params ["_newUnit", "_oldUnit"];
    [_newUnit, _oldUnit] call TAC_fnc_dthAttach;
}, true] call CBA_fnc_addPlayerEventHandler;

diag_log "[TAC][DTH] hazir";
