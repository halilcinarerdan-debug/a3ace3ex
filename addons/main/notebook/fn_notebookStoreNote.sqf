/*
    Fonksiyon: TAC_fnc_notebookStoreNote
    Çalışma yeri: İstemci

    Kaydı oyuncunun YEREL not listesine ekler. Liste missionNamespace'te tutulur ve
    asla publicVariable / setVariable [..., true] ile yayınlanmaz -> sunucuya yük yok,
    notlar kişiye özel. Oyuncu respawn olsa da (ayar izin verirse) liste korunur;
    bağlantı kopunca sıfırlanır.

    Ardından CBA yerel olayını tetikler: "TAC_notebook_noteAdded"

    Parametreler:
        0: OBJECT - notu alan oyuncu
        1: ARRAY  - kayıt [date, posASL, dir]

    Dönüş: yok
*/

params ["_unit", "_entry"];

private _entries = missionNamespace getVariable ["TAC_notebook_entries", []];
_entries pushBack _entry;

// Sınırı aşarsa en eskileri at (FIFO).
private _max = round TAC_notebook_maxEntries;
if (count _entries > _max) then {
    _entries = _entries select [count _entries - _max, _max];
};

missionNamespace setVariable ["TAC_notebook_entries", _entries];

["TAC_notebook_noteAdded", [_unit, _entry, count _entries]] call CBA_fnc_localEvent;
