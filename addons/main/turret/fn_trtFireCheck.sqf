/*
    Fonksiyon: TAC_fnc_trtFireCheck
    Çalışma yeri: İstemci (ACE "DefaultAction" koşulu)

    Gunner'ı olduğun sabit silahta tetik çekilirken atış engellensin mi? true = engelle (TAC_fnc_trtFireDo çalışır).
      MG       : besleme prosedürü yapılmamışsa (ayar açıksa) veya silah arızalıysa
      Güdümlü  : atış hazırlığı yapılmamışsa; pil / soğutma koşulu (TAC_fnc_rktGuidedCheck); ve ateşlenmeme zarı
                 (roketatarla aynı model: taban x ölçek x (1 + soğuk + 0.5 x ıslaklık + nem...), mühimmat başına bir kez)
    Hazırlık / arıza engellerinde yalnızca tık sesi (bekleme sayacı yok); ateşlenmemede bekleme başlar.

    Parametreler (ACE koşulu): [hedef, birim]
    Dönüş: BOOL
*/

params ["", "_unit"];

if (!TAC_trt_enabled) exitWith {false};

private _veh = vehicle _unit;

if (_veh isEqualTo _unit || {!(_veh isKindOf "StaticWeapon")} || {!(_unit isEqualTo (gunner _veh))}) exitWith {false};

private _weapon = _veh currentWeaponTurret [0];
private _kind = [_weapon] call TAC_fnc_trtKind;

if (_kind isEqualTo "other" || {(_veh ammo _weapon) < 1}) exitWith {false};

private _state = [_veh, _weapon] call TAC_fnc_trtState;

missionNamespace setVariable ["TAC_trt_blockPrep", false];

// --- MG ----------------------------------------------------------------------
if (_kind isEqualTo "mg") exitWith {
    private _block = (TAC_mg_feedStep && {!(_state select 5)}) || {_state select 14};

    if (_block) then {missionNamespace setVariable ["TAC_trt_blockPrep", true]};

    _block
};

// --- Guduml ------------------------------------------------------------------
if (TAC_rkt_prepare && {!(_state select 5)}) exitWith {
    missionNamespace setVariable ["TAC_trt_blockPrep", true];
    true
};

if (TAC_rkt_guided) then {
    private _reason = [_state] call TAC_fnc_rktGuidedCheck;

    [_veh, _weapon, _state] call TAC_fnc_trtState;

    if !(_reason isEqualTo "") exitWith {
        missionNamespace setVariable ["TAC_trt_blockPrep", true];
    };
};

if (missionNamespace getVariable ["TAC_trt_blockPrep", false]) exitWith {true};

if !(_state select 1) then {
    private _profile = [_weapon] call TAC_fnc_rktProfile;
    private _coldF = (((5 - ((ambientTemperature) select 0)) / 30) max 0) min 1;
    private _pos = getPosATL _veh;
    private _wetF = if (surfaceIsWater _pos && {(_pos select 2) < 0.4}) then {1} else {rain min 1};
    private _p = ((_profile select 1) * TAC_rkt_scale * (1 + _coldF + (0.5 * _wetF))) min 0.5;

    if (TAC_rkt_testChance > 0) then {_p = _p max (TAC_rkt_testChance / 100)};

    _state set [1, true];
    _state set [2, random 1 < _p];
    [_veh, _weapon, _state] call TAC_fnc_trtState;
};

_state select 2
