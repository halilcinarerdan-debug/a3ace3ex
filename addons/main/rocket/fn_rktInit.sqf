/*
    Fonksiyon: TAC_fnc_rktInit
    Çalışma yeri: TÜM makineler (XEH_postInit.sqf çağırır, hasInterface kontrolünden ÖNCE)

    SUNUCU: "TAC_rkt_createUxo" olayını dinler: [mühimmat sınıfı, konum ASL, yön]. Patlamamış mühimmatı
    (UXO) çarpma noktasında yaratır, simülasyonunu kapatır (donar, patlamaz, düşmez) ve herkese
    görünür / kalıcı yapar (görev bitene veya Zeus silene kadar). enableSimulationGlobal yalnızca
    sunucuda çalıştığı için nesne sunucuda yaratılır.

    Parametreler: yok
    Dönüş: yok
*/

if (!isServer) exitWith {};

["TAC_rkt_createUxo", {
    params ["_ammo", "_posASL", "_dir"];

    if !(isClass (configFile >> "CfgAmmo" >> _ammo)) exitWith {};

    private _object = createVehicle [_ammo, [0, 0, 1000], [], 0, "CAN_COLLIDE"];

    if (isNull _object) exitWith {};

    _object enableSimulationGlobal false;
    _object setVelocity [0, 0, 0];
    _object setPosASL (_posASL vectorAdd [0, 0, 0.05]);
    _object setVectorDirAndUp [_dir, [0, 0, 1]];
    _object setVariable ["TAC_rkt_uxo", true, true];
}] call CBA_fnc_addEventHandler;
