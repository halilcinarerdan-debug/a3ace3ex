/*
    Fonksiyon: TAC_fnc_rktPrepDone
    Çalışma yeri: İstemci

    Hazırlık prosedürünün son adımı doğru sırayla bitince çağrılır: hazır işaretini açar. Güdümlü fırlatıcıda
    (pil ve soğutma açıksa) ayrıca sistemi açar: pil sayılmaya başlar, arayıcı soğumaya girer (sıcak havada
    daha yavaş). Pil boşsa sistem açılmaz (kısa mesaj).

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: STRING - fırlatıcı classname

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_weapon", "", [""]]];

if !(_weapon isEqualTo (secondaryWeapon _unit)) exitWith {};

private _state = [_unit, _weapon] call TAC_fnc_rktGetState;
private _category = ([_weapon] call TAC_fnc_rktProfile) select 0;

if (TAC_rkt_guided && {_category isEqualTo "guided"}) then {
    if ((_state param [9, 100]) <= 0) exitWith {
        ["Pil boş: sistem açılmadı. Yedek pille 'Pili değiştir'."] call ace_common_fnc_displayTextStructured;
    };

    private _hot = ((((ambientTemperature select 0) - 25) / 20) max 0) min 1;

    _state set [7, time];
    _state set [8, time + (TAC_rkt_cooldown * (1 + (0.5 * _hot)))];
};

_state set [5, true];
_state set [10, 0];
[_unit, _weapon] call TAC_fnc_rktPublish;
