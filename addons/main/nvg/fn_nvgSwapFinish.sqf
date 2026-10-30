/*
    Fonksiyon: TAC_fnc_nvgSwapFinish
    Çalışma yeri: İstemci

    Pil değiştirmeyi tamamlar: envanterde bulunan ilk pil (tablo sırası) düşülür, eski pil atılır,
    şarj %100 olur, takılı pil sınıfı kaydedilir (tüketim hızı o sınıfın ömrüne göre belirlenir),
    düşük pil efektleri ve uyarı bayrağı sıfırlanır.
    Süre içinde pil envanterden çıkmışsa (atılmış/verilmiş) hiçbir şey değişmez.

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};

_unit setVariable ["TAC_nvg_swapping", false];

private _class = [_unit] call TAC_fnc_nvgFindBattery;

if (!(_class isEqualTo "") && {_unit removeItem _class}) then {
    _unit setVariable ["TAC_nvg_charge", 100];
    _unit setVariable ["TAC_nvg_installedClass", _class];
    _unit setVariable ["TAC_nvg_lowWarned", false];
    call TAC_fnc_nvgClearEffects;

    private _name = getText (configFile >> "CfgWeapons" >> _class >> "displayName");
    if (_name isEqualTo "") then {_name = _class};

    ["NVG pili değiştirildi: " + _name] call TAC_fnc_nvgNotify;
} else {
    ["Envanterde NVG bataryası yok."] call TAC_fnc_nvgNotify;
};
