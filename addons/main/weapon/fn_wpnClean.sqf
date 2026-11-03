/*
    Fonksiyon: TAC_fnc_wpnClean
    Çalışma yeri: İstemci

    "Silahı temizle": ilerleme çubuğu (kategori süresi x ayar çarpanı: tüfek 25 sn, MG 45 sn,
    tabanca 15 sn). Bitince kir %5'e iner, son temizlikten atış sayacı sıfırlanır ve temizlik
    yağı da alır: yağ en fazla %12 kalır (temizledikten sonra yağlamak gerekir).
    Silah Bakım Kiti gerekir ("Bakım malzemesi gerekli" açıksa; kit tükenmez).

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = [_unit] call TAC_fnc_wpnTargetWeapon;
if (_weapon isEqualTo "") exitWith {};

private _cat = [_weapon] call TAC_fnc_wpnCategory;
private _time = (_cat select 2) * TAC_wpn_cleanTimeMult;

[_unit, "Silah temizleniyor...", _time, {
    params ["_unit", "_args"];
    _args params ["_weapon"];

    private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;

    _state set [0, (_state select 0) min 5];
    _state set [1, (_state select 1) min 12];
    _state set [3, 0];

    [format ["%1 temizlendi.", getText (configFile >> "CfgWeapons" >> _weapon >> "displayName")]] call ace_common_fnc_displayTextStructured;
}, [_weapon]] call TAC_fnc_wpnRun;
