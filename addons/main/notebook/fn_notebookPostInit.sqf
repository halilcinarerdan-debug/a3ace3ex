/*
    Fonksiyon: TAC_fnc_notebookPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    Not Defteri modülünün istemci tarafı kurulumu:
      1. ACE eylemlerini sınıfa ekler.
      2. CBA yerel olayı "TAC_notebook_noteAdded" için bildirim dinleyicisi kurar.
         Depolama (StoreNote) ile arayüz birbirinden ayrık; başka modüller de bu olayı dinleyebilir.
      3. CBA oyuncu olayı "unit" ile respawn'ı yakalar ("Ölünce notlar silinsin" ayarı).

    Parametreler: yok
    Dönüş: yok
*/

call TAC_fnc_notebookInitActions;

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

// "unit": oyuncunun kontrol ettiği birim değişince çalışır (respawn dahil).
// Eski birim ölüyse bu bir respawn'dır. İlk spawn'da _oldUnit objNull olduğundan dokunulmaz.
["unit", {
    params ["_newUnit", "_oldUnit"];

    // Gelişmiş modda editör açık kalmış olabilir: yazılan metin zaten kayıtlı, pencereyi kapat.
    private _pad = findDisplay 91700;
    if (!isNull _pad) then {
        [_pad] call TAC_fnc_notebookPadSave;
        _pad closeDisplay 2;
    };

    if (TAC_notebook_clearOnDeath && {!isNull _oldUnit} && {!alive _oldUnit}) then {
        missionNamespace setVariable ["TAC_notebook_entries", []];
        missionNamespace setVariable ["TAC_notebook_text", ""];
    };
}] call CBA_fnc_addPlayerEventHandler;
