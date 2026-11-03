/*
    Fonksiyon: TAC_fnc_wpnClearJam
    Çalışma yeri: İstemci

    "Arızayı gider (ayrıntılı)": ACE'nin hızlı müdahalesi (tap-rack, şansa bağlı) başarısız olursa
    ikinci kademe. Silah sökülüp tıkanma giderilir: süre = temizlik süresinin %40'ı x çarpan,
    başarı garantili, ayrıca kir 8 puan azalır.

    ACE'nin arıza durumunu kendisi temizler (ace_overheating_fnc_clearJam şansa bağlı olduğu için
    doğrudan çağrılamaz): birimdeki "jammedWeapons" listesinden silah çıkarılır, arıza türü sıfırlanır,
    liste boşsa "DefaultAction" engelleyicisi kaldırılır. (ACE overheating kaynağıyla birebir.)

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

private _weapon = currentWeapon _unit;
private _cat = [_weapon] call TAC_fnc_wpnCategory;

if (_cat isEqualTo [] || {!(_weapon in (_unit getVariable ["ace_overheating_jammedWeapons", []]))}) exitWith {};

[_unit, "Arıza giderilmeye çalışılıyor...", (_cat select 2) * 0.4 * TAC_wpn_cleanTimeMult, {
    params ["_unit", "_args"];
    _args params ["_weapon"];

    private _jammed = (_unit getVariable ["ace_overheating_jammedWeapons", []]) - [_weapon];

    _unit setVariable ["ace_overheating_jammedWeapons", _jammed];
    _unit setVariable [format ["ace_overheating_%1_jamType", _weapon], "None"];

    if (_jammed isEqualTo []) then {
        private _id = _unit getVariable ["ace_overheating_JammingActionID", -1];

        if (_id != -1) then {
            [_unit, "DefaultAction", _id] call ace_common_fnc_removeActionEventHandler;
        };

        _unit setVariable ["ace_overheating_JammingActionID", -1];
    };

    private _state = [_unit, _weapon] call TAC_fnc_wpnGetState;
    _state set [0, ((_state select 0) - 8) max 0];

    ["Arıza giderildi."] call ace_common_fnc_displayTextStructured;
}, [_weapon], "clearJam"] call TAC_fnc_wpnRun;
