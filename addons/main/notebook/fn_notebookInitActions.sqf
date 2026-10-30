/*
    Fonksiyon: TAC_fnc_notebookInitActions
    Çalışma yeri: İstemci (postInit)

    ACE self-interaction menüsüne, "Not defteri modu" ayarına göre şunlardan biri görünür:

      BASİT (0)                          GELİŞMİŞ (1)
        Taktiksel Not Defteri              Not Defteri   (tek tık -> Notepad benzeri editör)
            ├─ Not Al
            └─ Notları Oku

    Eylemler tek bir kez, SINIFA (CAManBase, kalıtımla tüm askerler) eklenir. Self-interaction
    menüsü yalnızca oyuncunun kontrol ettiği birim için açıldığından respawn / JIP / selectPlayer
    sonrası eylemleri yeniden eklemeye gerek yoktur.

    Parametreler: yok
    Dönüş: yok
*/

// ----------------------------------------------------------------------------
// BASİT MOD
// ----------------------------------------------------------------------------

// Kök eylem. Koşul kodu ACE menüsü açıkken her karede çalışır -> sadece ucuz kontroller.
private _rootAction = [
    "TAC_notebook",
    "Taktiksel Not Defteri",
    "\a3\ui_f\data\igui\cfg\simpletasks\types\intel_ca.paa",
    {},
    {
        params ["_target", "_player"];
        TAC_notebook_mode == 0 && {[_player] call TAC_fnc_notebookCanUse}
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

// ----------------------------------------------------------------------------
// GELİŞMİŞ MOD: serbest yazı editörü
// ----------------------------------------------------------------------------

// ACE menüsü seçim anında kendi diyaloğunu kapatır; yeni diyalog bir sonraki karede açılsın.
private _padAction = [
    "TAC_notebook_pad",
    "Not Defteri",
    "\a3\ui_f\data\igui\cfg\simpletasks\types\documents_ca.paa",
    {
        [{call TAC_fnc_notebookOpenPad}] call CBA_fnc_execNextFrame;
    },
    {
        params ["_target", "_player"];
        TAC_notebook_mode == 1 && {[_player] call TAC_fnc_notebookCanUse}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions"], _padAction, true] call ace_interact_menu_fnc_addActionToClass;
