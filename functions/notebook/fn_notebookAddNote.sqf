/*
    Fonksiyon: TAC_fnc_notebookAddNote
    Çalışma yeri: İstemci

    "Not Al" eyleminin gövdesi. Gözlem anının verisini (zaman, konum, yön) o an yakalar;
    ayarlardaki süre kadar ACE ilerleme çubuğu gösterir, bitince kaydeder.
    Süre 0 ise anında kaydeder.

    Parametreler:
        0: OBJECT - notu alan oyuncu

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {_unit getVariable ["TAC_notebook_writing", false]}) exitWith {};

// Kayıt = [oyun içi tarih [y,a,g,saat,dk], pozisyon ASL, yön]
// Veri yazmaya BAŞLARKEN yakalanır: not, gözlemin yapıldığı an/yere aittir.
private _snapshot = [date, getPosASL _unit, getDir _unit];

if (TAC_notebook_writeTime <= 0) exitWith {
    [_unit, _snapshot] call TAC_fnc_notebookStoreNote;
};

_unit setVariable ["TAC_notebook_writing", true];

[
    TAC_notebook_writeTime,
    [_unit, _snapshot],
    {
        params ["_args"];
        _args params ["_unit", "_snapshot"];

        _unit setVariable ["TAC_notebook_writing", false];
        [_unit, _snapshot] call TAC_fnc_notebookStoreNote;
    },
    {
        params ["_args"];
        (_args select 0) setVariable ["TAC_notebook_writing", false];
    },
    "Not alınıyor...",
    {
        params ["_args"];
        private _unit = _args select 0;

        alive _unit && {!(_unit getVariable ["ACE_isUnconscious", false])}
    },
    ["isNotInside"]
] call ace_common_fnc_progressBar;
