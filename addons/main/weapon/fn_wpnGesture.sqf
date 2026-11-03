/*
    Fonksiyon: TAC_fnc_wpnGesture
    Çalışma yeri: İstemci

    Bakım süresince silahla uğraşma hareketi: silahın kendi yükleme hareketi (ACE'nin arıza
    giderirken kullandığıyla aynı: önce config "ACE_clearJamAction", yoksa "reloadAction") bir üst
    gövde jesti olarak oynatılır ve süre bitene kadar 2.8 sn'de bir tekrarlanır. Duruş değişmez,
    animasyon durumu geri yüklemek gerekmez. Bakım bitince ya da iptal edilince (meşgul işareti
    sıfırlanır) döngü kendiliğinden durur. Eldeki silah hedef silah değilse oynatılmaz.

    Parametreler:
        0: OBJECT - birim
        1: STRING - silah classname

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_weapon", "", [""]]];

if (
    !TAC_wpn_fx
    || {!alive _unit}
    || {time >= (_unit getVariable ["TAC_wpn_busyUntil", 0])}
    || {!((currentWeapon _unit) isEqualTo _weapon)}
) exitWith {};

private _cfg = configFile >> "CfgWeapons" >> _weapon;
private _action = getText (_cfg >> "ACE_clearJamAction");

if (_action isEqualTo "") then {_action = getText (_cfg >> "reloadAction")};
if (_action isEqualTo "") exitWith {};

[_unit, _action, 1] call ace_common_fnc_doGesture;

[TAC_fnc_wpnGesture, [_unit, _weapon], 2.8] call CBA_fnc_waitAndExecute;
