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

// Elde tabanca (el silahi) mi? (tabanca kalibreli SMG / PDW tabanca sayilmaz)
private _handgun = handgunWeapon _unit;
private _isPistol = !(_handgun isEqualTo "") && {(currentWeapon _unit) isEqualTo _handgun};

// Ayni muhimmat + ayni silah turu zaten uygulandiysa cik (ayar degisince recoilRefresh onbellegi sifirlar).
private _key = format ["%1|%2", _ammo, _isPistol];
if (_key isEqualTo (_unit getVariable ["TAC_recoil_ammo", "<yok>"])) exitWith {};
_unit setVariable ["TAC_recoil_ammo", _key];

private _category = 0;
private _coef = 1;

if (TAC_recoil_enabled && {!(_ammo isEqualTo "")}) then {
    _category = [_ammo] call TAC_fnc_recoilGetCategory;

    if (_category > 0) then {
        private _multipliers = [TAC_recoil_m1, TAC_recoil_m2, TAC_recoil_m3, TAC_recoil_m4, TAC_recoil_m5];

        _coef = ((_multipliers select (_category - 1)) * TAC_recoil_scale);
        _coef = (_coef min TAC_recoil_maxCoef) max 0.1;

        // Guclendirme: tavandan SONRA carpilir (tavana takilmaz), sert tavanla sinirlanir;
        // yalnizca secili kategorilere (varsayilan 5.56 / 5.45 ve 7.62 aileleri; tabanca kalibreli ve yuksek kalibre haric)
        private _boostOn = [TAC_recoil_boostC1, TAC_recoil_boostC2, TAC_recoil_boostC3, TAC_recoil_boostC4, TAC_recoil_boostC5] select (_category - 1);

        if (_boostOn) then {
            _coef = ((_coef * TAC_recoil_boost) min TAC_recoil_hardCap) max 0.1;
        };
    };
};

// Tabancalara dokunma (ayara gore)
if (_isPistol && {TAC_recoil_skipPistols}) then {_coef = 1};

// Atis sarsintisi (TAC_fnc_recoilKick) icin son kategori ve tabanca bilgisi
_unit setVariable ["TAC_recoil_cat", _category];
_unit setVariable ["TAC_recoil_isPistol", _isPistol];

if ((abs (_coef - (unitRecoilCoefficient _unit))) > 0.001) then {
    _unit setUnitRecoilCoefficient _coef;
};

if (TAC_recoil_debug) then {
    private _energy = [_ammo] call TAC_fnc_recoilGetEnergy;

    hintSilent parseText format [
        "<t color='#ffcc00'>[TEST] Recoil</t><br/>Mühimmat: %1<br/>Enerji: %2 J<br/>Kategori: %3<br/>Çarpan: x%4 (güçlendirme x%5%6)",
        _ammo,
        round _energy,
        _category,
        (round (_coef * 100)) / 100,
        TAC_recoil_boost,
        ["", " | TABANCA: dokunulmadi"] select (_isPistol && {TAC_recoil_skipPistols})
    ];
};
