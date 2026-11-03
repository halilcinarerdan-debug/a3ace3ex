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

_state set [0, (_state select 0) + 1];
_state set [1, false];
_state set [2, false];
_state set [3, 0];
_state set [5, false];

// Hedefte patlamama (dud): guduml olmayan roketlerde, ayni kosul carpaniyla (nem, soguk, sicak...).
if (TAC_rkt_dudChance > 0 && {!isNull _projectile} && {!((([_weapon] call TAC_fnc_rktProfile) select 0) isEqualTo "guided")}) then {
    if (random 1 < ((TAC_rkt_dudChance / 100) * (_state param [6, 1]) min 0.25)) then {
        [_projectile, _ammo] call TAC_fnc_rktDudTrack;

        if (TAC_rkt_debug) then {systemChat "[TAC roket] HEDEFTE PATLAMAYACAK (dud) - mermi izleniyor"};
    };
};
