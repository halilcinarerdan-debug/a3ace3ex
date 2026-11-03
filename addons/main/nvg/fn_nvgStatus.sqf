/*
    Fonksiyon: TAC_fnc_nvgStatus
    Çalışma yeri: İstemci

    "Pil durumu" eyleminin gövdesi: takılı pilin şarjını, tahmini kalan kullanım süresini
    (soğuk ve cihaz çarpanı dahil) ve envanterdeki yedek pilleri ACE yazı kartı olarak gösterir.
    Kalan süre iki türlü yazılır: "pil saati" (gerçek hayattaki kullanım) ve oyundaki dakika
    (1 pil saati = ayardaki dk).

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};

private _lines = [];

if (_unit getVariable ["TAC_nvg_hasBattery", true]) then {
    private _charge = _unit getVariable ["TAC_nvg_charge", 100];
    private _installed = _unit getVariable ["TAC_nvg_installedClass", ""];
    private _hours = [_installed] call TAC_fnc_nvgGetHours;
    private _factor = [_unit] call TAC_fnc_nvgDrainFactor;
    private _left = (_charge / 100) * _hours / _factor;
    private _name = getText (configFile >> "CfgWeapons" >> _installed >> "displayName");

    if (_name isEqualTo "") then {_name = "Başlangıç pili"};

    _lines pushBack format ["<t size='1.1'>Takılı pil: %1</t>", _name];
    _lines pushBack format ["Şarj: %1%%", round _charge];
    _lines pushBack format ["Kalan kullanım: ~%1 saat (oyunda ~%2 dk)", (round (_left * 10)) / 10, round (_left * TAC_nvg_minutesPerHour)];

    if (_factor > 1.05) then {
        _lines pushBack format ["Tüketim çarpanı: x%1 (soğuk / cihaz)", (round (_factor * 100)) / 100];
    };
} else {
    _lines pushBack "<t size='1.1'>NVG'de pil yok</t>";
};

private _list = [_unit] call TAC_fnc_nvgListBatteries;

if (_list isEqualTo []) then {
    _lines pushBack "Envanterde yedek pil yok.";
} else {
    _lines pushBack "Yedek piller:";

    {
        _x params ["_class", "", "", "_count"];

        _lines pushBack format [
            "  %1 x%2",
            getText (configFile >> "CfgWeapons" >> _class >> "displayName"),
            _count
        ];
    } forEach _list;
};

[_lines joinString "<br/>"] call ace_common_fnc_displayTextStructured;
