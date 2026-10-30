/*
    Fonksiyon: TAC_fnc_nvgDebug
    Çalışma yeri: İstemci (debug konsolu: "Yerel çalıştır")

    NVG pil sisteminin anlık durumunu ve "NVG Pil Değiştir" eyleminin neden görünüp
    görünmediğini döker. Çıktı üç yere gider: ekranda hint, RPT ("[TAC][NVG-DEBUG]") ve
    panoya (Ctrl+V ile yapıştırılabilir).

    Kullanım (debug konsolu):
        call TAC_fnc_nvgDebug

    Parametreler: yok
    Dönüş: STRING - rapor metni
*/

private _unit = ACE_player;

if (isNil "TAC_nvg_batteryList") then {
    [TAC_nvg_batteryTable] call TAC_fnc_nvgParseBatteryTable;
};

private _found = [_unit] call TAC_fnc_nvgFindBattery;
private _swapUntil = _unit getVariable ["TAC_nvg_swapUntil", 0];

private _cEnabled = TAC_nvg_enabled;
private _cAlive = alive _unit;
private _cAwake = !(_unit getVariable ["ACE_isUnconscious", false]);
private _cNotBusy = time >= _swapUntil;
private _cHmd = !((hmd _unit) isEqualTo "");
private _cBattery = !(_found isEqualTo "");

private _tacItems = (items _unit) select {((toLower _x) find "tac_") == 0};

private _lines = [
    "== TAC NVG DEBUG ==",
    format ["Surum (yuklu PBO): %1", getText (configFile >> "CfgPatches" >> "tac_main" >> "versionStr")],
    format ["Son pil degistirme: %1", missionNamespace getVariable ["TAC_nvg_lastSwap", "(henuz denenmedi)"]],
    format ["Eylem gorunmeli (hepsi true olmali): %1", _cEnabled && _cAlive && _cAwake && _cNotBusy && _cHmd && _cBattery],
    format ["  sistem aktif: %1 | hayatta: %2 | bilinci acik: %3", _cEnabled, _cAlive, _cAwake],
    format ["  mesgul degil: %1 (time %2 / swapUntil %3)", _cNotBusy, round time, round _swapUntil],
    format ["  NVG takili (hmd): %1 -> '%2' | gorus modu: %3", _cHmd, hmd _unit, currentVisionMode _unit],
    format ["  envanterde tablodaki pil: %1 -> '%2'", _cBattery, _found],
    format ["Envanterde TAC_ esyalari: %1", _tacItems],
    format ["Pil tablosu (ayar): %1", TAC_nvg_batteryTable],
    format ["Pil tablosu (cozulen): %1", TAC_nvg_batteryList],
    format ["Sarj: %1 | takili pil: '%2' | dusuk uyari: %3", _unit getVariable ["TAC_nvg_charge", 100], _unit getVariable ["TAC_nvg_installedClass", ""], _unit getVariable ["TAC_nvg_lowWarned", false]],
    format ["Dongu (PFH): %1 | test modu: %2 (x%3) | degistirme suresi: %4 sn | dk/saat: %5 | esik: %6", missionNamespace getVariable ["TAC_nvg_pfh", -1], TAC_nvg_testMode, TAC_nvg_testSpeed, TAC_nvg_swapTime, TAC_nvg_minutesPerHour, TAC_nvg_lowThreshold],
    format ["Config: TAC_NVGBattery %1 (scope %2) | TAC_NVGBattery_Lithium %3", isClass (configFile >> "CfgWeapons" >> "TAC_NVGBattery"), getNumber (configFile >> "CfgWeapons" >> "TAC_NVGBattery" >> "scope"), isClass (configFile >> "CfgWeapons" >> "TAC_NVGBattery_Lithium")]
];

private _report = _lines joinString endl;

diag_log ("[TAC][NVG-DEBUG]" + endl + _report);
copyToClipboard _report;
hint _report;

_report
