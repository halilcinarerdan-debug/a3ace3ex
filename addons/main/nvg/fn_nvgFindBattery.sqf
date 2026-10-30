/*
    Fonksiyon: TAC_fnc_nvgFindBattery
    Çalışma yeri: İstemci

    Oyuncunun envanterinde (üniforma, yelek, sırt çantası) pil tablosundaki ilk pili arar.
    Tablo sırası önceliktir. ACE menü koşulundan çağrıldığı için ucuz tutulmuştur.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: STRING - bulunan pilin classname'i (tablodaki yazımıyla), yoksa ""
*/

params [["_unit", objNull, [objNull]]];

if (isNil "TAC_nvg_batteryList") then {
    [TAC_nvg_batteryTable] call TAC_fnc_nvgParseBatteryTable;
};

private _items = (items _unit) apply {toLower _x};
private _index = TAC_nvg_batteryList findIf {(toLower (_x select 0)) in _items};

if (_index < 0) then {
    ""
} else {
    (TAC_nvg_batteryList select _index) select 0
}
