/*
    Fonksiyon: TAC_fnc_trtDo
    Çalışma yeri: İstemci (eylemi yapan kişi)

    Sabit silah bakım / yardım eylemleri (ilerleme çubuğu + hareket + ses, TAC_fnc_wpnRun):
      "clean"    : temizle (MG, 45 sn x çarpan): kir %5, yağ en fazla %12 (bakım kiti)
      "lube"     : yağla (6 sn): yağ +65 (1 silah yağı tükenir)
      "clearjam" : arızayı gider (MG, 18 sn): tutukluk açılır, kir -8
      "battery"  : pili değiştir (güdümlü, 5 sn): yedek pil, pil %100 (1 pil tükenir)
      "remove"   : ateşlenmeyen mühimmatı çıkar (güdümlü, 8 sn): tüp boşaltılır (araç sahibine olayla)

    Parametreler:
        0: OBJECT - eylemi yapan oyuncu
        1: OBJECT - sabit silah (araç)
        2: STRING - eylem

    Dönüş: yok
*/

params [["_player", objNull, [objNull]], ["_veh", objNull, [objNull]], ["_action", "", [""]]];

private _weapon = ((_veh weaponsTurret [0])) param [0, ""];

if (_weapon isEqualTo "") exitWith {};

private _info = switch (_action) do {
    case "clean": {["Silah temizleniyor...", 45]};
    case "lube": {["Silah yağlanıyor...", 6]};
    case "clearjam": {["Arıza giderilmeye çalışılıyor...", 18]};
    case "battery": {["Füze pili değiştiriliyor...", 5]};
    case "remove": {["Ateşlenmeyen mühimmat çıkarılıyor...", 8]};
    default {[]};
};

if (_info isEqualTo []) exitWith {};

[_player, _info select 0, (_info select 1) * TAC_wpn_cleanTimeMult, {
    params ["_player", "_args"];
    _args params ["_weapon", "_veh", "_action"];

    if (isNull _veh || {!alive _veh}) exitWith {};

    private _state = [_veh, _weapon] call TAC_fnc_trtState;

    switch (_action) do {
        case "clean": {
            _state set [11, (_state select 11) min 5];
            _state set [12, (_state select 12) min 12];
        };
        case "lube": {
            if !([_player, "TAC_WeaponOil"] call TAC_fnc_wpnConsume) exitWith {};
            _state set [12, ((_state select 12) + 65) min 100];
        };
        case "clearjam": {
            _state set [14, false];
            _state set [11, ((_state select 11) - 8) max 0];
        };
        case "battery": {
            if !([_player, "TAC_MissileBattery"] call TAC_fnc_wpnConsume) exitWith {};

            private _wasOn = (_state select 7) >= 0;

            [_state] call TAC_fnc_rktPowerOff;
            _state set [9, 100];

            if (_wasOn) then {_state set [7, time]};
        };
        case "remove": {
            [_state] call TAC_fnc_rktPowerOff;
            _state set [1, false];
            _state set [2, false];
            _state set [3, 0];
            _state set [5, false];
            _state set [10, 0];

            ["TAC_trtSetAmmo", [_veh, _weapon], _veh] call CBA_fnc_targetEvent;
        };
    };

    [_veh, _weapon, _state] call TAC_fnc_trtState;
}, [_weapon, _veh, _action], ["rocket", "feed"] select (_action in ["clean", "lube", "clearjam"])] call TAC_fnc_wpnRun;
