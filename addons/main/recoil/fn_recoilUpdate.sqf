/*
    Fonksiyon: TAC_fnc_recoilUpdate
    Çalışma yeri: İstemci (yalnızca LOCAL oyuncu)

    Oyuncunun recoil çarpanını (setUnitRecoilCoefficient) mevcut/ateşlenen mühimmata göre günceller.
    Çarpan silahın MEVCUT recoil'inin üstüne biner (config + ACE + A3RO değerleri korunur).

        çarpan = kategori_çarpanı * genel_ölçek,  [0.1 .. Maksimum çarpan] aralığına sıkıştırılır

    Çağrıldığı yerler: silah / namlu / araç değişimi (CBA oyuncu olayları), şarjör değişimi
    (Reloaded), her atış (Fired, o anki mühimmatla) ve ayar değişimi (recoilRefresh).
    Mühimmat değişmediyse hiçbir şey yapmaz (atış başına maliyet: tek karşılaştırma).

    Mermi olmayan silahlarda (roketatar, bomba atar) ve araç silahlarında çarpan 1'dir.

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: STRING - (isteğe bağlı) mühimmat; verilmezse mevcut şarjörden okunur

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_ammo", "", [""]]];

if (isNull _unit || {!local _unit}) exitWith {};

if (_ammo isEqualTo "") then {
    private _weapon = currentWeapon _unit;

    // Araç silahı veya silahsız: infantry recoil'ine dokunma.
    if (!(_weapon isEqualTo "") && {_weapon in (weapons _unit)}) then {
        _ammo = getText (configFile >> "CfgMagazines" >> (currentMagazine _unit) >> "ammo");
    };
};

// Aynı mühimmat zaten uygulandıysa çık (ayar değişince recoilRefresh önbelleği sıfırlar).
if (_ammo isEqualTo (_unit getVariable ["TAC_recoil_ammo", "<yok>"])) exitWith {};
_unit setVariable ["TAC_recoil_ammo", _ammo];

private _category = 0;
private _coef = 1;

if (TAC_recoil_enabled && {!(_ammo isEqualTo "")}) then {
    _category = [_ammo] call TAC_fnc_recoilGetCategory;

    if (_category > 0) then {
        private _multipliers = [TAC_recoil_m1, TAC_recoil_m2, TAC_recoil_m3, TAC_recoil_m4, TAC_recoil_m5];

        _coef = ((_multipliers select (_category - 1)) * TAC_recoil_scale);
        _coef = (_coef min TAC_recoil_maxCoef) max 0.1;
    };
};

if ((abs (_coef - (unitRecoilCoefficient _unit))) > 0.001) then {
    _unit setUnitRecoilCoefficient _coef;
};

if (TAC_recoil_debug) then {
    private _energy = [_ammo] call TAC_fnc_recoilGetEnergy;

    hintSilent parseText format [
        "<t color='#ffcc00'>[TEST] Recoil</t><br/>Mühimmat: %1<br/>Enerji: %2 J<br/>Kategori: %3<br/>Çarpan: x%4",
        _ammo,
        round _energy,
        _category,
        (round (_coef * 100)) / 100
    ];
};
