/*
    Fonksiyon: TAC_fnc_wpnLube
    Çalışma yeri: İstemci

    "Silahı yağla": 6 sn x ayar çarpanı. Bitince yağ +65 (en çok 100). 90 üstü "aşırı yağlı":
    tozlu ortamda daha çok kirlenir. Her seferinde bir "Silah Yağı" tükenir ("Bakım malzemesi
    gerekli" açıksa). Çubuk bitiminde yağ envanterden çıkarılamazsa işlem yapılmaz.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = [_unit] call TAC_fnc_wpnTargetWeapon;
if (_weapon isEqualTo "") exitWith {};

[_unit, "Silah yağlanıyor...", 6 * TAC_wpn_cleanTimeMult, {
    params ["_unit", "_args"];
    _args params ["_weapon"];

    if !([_unit, "TAC_WeaponOil"] call TAC_fnc_wpnConsume) exitWith {
        ["Silah yağı kalmadı."] call ace_common_fnc_displayTextStructured;
    };

    private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;

    _state set [1, ((_state select 1) + 65) min 100];

    [format ["%1 yağlandı.", getText (configFile >> "CfgWeapons" >> _weapon >> "displayName")]] call ace_common_fnc_displayTextStructured;
}, [_weapon]] call TAC_fnc_wpnRun;
