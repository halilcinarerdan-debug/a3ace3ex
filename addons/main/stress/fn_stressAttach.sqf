/*
    Fonksiyon: TAC_fnc_stressAttach
    Çalışma yeri: İstemci

    Oyuncu birimine vanilla "Suppressed" olayını bağlar (yakından mermi geçince tetiklenir,
    mermiye en yakın mesafeyi verir), eskisinden kaldırır. Olay CBA yerel olayı
    "TAC_suppressed" olarak dağıtılır. Yalnızca oyuncuya bağlı: yapay zekâ için maliyet yok.

    Parametreler:
        0: OBJECT - yeni birim
        1: OBJECT - eski birim (olmayabilir)

    Dönüş: yok
*/

params [["_newUnit", objNull, [objNull]], ["_oldUnit", objNull, [objNull]]];

if (!isNull _oldUnit) then {
    private _id = _oldUnit getVariable ["TAC_stress_ehSuppressed", -1];

    if (_id >= 0) then {_oldUnit removeEventHandler ["Suppressed", _id]};
    _oldUnit setVariable ["TAC_stress_ehSuppressed", -1];
};

if (isNull _newUnit || {(_newUnit getVariable ["TAC_stress_ehSuppressed", -1]) >= 0}) exitWith {};

// Suppressed: [unit, distance, shooter, instigator, ammoObject, ammoClassName, ammoConfig]
private _id = _newUnit addEventHandler ["Suppressed", {
    params ["_unit", "_distance", "_shooter", "", "", "_ammoClass"];

    ["TAC_suppressed", [_unit, _distance, _shooter, _ammoClass]] call CBA_fnc_localEvent;
}];

_newUnit setVariable ["TAC_stress_ehSuppressed", _id];
