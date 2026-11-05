/*
    Fonksiyon: TAC_fnc_rktStep
    Çalışma yeri: İstemci

    Atış hazırlığı prosedüründe BİR adımı yapar. Adımlar silaha ve yüklü başlığa özeldir (TAC_fnc_rktPrepSteps)
    ve menüde alfabetik sırayla listelenir: DOĞRU SIRAYI oyuncu bilmelidir. Seçilen adım kendi ilerleme çubuğu,
    hareketi ve sesiyle yapılır. Bitince:
      - adım sıradaki doğru adımsa ilerleme +1; son adım da bitince hazırlık tamamlanır (TAC_fnc_rktPrepDone)
      - değilse HATALI SIRA: ilerleme sıfırlanır, prosedür baştan başlar (kısa mesaj)

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: NUMBER - adımın prosedürdeki sıra numarası (0'dan)

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_index", 0, [0]]];

private _weapon = secondaryWeapon _unit;
if (_weapon isEqualTo "" || {(_unit ammo _weapon) < 1} || {!((currentWeapon _unit) isEqualTo _weapon)}) exitWith {};

private _mags = secondaryWeaponMagazine _unit;
private _magazine = if (_mags isEqualTo []) then {currentMagazine _unit} else {_mags select 0};
private _steps = [_weapon, _magazine] call TAC_fnc_rktPrepSteps;

if (_index < 0 || {_index >= count _steps}) exitWith {};

(_steps select _index) params ["_label", "_seconds"];

[_unit, _label + "...", _seconds * TAC_wpn_cleanTimeMult, {
    params ["_unit", "_args"];
    _args params ["_weapon", "_index"];

    if !(_weapon isEqualTo (secondaryWeapon _unit)) exitWith {};

    [_unit, _index] call TAC_fnc_rktStepApply;
}, [_weapon, _index], "rocket"] call TAC_fnc_wpnRun;
