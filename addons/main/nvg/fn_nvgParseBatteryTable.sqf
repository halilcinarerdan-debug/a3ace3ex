/*
    Fonksiyon: TAC_fnc_nvgParseBatteryTable
    Çalışma yeri: İstemci + sunucu (ayar kaydında ve her değişimde CBA çağırır)

    "Pil tablosu" ayarını ("classname=saat; classname=saat; ...") çözer ve iki global üretir:
        TAC_nvg_batteryList : [[classname, saat], ...]   tablo sırasıyla (öncelik sırası)
        TAC_nvg_batteryMap  : HashMap  küçük_harf_classname -> saat
    Geçersiz girişler (sayı değil, saat <= 0, eksik '=') atlanır; tekrarlarda ilk giriş geçerlidir.
    Hiç geçerli giriş yoksa varsayılan pil olarak TAC_NVGBattery kullanılır.

    Parametreler:
        0: STRING - tablo metni

    Dönüş: yok
*/

params [["_table", "", [""]]];

private _list = [];
private _map = createHashMap;

{
    // "TAC_NVGBattery = 40" -> ["TAC_NVGBattery", "40"]  ('=' ve boşluk ayraç)
    private _parts = _x splitString "= ";

    if (count _parts >= 2) then {
        private _class = _parts select 0;
        private _hours = parseNumber (_parts select 1);
        private _key = toLower _class;

        if (_hours > 0 && {(_map getOrDefault [_key, -1]) < 0}) then {
            _map set [_key, _hours];
            _list pushBack [_class, _hours];
        };
    };
} forEach (_table splitString ";");

if (_list isEqualTo []) then {
    private _default = missionNamespace getVariable ["TAC_nvg_batteryHours", 40];

    _map set ["tac_nvgbattery", _default];
    _list pushBack ["TAC_NVGBattery", _default];

    diag_log "[TAC] NVG pil tablosu boş/geçersiz, varsayılan kullanılıyor.";
};

missionNamespace setVariable ["TAC_nvg_batteryList", _list];
missionNamespace setVariable ["TAC_nvg_batteryMap", _map];
