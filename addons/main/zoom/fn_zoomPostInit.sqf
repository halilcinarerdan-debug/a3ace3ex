/*
    Fonksiyon: TAC_fnc_zoomPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    Silahsızken çıplak göz zoom'unu engeller: mission ekranına (display 46) iki dinleyici bağlar.
      - MouseButtonDown : sağ tık (button 1)
      - KeyDown         : "optics", "opticsTemp", "zoomTemp", "zoomIn", "zoomOut" eylemlerine bağlı tuşlar
    Dinleyici true dönerse motor girişi işlemez (varsayılan davranışı iptal eder).
    Döngü yok; dinleyiciler yalnızca tuş/fare basışında çalışır ve ilk iş TAC_fnc_zoomIsBlocked
    ile ucuz bir koşul kontrolü yapar.

    Silah nişanındaki zoom'un kaldırılması config tarafındadır (zoom/CfgWeapons.hpp).

    Parametreler: yok
    Dönüş: yok
*/

missionNamespace setVariable ["TAC_zoom_blocked", 0];

[{!isNull (findDisplay 46)}, {
    private _display = findDisplay 46;

    _display displayAddEventHandler ["MouseButtonDown", {
        params ["", "_button"];

        if (_button != 1 || {!([] call TAC_fnc_zoomIsBlocked)}) exitWith {false};

        TAC_zoom_blocked = TAC_zoom_blocked + 1;
        if (TAC_zoom_debug) then {systemChat format ["[TAC zoom] sag tik zoom engellendi (%1)", TAC_zoom_blocked]};

        true
    }];

    _display displayAddEventHandler ["KeyDown", {
        params ["", "_key"];

        if !([] call TAC_fnc_zoomIsBlocked) exitWith {false};

        private _zoomKey = false;
        {
            if (_key in (actionKeys _x)) exitWith {_zoomKey = true};
        } forEach ["optics", "opticsTemp", "zoomTemp", "zoomIn", "zoomOut"];

        if (!_zoomKey) exitWith {false};

        TAC_zoom_blocked = TAC_zoom_blocked + 1;
        if (TAC_zoom_debug) then {systemChat format ["[TAC zoom] zoom tusu engellendi (%1)", TAC_zoom_blocked]};

        true
    }];
}] call CBA_fnc_waitUntilAndExecute;

diag_log "[TAC][ZOOM] hazir";
