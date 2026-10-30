/*
    initPlayerLocal.sqf
    Her oyuncunun KENDİ makinesinde, oyuncu objesi hazır olunca bir kez çalışır (JIP dahil).
    Sunucuda / headless client'ta çalışmaz.
*/

params ["_player", "_didJIP"];

// ----------------------------------------------------------------------------
// 1. Taktiksel Not Defteri
// ----------------------------------------------------------------------------

// CBA yerel olayı: not kaydedilince geri bildirim göster.
// Depolama mantığı (StoreNote) ile arayüz birbirinden ayrık; başka modüller de
// "TAC_notebook_noteAdded" olayını dinleyebilir.
["TAC_notebook_noteAdded", {
    params ["_unit", "_entry", "_count"];

    if (!TAC_notebook_notify) exitWith {};

    [format [
        "Not kaydedildi [%1/%2]  %3",
        _count,
        round TAC_notebook_maxEntries,
        [_entry] call TAC_fnc_notebookFormatEntry
    ]] call ace_common_fnc_displayTextStructured;
}] call CBA_fnc_addEventHandler;

// ACE self-interaction eylemlerini bu oyuncuya ekle.
[_player] call TAC_fnc_notebookInit;
