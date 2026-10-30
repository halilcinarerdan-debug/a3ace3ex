/*
    Fonksiyon: TAC_fnc_recoilGetCategory
    Çalışma yeri: İstemci

    Mühimmatın recoil kategorisini verir:
        0 = recoil'e dokunma (mermi değil / istisna 0)
        1 Tabanca/PDW | 2 Hafif | 3 Orta | 4 Ağır | 5 Aşırı

    Önce "Kategori istisnaları" tablosuna bakar, yoksa kinetik enerjiyi sınırlarla karşılaştırır.
    Sınırlar karışık girilmişse otomatik sıralanır.

    Parametreler:
        0: STRING - mühimmat classname

    Dönüş: NUMBER - 0..5
*/

params [["_ammo", "", [""]]];

if (isNil "TAC_recoil_overrideMap") then {
    [TAC_recoil_overrides] call TAC_fnc_recoilParseOverrides;
};

private _override = TAC_recoil_overrideMap getOrDefault [toLower _ammo, -1];
if (_override >= 0) exitWith {_override};

private _energy = [_ammo] call TAC_fnc_recoilGetEnergy;
if (_energy < 0) exitWith {0};

private _limits = [TAC_recoil_t1, TAC_recoil_t2, TAC_recoil_t3, TAC_recoil_t4];
_limits sort true;

1 + ({_energy >= _x} count _limits)
