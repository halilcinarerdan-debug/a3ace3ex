/*
    Fonksiyon: TAC_fnc_notebookOnRespawn
    Çalışma yeri: İstemci

    onPlayerRespawn.sqf'ten çağrılır.
      - "Ölünce notlar silinsin" açıksa yerel not listesini boşaltır.
        (Mission başındaki ilk tetiklemede liste zaten boştur, zararı yok.)
      - Yeni bedene ACE eylemlerini ekler.

    Parametreler:
        0: OBJECT - yeni birim
        1: OBJECT - eski birim (mission başında objNull)

    Dönüş: yok
*/

params ["_newUnit", "_oldUnit"];

if (TAC_notebook_clearOnDeath) then {
    missionNamespace setVariable ["TAC_notebook_entries", []];
};

[_newUnit] call TAC_fnc_notebookInit;
