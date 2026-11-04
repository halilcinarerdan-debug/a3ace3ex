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
if (_weapon isEqualTo "" || {(_unit ammo _weapon) < 1}) exitWith {};

private _mags = secondaryWeaponMagazine _unit;
private _magazine = if (_mags isEqualTo []) then {currentMagazine _unit} else {_mags select 0};
private _steps = [_weapon, _magazine] call TAC_fnc_rktPrepSteps;

if (_index < 0 || {_index >= count _steps}) exitWith {};

(_steps select _index) params ["_label", "_seconds"];

[_unit, _label + "...", _seconds * TAC_wpn_cleanTimeMult, {
    params ["_unit", "_args"];
    _args params ["_weapon", "_index", "_count"];

    if !(_weapon isEqualTo (secondaryWeapon _unit)) exitWith {};

    private _state = [_unit, _weapon] call TAC_fnc_rktGetState;
    private _progress = _state param [10, 0];

    if (_index != _progress) exitWith {
        _state set [10, 0];
        ["Hatalı sıra: prosedür baştan başlamalı."] call ace_common_fnc_displayTextStructured;
    };

    if ((_progress + 1) >= _count) then {
        [_unit, _weapon] call TAC_fnc_rktPrepDone;
    } else {
        _state set [10, _progress + 1];
    };
}, [_weapon, _index, count _steps], "rocket"] call TAC_fnc_wpnRun;
