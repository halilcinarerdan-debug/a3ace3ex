/*
    Fonksiyon: TAC_fnc_wpnFeedApply
    Çalışma yeri: İstemci (durumun sahibi; kendi adımı bitince VEYA arkadaşının yardım adımı gelince)

    Bir MG besleme adımının sonucunu uygular: doğru sıradaysa ilerleme +1, son adımda besleme hazır olur;
    yanlış sıradaysa ilerleme sıfırlanır (kısa mesaj). Sonuç herkese yayınlanır.

    Parametreler:
        0: OBJECT - MG'nin sahibi (yerel birim)
        1: NUMBER - adımın prosedürdeki sıra numarası

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_index", 0, [0]]];

if (!local _unit) exitWith {};

private _weapon = currentWeapon _unit;
if !([_weapon] call TAC_fnc_wpnIsBeltFed) exitWith {};

private _count = count ([_weapon] call TAC_fnc_wpnFeedSteps);
private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;
private _progress = _state param [8, 0];

if (_state param [7, true]) exitWith {};

if (_index != _progress) exitWith {
    _state set [8, 0];
    [_unit, _weapon] call TAC_fnc_wpnPublish;

    if (_unit isEqualTo ACE_player) then {
        ["Hatalı sıra: prosedür baştan başlamalı."] call ace_common_fnc_displayTextStructured;
    };
};

if ((_progress + 1) >= _count) then {
    _state set [7, true];
    _state set [8, 0];
} else {
    _state set [8, _progress + 1];
};

[_unit, _weapon] call TAC_fnc_wpnPublish;
