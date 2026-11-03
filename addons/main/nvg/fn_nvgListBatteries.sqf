/*
    Fonksiyon: TAC_fnc_nvgListBatteries
    Çalışma yeri: İstemci

    Oyuncunun envanterindeki (üniforma, yelek, sırt çantası) kullanılabilir NVG pillerini listeler:
    ana sınıfı pil tablosunda olan her eşya (kısmen kullanılmış kademeler dahil). Aynı sınıf tek
    satırda sayılır. Sıralama: pil tablosu sırası, aynı pilde dolu olan önce.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: ARRAY - [[classname, ana sınıf, şarj 0..1, adet], ...]
*/

params [["_unit", objNull, [objNull]]];

if (isNil "TAC_nvg_batteryList") then {
    [TAC_nvg_batteryTable] call TAC_fnc_nvgParseBatteryTable;
};

private _order = TAC_nvg_batteryList apply {toLower (_x select 0)};
private _counts = createHashMap;

{
    private _key = toLower _x;
    private _entry = _counts getOrDefault [_key, [_x, 0]];

    _entry set [1, (_entry select 1) + 1];
    _counts set [_key, _entry];
} forEach (items _unit);

private _result = [];

{
    _x params ["_class", "_count"];

    private _info = [_class] call TAC_fnc_nvgBatteryInfo;
    private _index = _order find (toLower (_info select 0));

    if (_index >= 0) then {
        _result pushBack [(_index * 10) + (1 - (_info select 1)), [_class, _info select 0, _info select 1, _count]];
    };
} forEach (values _counts);

_result sort true;

_result apply {_x select 1}
