/*
    Fonksiyon: TAC_fnc_wpnOnFired
    Çalışma yeri: İstemci (oyuncunun "Fired" olayı)

    Her kurşun atışında:
      1. Silah kategorisi (tüfek / MG / tabanca) takip ediliyor mu? Bomba, roket, fırlatıcı: atla.
      2. Kir artar:  oran/1000 x kategori çarpanı x ortam x susturucu (x yağ aşırıysa tozda 1.3)
         Yağ azalır: oran/1000.  Aşınma: +1 atış.  (Test modunda hepsi test çarpanıyla hızlanır.)
      2b. Kapalı lensli optik takılıysa lens kiri de artar (TAC_fnc_optGetState).
      3. Arıza ihtimali (TAC_fnc_wpnJamChance) ile zar atılır. Arıza çıkarsa tür, nedene göre
         ağırlıklandırılır (kir -> besleme/çıkarma, düşük yağ ve aşınma -> kovan çıkarma, ufak sabit
         pay -> kusurlu mühimmat) ve ACE'nin arıza sistemine verilir. Silah, ACE'nin kendi
         "arıza gider" eylemiyle (şansa bağlı) ya da bizim ayrıntılı müdahalemizle düzelir.
    Atış başına maliyet: bir hashmap araması, birkaç toplama, bir random. Döngü yok.

    Oyuncuya hiçbir bildirim verilmez (test göstergesi kapalıyken).

    Parametreler: Fired olayı: [unit, weapon, muzzle, mode, ammo, magazine, projectile, gunner]
    Dönüş: yok
*/

params ["_unit", "_weapon", "", "", "_ammo"];

if (!TAC_wpn_enabled || {!(_ammo isKindOf "BulletBase")}) exitWith {};

private _cat = [_weapon] call TAC_fnc_wpnCategory;
if (_cat isEqualTo []) exitWith {};

_cat params ["_catName", "_dirtMult", "", "_isMG"];

private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;
private _env = [_unit] call TAC_fnc_wpnEnvFactor;
private _accel = if (TAC_wpn_testMode) then {TAC_wpn_testMult} else {1};

_state params ["_dirt", "_lube", "_wear", "_since"];

// Susturucu: gaz geri tepmesi kirlenmeyi artirir
private _optic = "";
private _suppressor = switch (_weapon) do {
    case (primaryWeapon _unit): {
        private _items = primaryWeaponItems _unit;
        _optic = _items select 2;
        _items select 0
    };
    case (handgunWeapon _unit): {(handgunItems _unit) select 0};
    default {""};
};
private _suppMult = if (_suppressor isEqualTo "") then {1} else {TAC_wpn_suppressorMult};

// Toz/camurda asiri yagli silah tozu cekmeye daha yatkin
private _dustMult = if (_lube > 90 && {_env > 1.3}) then {1.3} else {1};

_dirt = (_dirt + ((TAC_wpn_dirtRate / 1000) * _dirtMult * _env * _suppMult * _dustMult * _accel)) min 100;
_lube = (_lube - ((TAC_wpn_lubeLoss / 1000) * _accel)) max 0;
_wear = _wear + _accel;
_since = _since + 1;

_state set [0, _dirt];
_state set [1, _lube];
_state set [2, _wear];
_state set [3, _since];

// Kapali lensli optikte atisla lens kirlenir (ortam carpani yagmur/toz icin aynidir).
if (TAC_opt_enabled && {!(_optic isEqualTo "")} && {[_optic] call TAC_fnc_optIsSealed}) then {
    private _optState = [_unit, _weapon] call TAC_fnc_optGetState;

    _optState set [1, ((_optState select 1) + (TAC_opt_shotDirt * _env * _accel)) min 100];
};

// --- Ariza ------------------------------------------------------------------
if (isNil "ace_overheating_fnc_jamWeapon") exitWith {};

// MG: besleme kapagi adimi atlandiysa ilk atista besleme arizasi (bir kez).
if (TAC_mg_feedStep && {[_weapon] call TAC_fnc_wpnIsBeltFed} && {!(_state param [7, true])}) exitWith {
    _state set [7, true];
    [_unit, _weapon] call TAC_fnc_wpnPublish;

    if !(_weapon in (_unit getVariable ["ace_overheating_jammedWeapons", []])) then {
        missionNamespace setVariable ["TAC_wpn_ownJam", time];
        [_unit, _weapon, "feed"] call ace_overheating_fnc_jamWeapon;

        if (TAC_wpn_debug) then {systemChat "[TAC silah] ARIZA feed | besleme kapagi adimi atlandi"};
    };
};

private _p = [_state, _env, _weapon] call TAC_fnc_wpnJamChance;

if (random 1 >= _p) exitWith {};
if (_weapon in (_unit getVariable ["ace_overheating_jammedWeapons", []])) exitWith {};

private _dirtF = _dirt / 100;
private _wearF = (_wear / (TAC_wpn_wearLife max 1)) min 1;
private _lubeF = ((30 - _lube) max 0) / 30;

private _type = selectRandomWeighted [
    "eject", 1 + (_dirtF * 2),
    "extract", 1 + (_wearF * 4) + (_lubeF * 2),
    "feed", 1 + (_dirtF * 2) + ([0, 1] select _isMG),
    "fire", 0.7 + _lubeF,
    "dud", 0.3
];

missionNamespace setVariable ["TAC_wpn_ownJam", time];
[_unit, _weapon, _type] call ace_overheating_fnc_jamWeapon;

if (TAC_wpn_debug) then {
    systemChat format [
        "[TAC silah] ARIZA %1 | %2 (%3) | kir %4 | yag %5 | asinma %6 | ihtimal %7 | ortam x%8",
        _type,
        _weapon,
        _catName,
        round _dirt,
        round _lube,
        round _wear,
        (round (_p * 10000)) / 100,
        (round (_env * 100)) / 100
    ];
};
