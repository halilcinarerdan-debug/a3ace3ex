/*
    Fonksiyon: TAC_fnc_nvgFindBattery
    Çalışma yeri: İstemci

    Envanterdeki "en iyi" pili verir: pil tablosu sırasına göre ilk pil, aynı pilde en dolu kademe.
    Ayrıntılı liste için TAC_fnc_nvgListBatteries.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: STRING - pilin classname'i, yoksa ""
*/

params [["_unit", objNull, [objNull]]];

private _list = [_unit] call TAC_fnc_nvgListBatteries;

if (_list isEqualTo []) then {""} else {(_list select 0) select 0}
