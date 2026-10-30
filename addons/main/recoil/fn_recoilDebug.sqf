/*
    Fonksiyon: TAC_fnc_recoilDebug
    Çalışma yeri: İstemci (debug konsolu: "Yerel çalıştır")

    Elindeki silahın recoil sınıflandırmasını döker: mühimmat, kinetik enerji, kategori, çarpan,
    motorun gerçekte uyguladığı katsayı ve tüm eşik/çarpan tablosu. Çıktı ekrana (hint), RPT'ye
    ("[TAC][RECOIL-DEBUG]") ve panoya gider.

    Kullanım:  call TAC_fnc_recoilDebug

    Parametreler: yok
    Dönüş: STRING - rapor
*/

private _unit = ACE_player;
private _weapon = currentWeapon _unit;
private _magazine = currentMagazine _unit;
private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");

private _energy = [_ammo] call TAC_fnc_recoilGetEnergy;
private _category = [_ammo] call TAC_fnc_recoilGetCategory;
private _names = ["recoil'e dokunulmaz", "Tabanca / PDW", "Hafif", "Orta", "Ağır", "Aşırı"];
private _config = configFile >> "CfgAmmo" >> _ammo;

private _limits = [TAC_recoil_t1, TAC_recoil_t2, TAC_recoil_t3, TAC_recoil_t4];
_limits sort true;

private _lines = [
    "== TAC RECOIL DEBUG ==",
    format ["Surum (yuklu PBO): %1", getText (configFile >> "CfgPatches" >> "tac_main" >> "versionStr")],
    format ["Silah: %1 | sarjor: %2 | mühimmat: %3", _weapon, _magazine, _ammo],
    format ["simulasyon: %1 | typicalSpeed: %2 | ACE_bulletMass: %3 gr | hit: %4", getText (_config >> "simulation"), getNumber (_config >> "typicalSpeed"), getNumber (_config >> "ACE_bulletMass"), getNumber (_config >> "hit")],
    format ["Enerji: %1 J | kategori: %2 (%3)", round _energy, _category, _names select _category],
    format ["Motorun uyguladigi katsayi: %1 | aktif: %2", unitRecoilCoefficient _unit, TAC_recoil_enabled],
    format ["Sinirlar (J): %1", _limits],
    format ["Carpanlar 1-5: %1 | genel olcek: %2 | tavan: %3", [TAC_recoil_m1, TAC_recoil_m2, TAC_recoil_m3, TAC_recoil_m4, TAC_recoil_m5], TAC_recoil_scale, TAC_recoil_maxCoef],
    format ["Istisnalar: %1", TAC_recoil_overrides]
];

private _report = _lines joinString endl;

diag_log ("[TAC][RECOIL-DEBUG]" + endl + _report);
copyToClipboard _report;
hint _report;

_report
