/*
    Fonksiyon: TAC_fnc_notebookInit
    Çalışma yeri: İstemci (yalnızca LOCAL oyuncu)

    Oyuncuya ACE self-interaction menüsüne şu ağacı ekler:
        Taktiksel Not Defteri
            ├─ Not Al
            └─ Notları Oku

    Tekrar çağrılması güvenlidir (unit üzerindeki bayrak ile korunur): hem
    initPlayerLocal.sqf hem onPlayerRespawn.sqf çağırabilir.

    Parametreler:
        0: OBJECT - eylemlerin ekleneceği oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};

if (isNil "ace_interact_menu_fnc_createAction") exitWith {
    diag_log "[TAC] HATA: ACE3 interaction menüsü bulunamadı.";
};

// ACE eylemleri OBJEYE bağlıdır; respawn'da yeni obje gelir. Aynı obje için çift ekleme yapma.
if (_unit getVariable ["TAC_notebook_actionsAdded", false]) exitWith {};
_unit setVariable ["TAC_notebook_actionsAdded", true];

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

[_unit, 1, ["ACE_SelfActions"], _rootAction] call ace_interact_menu_fnc_addActionToObject;

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

[_unit, 1, ["ACE_SelfActions", "TAC_notebook"], _addAction] call ace_interact_menu_fnc_addActionToObject;

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

[_unit, 1, ["ACE_SelfActions", "TAC_notebook"], _readAction] call ace_interact_menu_fnc_addActionToObject;
