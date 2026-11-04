/*
    Fonksiyon: TAC_fnc_trtStep
    Çalışma yeri: İstemci (adımı yapan kişi: gunner ya da yardımcı)

    Sabit silahın hazırlık prosedüründe BİR adımı yapar (MG besleme: "feed", güdümlü atış hazırlığı: "rocket").
    Adımın çubuğu, hareketi ve sesi yapan kişide yürür. Bitince sıra doğrulanır (durum araçta herkese yayınlıdır):
    doğru adımsa ilerleme +1 ve son adımda hazır; yanlış sıradaysa sıfırlanır ("Hatalı sıra" mesajı).
    Güdümlü hazırlık bitince sistem açılır (pil sayılır, arayıcı soğur).

    Parametreler:
        0: OBJECT - adımı yapan oyuncu
        1: OBJECT - sabit silah (araç)
        2: STRING - "feed" veya "rocket"
        3: NUMBER - adımın prosedürdeki sıra numarası

    Dönüş: yok
*/

params [["_player", objNull, [objNull]], ["_veh", objNull, [objNull]], ["_kind", "", [""]], ["_index", 0, [0]]];

private _weapon = ((_veh weaponsTurret [0])) param [0, ""];
private _mag = (((_veh magazinesTurret [0])) param [0, ""]);
private _steps = if (_kind isEqualTo "feed") then {[_weapon, _veh] call TAC_fnc_trtFeedSteps} else {[_weapon, _mag] call TAC_fnc_rktPrepSteps};

if (_weapon isEqualTo "" || {_index < 0} || {_index >= count _steps}) exitWith {};

(_steps select _index) params ["_label", "_seconds"];

[_player, _label + "...", _seconds * TAC_wpn_cleanTimeMult, {
    params ["_player", "_args"];
    _args params ["_weapon", "_veh", "_index", "_count", "_kind"];

    if (isNull _veh || {!alive _veh}) exitWith {};

    private _state = [_veh, _weapon] call TAC_fnc_trtState;
    private _progress = _state select 10;

    if (_state select 5) exitWith {};

    if (_index != _progress) exitWith {
        _state set [10, 0];
        [_veh, _weapon, _state] call TAC_fnc_trtState;
        ["Hatalı sıra: prosedür baştan başlamalı."] call ace_common_fnc_displayTextStructured;
    };

    if ((_progress + 1) >= _count) then {
        if (_kind isEqualTo "rocket" && {TAC_rkt_guided} && {([_weapon, _veh] call TAC_fnc_trtKind) isEqualTo "guided"}) then {
            if ((_state select 9) > 0) then {
                private _hot = ((((ambientTemperature select 0) - 25) / 20) max 0) min 1;

                _state set [7, time];
                _state set [8, time + (TAC_rkt_cooldown * (1 + (0.5 * _hot)))];
            } else {
                ["Pil boş: sistem açılmadı. Yedek pille 'Pili değiştir'."] call ace_common_fnc_displayTextStructured;
            };
        };

        _state set [5, true];
        _state set [10, 0];
    } else {
        _state set [10, _progress + 1];
    };

    [_veh, _weapon, _state] call TAC_fnc_trtState;
}, [_weapon, _veh, _index, count _steps, _kind], [ "rocket", "feed" ] select (_kind isEqualTo "feed")] call TAC_fnc_wpnRun;
