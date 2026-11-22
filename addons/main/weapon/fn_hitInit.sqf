/*
    Fonksiyon: TAC_fnc_hitInit
    Çalışma yeri: TÜM makineler (sunucu / headless dahil; XEH_postInit, hasInterface kontrolünden ÖNCE)

    Silah nesnesine isabet (mermi izleme) için gereken dinleyiciler:
      - mission olayı "ProjectileCreated": bu makinede YEREL mermiler (yapay zekâ mermileri sunucuda yerel olduğundan
        dedicated sunucuda da çalışmalıdır) TAC_fnc_hitProjectile ile oyunculara karşı izlenir
      - CBA olayı "TAC_hit_ctl": Zeus ile kontrol edilen (oyuncu olmayan) birimler listesi (TAC_hit_ctlList). Zeus kontrolündeki
        askerin silahı da hedef olabilsin diye istemci kontrol ettiği birimi herkese bildirir (TAC_fnc_hitPostInit gönderir)

    Parametreler: yok
    Dönüş: yok
*/

if (isNil "TAC_hit_ctlList") then {TAC_hit_ctlList = []};

["TAC_hit_ctl", {
    params ["_unit", "_on"];

    if (isNull _unit) exitWith {};

    if (_on) then {
        TAC_hit_ctlList pushBackUnique _unit;
    } else {
        TAC_hit_ctlList = TAC_hit_ctlList - [_unit];
    };

    TAC_hit_ctlList = TAC_hit_ctlList select {!isNull _x};
}] call CBA_fnc_addEventHandler;

addMissionEventHandler ["ProjectileCreated", {
    _this call TAC_fnc_hitProjectile;
}];
