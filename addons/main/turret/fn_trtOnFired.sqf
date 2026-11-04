/*
    Fonksiyon: TAC_fnc_trtOnFired
    Çalışma yeri: İstemci (oyuncunun "FiredMan" olayı: sabit silahtan atış)

    Sabit silahtan atış çıktığında (araç statik silah ve atan kişi gunner):
      MG      : kir / yağ / aşınma artar (kişisel silahlarla aynı oranlar, MG x1.3), arıza zarı atılır;
                arıza çıkarsa silah tutukluk yapar (tetik tık verir) "Arızayı gider" yapılana kadar
      Güdümlü : sistem kapanır (pil düşer), atış sayısı +1, zar / hazırlık / prosedür sıfırlanır

    Parametreler: FiredMan olayı: [unit, weapon, muzzle, mode, ammo, magazine, projectile, vehicle]
    Dönüş: yok
*/

params ["_unit", "_weapon", "", "", "_ammo", "", "", "_veh"];

if (!TAC_trt_enabled || {isNull _veh} || {!(_veh isKindOf "StaticWeapon")}) exitWith {};

private _kind = [_weapon, _veh] call TAC_fnc_trtKind;

if (_kind isEqualTo "other") exitWith {};

private _state = [_veh, _weapon] call TAC_fnc_trtState;

if (_kind in ["guided", "launcher"]) exitWith {
    // Guduml: sistem acik kalir (yeniden guc / hazirlik istenmez); statik firlaticida her atis hazirligi sifirlar.
    if !(_kind isEqualTo "guided" && {TAC_rkt_guided}) then {
        [_state] call TAC_fnc_rktPowerOff;
        _state set [5, false];
        _state set [10, 0];
    };

    _state set [0, (_state select 0) + 1];
    _state set [1, false];
    _state set [2, false];
    _state set [3, 0];
    [_veh, _weapon, _state] call TAC_fnc_trtState;
};

if (!TAC_wpn_enabled || {!(_ammo isKindOf "BulletBase" || {_ammo isKindOf "GrenadeBase"} || {_ammo isKindOf "ShellBase"})}) exitWith {};

private _env = [_unit] call TAC_fnc_wpnEnvFactor;
private _accel = if (TAC_wpn_testMode) then {TAC_wpn_testMult} else {1};

private _dirt = ((_state select 11) + ((TAC_wpn_dirtRate / 1000) * 1.3 * _env * _accel)) min 100;
private _lube = ((_state select 12) - ((TAC_wpn_lubeLoss / 1000) * _accel)) max 0;
private _wear = (_state select 13) + _accel;

_state set [11, _dirt];
_state set [12, _lube];
_state set [13, _wear];

private _p = [[_dirt, _lube, _wear], _env, _weapon] call TAC_fnc_wpnJamChance;

if (random 1 < _p) then {
    _state set [14, true];

    if (TAC_wpn_debug) then {
        systemChat format ["[TAC taret] ARIZA %1 | kir %2 | yag %3 | asinma %4 | ihtimal %5", _weapon, round _dirt, round _lube, round _wear, (round (_p * 10000)) / 100];
    };
};

[_veh, _weapon, _state] call TAC_fnc_trtState;
