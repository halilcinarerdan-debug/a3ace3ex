/*
    Fonksiyon: TAC_fnc_recoilAttach
    Çalışma yeri: İstemci (CBA "unit" oyuncu olayı)

    Oyuncu birimine "Fired" ve "Reloaded" olay dinleyicilerini bağlar, eski birimdekileri kaldırır
    (respawn, selectPlayer). Dinleyiciler yalnızca OYUNCUYA bağlıdır; yapay zekânın atışları
    kodu hiç çalıştırmaz. Yeni birimin recoil çarpanı 1'den başlar, hemen güncellenir.

    Parametreler:
        0: OBJECT - yeni birim
        1: OBJECT - eski birim (olmayabilir)

    Dönüş: yok
*/

params [["_newUnit", objNull, [objNull]], ["_oldUnit", objNull, [objNull]]];

if (!isNull _oldUnit) then {
    private _fired = _oldUnit getVariable ["TAC_recoil_ehFired", -1];
    private _reloaded = _oldUnit getVariable ["TAC_recoil_ehReloaded", -1];

    if (_fired >= 0) then {_oldUnit removeEventHandler ["Fired", _fired]};
    if (_reloaded >= 0) then {_oldUnit removeEventHandler ["Reloaded", _reloaded]};

    _oldUnit setVariable ["TAC_recoil_ehFired", -1];
    _oldUnit setVariable ["TAC_recoil_ehReloaded", -1];
};

if (isNull _newUnit) exitWith {};

// Aynı birime iki kez bağlama.
if ((_newUnit getVariable ["TAC_recoil_ehFired", -1]) < 0) then {
    // Fired: [unit, weapon, muzzle, mode, ammo, ...] -> o anki mühimmatla güncelle
    private _fired = _newUnit addEventHandler ["Fired", {
        [_this select 0, _this select 4] call TAC_fnc_recoilUpdate;
    }];

    // Reloaded: [unit, weapon, muzzle, newMagazine, oldMagazine]
    private _reloaded = _newUnit addEventHandler ["Reloaded", {
        params ["_unit", "", "", "_newMagazine"];

        if (_newMagazine isEqualType [] && {count _newMagazine > 0}) then {
            [_unit, getText (configFile >> "CfgMagazines" >> (_newMagazine select 0) >> "ammo")] call TAC_fnc_recoilUpdate;
        };
    }];

    _newUnit setVariable ["TAC_recoil_ehFired", _fired];
    _newUnit setVariable ["TAC_recoil_ehReloaded", _reloaded];
};

_newUnit setVariable ["TAC_recoil_ammo", "<yok>"];
[_newUnit] call TAC_fnc_recoilUpdate;
