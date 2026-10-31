/*
    Fonksiyon: TAC_fnc_zoomDebug
    Çalışma yeri: İstemci (debug konsolu: "Yerel çalıştır")

    Elindeki silahın zoom config'ini döker: yama etkili mi, değer nereden geliyor.
      - opticsZoomMin/Max/Init (config'den okunan, yama sonrası değer)
      - bu sınıf değeri KENDİ mi tanımlıyor (true ise taban yama etkilemez: TAC_fnc_zoomScan ile
        overrides.hpp'ye eklenmeli) yoksa miras mı alıyor
      - takılı optik ve OpticsModes zoom değerleri
    Çıktı ekrana, RPT'ye ("[TAC][ZOOM-DEBUG]") ve panoya gider.

    Kullanım:
        call TAC_fnc_zoomDebug

    Parametreler: yok
    Dönüş: STRING - rapor
*/

private _unit = ACE_player;
private _weapon = currentWeapon _unit;
private _lines = [
    "== TAC ZOOM DEBUG ==",
    format ["Surum (yuklu PBO): %1", getText (configFile >> "CfgPatches" >> "tac_main" >> "versionStr")],
    format ["Ciplak goz zoom engeli: %1 | su an engellenir: %2 | engellenen girisim: %3", TAC_zoom_blockBare, [] call TAC_fnc_zoomIsBlocked, missionNamespace getVariable ["TAC_zoom_blocked", 0]]
];

if (_weapon isEqualTo "") then {
    _lines pushBack "Elde silah yok (currentWeapon bos).";
} else {
    private _cfg = configFile >> "CfgWeapons" >> _weapon;
    private _own = configProperties [_cfg, "(toLower (configName _x)) in ['opticszoommin','opticszoommax','opticszoominit']", false];
    private _ownNames = _own apply {configName _x};

    _lines pushBack format ["Silah: %1 | taban: %2", _weapon, configName (inheritsFrom _cfg)];
    _lines pushBack format ["Config degeri (min/max/init): %1 / %2 / %3", getNumber (_cfg >> "opticsZoomMin"), getNumber (_cfg >> "opticsZoomMax"), getNumber (_cfg >> "opticsZoomInit")];
    _lines pushBack format ["Sinifin KENDI tanimladigi zoom alanlari: %1", if (_ownNames isEqualTo []) then {"yok (miras alir: taban yama etkili)"} else {str _ownNames + " -> overrides.hpp gerekebilir"}];
    _lines pushBack format ["Config kaynagi (CfgPatches): %1", configSourceAddonList _cfg];

    // weaponsItems: [silah, namlu, lazer/fener, optik, bipod, sarjor, ...]
    private _item = (weaponsItems _unit) select {(_x select 0) isEqualTo _weapon};
    private _optic = if (_item isEqualTo []) then {""} else {(_item select 0) param [3, ""]};
    if (_optic isEqualTo "") then {
        _lines pushBack "Optik takili degil: demir nisan (bu yama gecerli).";
    } else {
        _lines pushBack format ["Takili optik: %1", _optic];
        {
            _lines pushBack format ["  mod %1: min %2 | max %3 | init %4", configName _x, getNumber (_x >> "opticsZoomMin"), getNumber (_x >> "opticsZoomMax"), getNumber (_x >> "opticsZoomInit")];
        } forEach ("true" configClasses (configFile >> "CfgWeapons" >> _optic >> "ItemInfo" >> "OpticsModes"));
    };
};

private _report = _lines joinString endl;

diag_log ("[TAC][ZOOM-DEBUG]" + endl + _report);
copyToClipboard _report;
hint _report;

_report
