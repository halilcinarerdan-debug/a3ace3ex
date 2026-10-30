/*
    Fonksiyon: TAC_fnc_nvgPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    NVG pili modülünün istemci tarafı kurulumu:
      1. ACE self-action: "NVG Pil Değiştir" (sınıfa bir kez eklenir, respawn'da yeniden gerekmez).
      2. CBA oyuncu olayı "visionMode": NVG açılınca tüketimi başlatır, kapanınca durdurur.
         Sürekli döngü yok; tüketim yalnızca NVG açıkken çalışan bir PFH ile yürür.
      3. CBA oyuncu olayı "unit": birim değişince (respawn) PFH ve efektleri temizler.
         Şarj birimin üzerinde tutulduğundan yeni beden otomatik %100 başlar.

    Parametreler: yok
    Dönüş: yok
*/

// ----------------------------------------------------------------------------
// 1. ACE: NVG Pil Değiştir
// ----------------------------------------------------------------------------
// Görünme koşulu: sistem açık, oyuncu hayatta/bilinci yerinde, NVG takılı ve envanterde
// pil tablosundaki pillerden biri var (hangisinin kullanılacağı tablo sırasına göre).
private _swapAction = [
    "TAC_nvg_swap",
    "NVG Pil Değiştir",
    "\a3\ui_f\data\gui\rsc\rscdisplayarsenal\nvgs_ca.paa",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_nvgSwapBattery;
    },
    {
        params ["_target", "_player"];

        TAC_nvg_enabled
        && {alive _player}
        && {!(_player getVariable ["ACE_isUnconscious", false])}
        && {time >= (_player getVariable ["TAC_nvg_swapUntil", 0])}
        && {!((hmd _player) isEqualTo "")}
        && {!(([_player] call TAC_fnc_nvgFindBattery) isEqualTo "")}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions"], _swapAction, true] call ace_interact_menu_fnc_addActionToClass;

// ----------------------------------------------------------------------------
// 2. NVG açma / kapama
// ----------------------------------------------------------------------------
// applyInitial = true: oyun NVG açıkken başladıysa da mevcut durum işlenir.
["visionMode", {
    _this call TAC_fnc_nvgOnVisionMode;
}, true] call CBA_fnc_addPlayerEventHandler;

// ----------------------------------------------------------------------------
// 3. Birim değişimi (respawn, selectPlayer)
// ----------------------------------------------------------------------------
["unit", {
    call TAC_fnc_nvgStop;
}] call CBA_fnc_addPlayerEventHandler;

// ----------------------------------------------------------------------------
// 4. Açılış raporu (RPT): pil sınıfları config'te var mı, tablo nasıl çözüldü
// ----------------------------------------------------------------------------
if (isNil "TAC_nvg_batteryList") then {
    [TAC_nvg_batteryTable] call TAC_fnc_nvgParseBatteryTable;
};

{
    _x params ["_class", "_hours"];

    diag_log format [
        "[TAC][NVG] hazir | pil '%1': config %2 (scope %3) | omur %4 saat",
        _class,
        isClass (configFile >> "CfgWeapons" >> _class),
        getNumber (configFile >> "CfgWeapons" >> _class >> "scope"),
        _hours
    ];
} forEach TAC_nvg_batteryList;
