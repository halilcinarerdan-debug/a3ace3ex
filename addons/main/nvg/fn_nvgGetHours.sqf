/*
    Fonksiyon: TAC_fnc_nvgGetHours
    Çalışma yeri: İstemci

    Bir pil sınıfının gerçek hayattaki ömrünü (saat) pil tablosundan verir.
    Sınıf boşsa (başlangıçtaki takılı pil) veya tabloda yoksa "Varsayılan pil ömrü" döner.

    Parametreler:
        0: STRING - pil classname (boş olabilir)

    Dönüş: NUMBER - saat
*/

params [["_class", "", [""]]];

if (isNil "TAC_nvg_batteryMap") then {
    [TAC_nvg_batteryTable] call TAC_fnc_nvgParseBatteryTable;
};

private _key = toLower _class;

// Soguk Savas modu: lityum AA pil donem disi, alkalin gibi davranir
if (!isNil "TAC_coldWar" && {TAC_coldWar} && {(_key find "lithium") >= 0}) then {_key = "tac_nvgbattery"};

TAC_nvg_batteryMap getOrDefault [_key, TAC_nvg_batteryHours]
