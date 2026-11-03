/*
    Fonksiyon: TAC_fnc_wpnReplaceParts
    Çalışma yeri: İstemci

    "Parça değiştir" (yalnızca silahçı): kategori temizlik süresi x çarpan sürer, bir "Silah Yedek
    Parça Seti" tükenir ("Bakım malzemesi gerekli" açıksa). Bitince aşınma sıfırlanır.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = [_unit] call TAC_fnc_wpnTargetWeapon;
if (_weapon isEqualTo "" || {!([_unit] call TAC_fnc_wpnIsArmorer)}) exitWith {};

private _cat = [_weapon] call TAC_fnc_wpnCategory;

[_unit, "Parçalar değiştiriliyor...", (_cat select 2) * TAC_wpn_cleanTimeMult, {
    params ["_unit", "_args"];
    _args params ["_weapon"];

    if !([_unit, "TAC_WeaponSpareParts"] call TAC_fnc_wpnConsume) exitWith {
        ["Yedek parça seti kalmadı."] call ace_common_fnc_displayTextStructured;
    };

    private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;
    _state set [2, 0];

    [format ["%1: parçalar değiştirildi.", getText (configFile >> "CfgWeapons" >> _weapon >> "displayName")]] call ace_common_fnc_displayTextStructured;
}, [_weapon]] call TAC_fnc_wpnRun;
