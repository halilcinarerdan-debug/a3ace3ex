/*
    Fonksiyon: TAC_fnc_rktBattery
    Çalışma yeri: İstemci

    "Pili değiştir": güdümlü fırlatıcıya yedek "Güdümlü Füze Pili" (TAC_MissileBattery) takar, 5 sn x bakım
    süresi çarpanı. Envanterden bir pil düşer ("Bakım malzemesi gerekli" açıksa), pil %100 olur. Sistem açıksa
    geçen süre için önce eski pil düşülür, sonra yeni pil o andan itibaren sayılır.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = secondaryWeapon _unit;
if (_weapon isEqualTo "") exitWith {};

[_unit, "Füze pili değiştiriliyor...", 5 * TAC_wpn_cleanTimeMult, {
    params ["_unit", "_args"];
    _args params ["_weapon"];

    if !(_weapon isEqualTo (secondaryWeapon _unit)) exitWith {};

    if !([_unit, "TAC_MissileBattery"] call TAC_fnc_wpnConsume) exitWith {
        ["Yedek pil kalmadı."] call ace_common_fnc_displayTextStructured;
    };

    private _state = [_unit, _weapon] call TAC_fnc_rktGetState;
    private _wasOn = (_state param [7, -1]) >= 0;

    [_state] call TAC_fnc_rktPowerOff;
    _state set [9, 100];

    if (_wasOn) then {_state set [7, time]};

    ["Pil değiştirildi."] call ace_common_fnc_displayTextStructured;
}, [_weapon], "rocket"] call TAC_fnc_wpnRun;
