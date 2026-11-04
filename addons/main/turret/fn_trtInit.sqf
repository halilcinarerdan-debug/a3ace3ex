/*
    Fonksiyon: TAC_fnc_trtInit
    Çalışma yeri: TÜM makineler (XEH_postInit.sqf çağırır, hasInterface kontrolünden ÖNCE)

    "TAC_trtSetAmmo" olayı: [araç, silah] - aracın sahibinde (yerel makinede) o silahın mühimmatını boşaltır
    (ateşlenmeyen mühimmat çıkarma). setAmmo yalnızca yerel araçta çalışır.

    Parametreler: yok
    Dönüş: yok
*/

["TAC_trtSetAmmo", {
    params ["_veh", "_weapon"];

    if (local _veh) then {_veh setAmmo [_weapon, 0]};
}] call CBA_fnc_addEventHandler;
