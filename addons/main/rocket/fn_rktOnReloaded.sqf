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

private _keep = TAC_rkt_guided && {(([_weapon] call TAC_fnc_rktProfile) select 0) isEqualTo "guided"};

// Guduml: yeni fuze yuklenince sistem yeniden acilmaz (guc ve hazirlik korunur); digerlerinde hazirlik sifirlanir.
if (!_keep) then {
    private _wasReady = _state select 5;

    [_state] call TAC_fnc_rktPowerOff;
    _state set [5, false];
    _state set [10, 0];

    // Yeniden yukleme hazirligi sifirlar: parcalar katlanmis gorunur (R tusu)
    if (_wasReady) then {[_unit] call TAC_fnc_rktHint};
};

_state set [1, false];
_state set [2, false];
_state set [3, 0];
[_unit, _weapon] call TAC_fnc_rktPublish;
