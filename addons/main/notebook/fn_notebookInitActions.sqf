/*
    Fonksiyon: TAC_fnc_notebookInitActions
    Çalışma yeri: İstemci (postInit)

    ACE self-interaction menüsüne şu ağacı ekler:
        Taktiksel Not Defteri
            ├─ Not Al
            └─ Notları Oku

    Eylemler tek bir kez, SINIFA (CAManBase, kalıtımla tüm askerler) eklenir. Self-interaction
    menüsü yalnızca oyuncunun kontrol ettiği birim için açıldığından respawn / JIP / selectPlayer
    sonrası eylemleri yeniden eklemeye gerek yoktur.

    Parametreler: yok
    Dönüş: yok
*/

// Kök eylem: yalnızca gerekli eşya varken ve oyuncu ayaktayken görünür.
// Koşul kodu ACE menüsü açıkken her karede çalışır -> sadece ucuz kontroller.
private _rootAction = [
    "TAC_notebook",
    "Taktiksel Not Defteri",
    "\a3\ui_f\data\igui\cfg\simpletasks\types\intel_ca.paa",
    {},
    {
        params ["_target", "_player"];

        TAC_notebook_enabled
        && {alive _player}
        && {!(_player getVariable ["ACE_isUnconscious", false])}
        && {(TAC_notebook_itemClass in assignedItems _player) || {TAC_notebook_itemClass in items _player}}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions"], _rootAction, true] call ace_interact_menu_fnc_addActionToClass;

// Not Al: yazma sürerken tekrar basılmasın.
private _addAction = [
    "TAC_notebook_add",
    "Not Al",
    "\a3\ui_f\data\igui\cfg\simpletasks\types\documents_ca.paa",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_notebookAddNote;
    },
    {
        params ["_target", "_player"];
        !(_player getVariable ["TAC_notebook_writing", false])
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_notebook"], _addAction, true] call ace_interact_menu_fnc_addActionToClass;

// Notları Oku
private _readAction = [
    "TAC_notebook_read",
    "Notları Oku",
    "\a3\ui_f\data\igui\cfg\simpletasks\types\map_ca.paa",
    {
        call TAC_fnc_notebookShow;
    },
    {true}
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_notebook"], _readAction, true] call ace_interact_menu_fnc_addActionToClass;
