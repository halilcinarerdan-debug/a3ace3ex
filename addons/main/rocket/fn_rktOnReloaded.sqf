/*
    Fonksiyon: TAC_fnc_rktOnReloaded
    Çalışma yeri: İstemci (oyuncunun "Reloaded" olayı)

    Fırlatıcıya yeni mühimmat yüklendiğinde zar ve ateşlenmeme durumu sıfırlanır (yeni mermi, yeni zar).

    Parametreler: Reloaded olayı: [unit, weapon, muzzle, newMagazine, oldMagazine]
    Dönüş: yok
*/

params ["_unit", "_weapon"];

if (!TAC_rkt_enabled || {!(_weapon isEqualTo (secondaryWeapon _unit))}) exitWith {};

private _state = [_unit, _weapon] call TAC_fnc_rktGetState;

_state set [1, false];
_state set [2, false];
_state set [3, 0];
