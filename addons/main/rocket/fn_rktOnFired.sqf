/*
    Fonksiyon: TAC_fnc_rktOnFired
    Çalışma yeri: İstemci (oyuncunun "Fired" olayı)

    Fırlatıcıdan gerçekten bir atış çıktığında: atış sayacı +1, zar sıfırlanır (bir sonraki yüklü
    mühimmat için yeniden atılır). Yalnızca birincil olmayan ikincil silah (fırlatıcı) için.

    Parametreler: Fired olayı: [unit, weapon, ...]
    Dönüş: yok
*/

params ["_unit", "_weapon"];

if (!TAC_rkt_enabled || {!(_weapon isEqualTo (secondaryWeapon _unit))}) exitWith {};

private _state = [_unit, _weapon] call TAC_fnc_rktGetState;

_state set [0, (_state select 0) + 1];
_state set [1, false];
_state set [2, false];
_state set [3, 0];
_state set [5, false];
