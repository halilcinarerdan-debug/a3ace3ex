/*
    Fonksiyon: TAC_fnc_assistStep
    Çalışma yeri: İstemci (YARDIMCI)

    Arkadaşın silahında bir hazırlık adımını yapar. Çubuk yardımcıda yürür (süre x bakım süresi çarpanı x
    yardım çarpanı). Bitince, yardımcı hâlâ yakındaysa (4 m) ve arkadaş yaşıyorsa adım "TAC_assistStep" olayıyla
    arkadaşın makinesine gönderilir; sıra doğrulaması ve sonuç orada uygulanır (yanlış sıra prosedürü sıfırlar).

    Parametreler:
        0: OBJECT - yardımcı
        1: OBJECT - arkadaş (silahın sahibi)
        2: STRING - "feed" veya "rocket"
        3: NUMBER - adımın prosedürdeki sıra numarası

    Dönüş: yok
*/

params [["_helper", objNull, [objNull]], ["_target", objNull, [objNull]], ["_kind", "", [""]], ["_index", 0, [0]]];

if (isNull _helper || {isNull _target} || {(_helper distance _target) > 4}) exitWith {};

private _weapon = "";
private _steps = [];

if (_kind isEqualTo "feed") then {
    _weapon = currentWeapon _target;
    _steps = [_weapon] call TAC_fnc_wpnFeedSteps;
} else {
    _weapon = secondaryWeapon _target;
    private _mags = secondaryWeaponMagazine _target;
    _steps = [_weapon, if (_mags isEqualTo []) then {""} else {_mags select 0}] call TAC_fnc_rktPrepSteps;
};

if (_weapon isEqualTo "" || {_index < 0} || {_index >= count _steps}) exitWith {};

(_steps select _index) params ["_label", "_seconds"];

[_helper, _label + " (yardım)...", _seconds * TAC_wpn_cleanTimeMult * TAC_assist_speed, {
    params ["_helper", "_args"];
    _args params ["_target", "_kind", "_index"];

    if (isNull _target || {!alive _target} || {(_helper distance _target) > 4}) exitWith {};

    ["TAC_assistStep", [_target, _kind, _index], _target] call CBA_fnc_targetEvent;
}, [_kind, _target, _kind, _index], [ "rocket", "feed" ] select (_kind isEqualTo "feed")] call TAC_fnc_wpnRun;
