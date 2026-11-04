/*
    Fonksiyon: TAC_fnc_rktStepApply
    Çalışma yeri: İstemci (durumun sahibi; kendi adımı bitince VEYA arkadaşının yardım adımı gelince)

    Bir hazırlık adımının sonucunu uygular: adım sıradaki doğruysa ilerleme +1 ve son adımda hazırlık tamamlanır
    (TAC_fnc_rktPrepDone); değilse HATALI SIRA: ilerleme sıfırlanır (kısa mesaj). Sonuç herkese yayınlanır.
    Fırlatıcı / mühimmat değişmişse hiçbir şey yapmaz.

    Parametreler:
        0: OBJECT - fırlatıcının sahibi (yerel birim)
        1: NUMBER - adımın prosedürdeki sıra numarası

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_index", 0, [0]]];

if (!local _unit) exitWith {};

private _weapon = secondaryWeapon _unit;
if (_weapon isEqualTo "" || {(_unit ammo _weapon) < 1}) exitWith {};

private _mags = secondaryWeaponMagazine _unit;
private _magazine = if (_mags isEqualTo []) then {currentMagazine _unit} else {_mags select 0};
private _count = count ([_weapon, _magazine] call TAC_fnc_rktPrepSteps);

private _state = [_unit, _weapon] call TAC_fnc_rktGetState;
private _progress = _state param [10, 0];

if (_state select 5) exitWith {};

if (_index != _progress) exitWith {
    _state set [10, 0];
    [_unit, _weapon] call TAC_fnc_rktPublish;

    if (_unit isEqualTo ACE_player) then {
        ["Hatalı sıra: prosedür baştan başlamalı."] call ace_common_fnc_displayTextStructured;
    };
};

if ((_progress + 1) >= _count) then {
    [_unit, _weapon] call TAC_fnc_rktPrepDone;
} else {
    _state set [10, _progress + 1];
};

[_unit, _weapon] call TAC_fnc_rktPublish;
