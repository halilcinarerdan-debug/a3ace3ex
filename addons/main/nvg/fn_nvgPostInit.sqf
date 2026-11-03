/*
    Fonksiyon: TAC_fnc_nvgPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf çağırır)

    NVG pili modülünün istemci tarafı kurulumu:
      1. ACE self-menu "NVG Pili": Pil durumu / Pil tak (dinamik liste) / Pili çıkar (sınıfa bir kez
         eklenir, respawn'da yeniden gerekmez).
      2. CBA oyuncu olayı "visionMode": NVG açılınca tüketimi başlatır, kapanınca durdurur.
         Sürekli döngü yok; tüketim yalnızca NVG açıkken çalışan bir PFH ile yürür.
      3. CBA oyuncu olayı "unit": birim değişince (respawn) PFH ve efektleri temizler.
         Şarj birimin üzerinde tutulduğundan yeni beden otomatik %100 başlar.

    Parametreler: yok
    Dönüş: yok
*/

// ----------------------------------------------------------------------------
// 1. ACE self-menu: NVG Pili (klasor) > Pil durumu | Pil tak / değiştir (dinamik) | Pili çıkar
// ----------------------------------------------------------------------------
// Klasör görünme koşulu: sistem açık, oyuncu hayatta/bilinci yerinde, NVG takılı.
// "Pil tak" alt menüsü envanterdeki her pil türünü (ve kısmen kullanılmış kademeleri) ayrı satır olarak
// listeler; seçilen pil takılır, eski pil kalan şarjıyla envantere döner.
private _icon = "\a3\ui_f\data\gui\rsc\rscdisplayarsenal\nvgs_ca.paa";

private _menu = [
    "TAC_nvg_menu",
    "NVG Pili",
    _icon,
    {},
    {
        params ["_target", "_player"];

        TAC_nvg_enabled
        && {alive _player}
        && {!(_player getVariable ["ACE_isUnconscious", false])}
        && {!((hmd _player) isEqualTo "")}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions"], _menu, true] call ace_interact_menu_fnc_addActionToClass;

private _status = [
    "TAC_nvg_status",
    "Pil durumu",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_nvgStatus;
    },
    {true}
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_nvg_menu"], _status, true] call ace_interact_menu_fnc_addActionToClass;

private _insert = [
    "TAC_nvg_insert",
    "Pil tak / değiştir",
    "",
    {},
    {
        params ["_target", "_player"];

        time >= (_player getVariable ["TAC_nvg_swapUntil", 0])
        && {!(([_player] call TAC_fnc_nvgListBatteries) isEqualTo [])}
    },
    {
        params ["_target", "_player"];

        private _actions = [];

        {
            _x params ["_class", "", "_levelFrac", "_count"];

            private _label = format [
                "%1 (x%2)",
                getText (configFile >> "CfgWeapons" >> _class >> "displayName"),
                _count
            ];

            private _child = [
                format ["TAC_nvg_insert_%1", _class],
                _label,
                "",
                {
                    params ["_target", "_player", "_class"];
                    [_player, _class] call TAC_fnc_nvgSwapBattery;
                },
                {true},
                {},
                _class
            ] call ace_interact_menu_fnc_createAction;

            _actions pushBack [_child, [], _target];
        } forEach ([_player] call TAC_fnc_nvgListBatteries);

        _actions
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_nvg_menu"], _insert, true] call ace_interact_menu_fnc_addActionToClass;

private _remove = [
    "TAC_nvg_remove",
    "Pili çıkar",
    "",
    {
        params ["_target", "_player"];
        [_player] call TAC_fnc_nvgRemoveBattery;
    },
    {
        params ["_target", "_player"];

        time >= (_player getVariable ["TAC_nvg_swapUntil", 0])
        && {_player getVariable ["TAC_nvg_hasBattery", true]}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions", "TAC_nvg_menu"], _remove, true] call ace_interact_menu_fnc_addActionToClass;

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
