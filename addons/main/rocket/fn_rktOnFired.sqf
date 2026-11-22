/*
    Fonksiyon: TAC_fnc_rktOnFired
    Çalışma yeri: İstemci (oyuncunun "Fired" olayı)

    Fırlatıcıdan gerçekten bir atış çıktığında: atış sayacı +1, zar sıfırlanır (bir sonraki yüklü
    mühimmat için yeniden atılır). Yalnızca birincil olmayan ikincil silah (fırlatıcı) için.

    Parametreler: Fired olayı: [unit, weapon, ...]
    Dönüş: yok
*/

params ["_unit", "_weapon", "", "", "_ammo", "", "_projectile"];

if (!TAC_rkt_enabled || {!(_weapon isEqualTo (secondaryWeapon _unit))}) exitWith {};

private _state = [_unit, _weapon] call TAC_fnc_rktGetState;

// GUVENLIK AGI: tetik engeli (DefaultAction) herhangi bir nedenle atlandiysa (hazir degil, guduml sartlar yok, ateslenmeme
// zari "ateslenmeyecek" demisti) atis GERI ALINIR: roket silinir, harcanan mermi geri verilir, durum degismez.
private _cancelReason = "";

if (TAC_hit_enabled && {TAC_hit_unusable} && {_state param [11, false]}) then {
    _cancelReason = "firlatici hasarli (mermi isabeti)";
} else {
if (TAC_rkt_prepare && {!(_state select 5)}) then {
    _cancelReason = "hazirlik yapilmamis";
} else {
    if (TAC_rkt_guided && {(([_weapon] call TAC_fnc_rktProfile) select 0) isEqualTo "guided"}) then {
        private _why = [_state] call TAC_fnc_rktGuidedCheck;
        if !(_why isEqualTo "") then {_cancelReason = "guduml: " + _why};
    };
};
};

if (_cancelReason isEqualTo "" && {_state select 1} && {_state select 2}) then {_cancelReason = "ateslenmeme (misfire) isaretli"};

if !(_cancelReason isEqualTo "") exitWith {
    if (!isNull _projectile) then {deleteVehicle _projectile};
    _unit setAmmo [_weapon, (_unit ammo _weapon) + 1];

    if (TAC_rkt_debug) then {systemChat format ["[TAC roket] atis GERI ALINDI (guvenlik agi) | neden: %1", _cancelReason]};

    // misfire ise bekleme / sayac isleri (tik + bekleme) tetik yolundaki gibi islesin
    if (_state select 2) then {[objNull, _unit] call TAC_fnc_rktMisfireDo};
};

private _keep = TAC_rkt_guided && {(([_weapon] call TAC_fnc_rktProfile) select 0) isEqualTo "guided"};

// Guduml: sistem acik kalir (guc / sogutma / hazirlik atistan sonra yeniden istenmez; yalnizca soguma suresi
// bitince ya da pil bosalinca kapanir). Digerlerinde her atis hazirligi sifirlar.
if (!_keep) then {
    [_state] call TAC_fnc_rktPowerOff;
    _state set [5, false];
    _state set [10, 0];
};

_state set [0, (_state select 0) + 1];
_state set [1, false];
_state set [2, false];
_state set [3, 0];
[_unit, _weapon] call TAC_fnc_rktPublish;

// Hedefte patlamama (dud): guduml olmayan roketlerde, ayni kosul carpaniyla (nem, soguk, sicak...).
if (TAC_rkt_dudChance > 0 && {!isNull _projectile} && {!((([_weapon] call TAC_fnc_rktProfile) select 0) isEqualTo "guided")}) then {
    if (random 1 < ((TAC_rkt_dudChance / 100) * (_state param [6, 1]) min 0.25)) then {
        [_projectile, _ammo] call TAC_fnc_rktDudTrack;

        if (TAC_rkt_debug) then {systemChat "[TAC roket] HEDEFTE PATLAMAYACAK (dud) - mermi izleniyor"};
    };
};
