/*
    Fonksiyon: TAC_fnc_nvgDrainFactor
    Çalışma yeri: İstemci

    Pil tüketim çarpanı (>= 1): normal tüketimin kaç katı hızla boşalıyor.
        çarpan = cihaz çarpanı x soğuk çarpanı
      - cihaz: takılı NVG (hmd) sınıfı "Cihaz tüketim çarpanı" tablosunda varsa o değer, yoksa 1.
      - soğuk: ACE hava durumundan sıcaklık (ace_weather_currentTemperature, yoksa 20 °C sayılır).
        Kapasite = 1 - TAC_coldK x (20 - sıcaklık), alt sınır 0.25; çarpan = 1 / kapasite.
        TAC_coldK takılı pilin config alanıdır (alkalin 0.012, lityum 0.003). 20 °C ve üstü etkisiz.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: NUMBER
*/

params [["_unit", objNull, [objNull]]];

if (isNil "TAC_nvg_deviceMap") then {
    [TAC_nvg_deviceTable] call TAC_fnc_nvgParseDeviceTable;
};

private _factor = TAC_nvg_deviceMap getOrDefault [toLower (hmd _unit), 1];

if (TAC_nvg_cold) then {
    private _temp = missionNamespace getVariable ["ace_weather_currentTemperature", 20];

    if (_temp < 20) then {
        private _installed = _unit getVariable ["TAC_nvg_installedClass", ""];
        private _coldK = if (_installed isEqualTo "") then {0.012} else {([_installed] call TAC_fnc_nvgBatteryInfo) select 2};
        private _capacity = (1 - (_coldK * (20 - _temp))) max 0.25;

        _factor = _factor / _capacity;
    };
};

_factor
