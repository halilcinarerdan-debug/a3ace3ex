/*
    Fonksiyon: TAC_fnc_trtDebug
    Çalışma yeri: İstemci (debug konsolu: "Yerel çalıştır")

    Baktığın sabit silahın (cursorObject, yoksa içinde olduğun araç) sistem tanısını döker: sınıf, silah, ilk şarjör
    ve mühimmat, mühimmat simülasyonu, atanan TÜR, besleme / hazırlık adımları ve araçtaki durum. "Tüm taretler aynı
    sistemi açıyor" gibi durumlarda hangi sınıfın hangi türe düştüğünü görmek içindir. Çıktı ekrana, RPT'ye
    ("[TAC][TRT-DEBUG]") ve panoya gider.

    Kullanım: call TAC_fnc_trtDebug

    Parametreler: yok
    Dönüş: STRING - rapor
*/

private _veh = if (!isNull cursorObject && {cursorObject isKindOf "StaticWeapon"}) then {cursorObject} else {vehicle ACE_player};

private _lines = ["== TAC TARET DEBUG ==", format ["Surum (yuklu PBO): %1", getText (configFile >> "CfgPatches" >> "tac_main" >> "versionStr")]];

if (isNull _veh || {!(_veh isKindOf "StaticWeapon")}) then {
    _lines pushBack "Sabit silah yok: bir statik silaha bakarak ya da icine binerek calistir.";
} else {
    private _weapon = (_veh weaponsTurret [0]) param [0, ""];
    private _kind = [_weapon, _veh] call TAC_fnc_trtKind;
    private _mags = _veh magazinesTurret [0];
    private _mag = _mags param [0, ""];
    private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");

    _lines pushBack format ["Arac: %1 | silahlar: %2", typeOf _veh, _veh weaponsTurret [0]];
    _lines pushBack format ["Silah: %1 | tur: %2 | roket profili: %3", _weapon, _kind, [_weapon] call TAC_fnc_rktProfile];
    _lines pushBack format ["Sarjor: %1 (sayi %2) | mühimmat: %3 | simulasyon: %4", _mag, getNumber (configFile >> "CfgMagazines" >> _mag >> "count"), _ammo, getText (configFile >> "CfgAmmo" >> _ammo >> "simulation")];

    switch (_kind) do {
        case "mg": {_lines pushBack format ["Besleme adimlari: %1", [_weapon, _veh] call TAC_fnc_trtFeedSteps]};
        case "guided"; case "launcher": {_lines pushBack format ["Hazirlik adimlari: %1", [_weapon, _mag] call TAC_fnc_rktPrepSteps]};
    };

    _lines pushBack format ["Durum (aracta): %1", [_veh, _weapon] call TAC_fnc_trtState];
};

private _report = _lines joinString endl;

diag_log ("[TAC][TRT-DEBUG]" + endl + _report);
copyToClipboard _report;
hint _report;

_report
