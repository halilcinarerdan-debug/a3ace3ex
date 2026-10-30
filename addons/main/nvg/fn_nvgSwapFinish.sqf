/*
    Fonksiyon: TAC_fnc_nvgSwapFinish
    Çalışma yeri: İstemci

    Pil değiştirmeyi tamamlar: envanterde bulunan ilk pil (tablo sırası) düşülür, eski pil atılır,
    şarj %100 olur, takılı pil sınıfı kaydedilir (tüketim hızı o sınıfın ömrüne göre belirlenir),
    düşük pil efektleri ve uyarı bayrağı sıfırlanır.

    removeItem'in dönüş değerine GÜVENİLMEZ (sürüme göre Bool veya hiçbir şey olabilir): pilin
    envanter sayısı önce/sonra karşılaştırılır. Pil gerçekten çıkarılamadıysa şarj YENİLENMEZ
    (bedava pil olmasın) ve oyuncuya hata gösterilir.
    Süre içinde pil envanterden çıkmışsa (atılmış/verilmiş) hiçbir şey değişmez.

    Sonuç TAC_nvg_lastSwap değişkenine yazılır (call TAC_fnc_nvgDebug gösterir).

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};

_unit setVariable ["TAC_nvg_swapUntil", 0];

private _class = [_unit] call TAC_fnc_nvgFindBattery;

if (_class isEqualTo "") exitWith {
    missionNamespace setVariable ["TAC_nvg_lastSwap", format ["t=%1 | BASARISIZ: bitiste envanterde tablodaki pil yok", round time]];
    diag_log "[TAC][NVG] pil degistirme basarisiz: envanterde tablodaki pil bulunamadi";
    ["Envanterde NVG bataryası yok.", true] call TAC_fnc_nvgNotify;
};

private _before = {(toLower _x) isEqualTo (toLower _class)} count (items _unit);
_unit removeItem _class;
private _after = {(toLower _x) isEqualTo (toLower _class)} count (items _unit);

if (_after >= _before) exitWith {
    missionNamespace setVariable ["TAC_nvg_lastSwap", format ["t=%1 | BASARISIZ: '%2' envanterden cikarilamadi (once %3, sonra %4)", round time, _class, _before, _after]];
    diag_log format ["[TAC][NVG] pil degistirme basarisiz: '%1' envanterden cikarilamadi (once %2, sonra %3)", _class, _before, _after];
    ["NVG bataryası envanterden çıkarılamadı.", true] call TAC_fnc_nvgNotify;
};

_unit setVariable ["TAC_nvg_charge", 100];
_unit setVariable ["TAC_nvg_installedClass", _class];
_unit setVariable ["TAC_nvg_lowWarned", false];
call TAC_fnc_nvgClearEffects;

missionNamespace setVariable ["TAC_nvg_lastSwap", format ["t=%1 | BASARILI: '%2' takildi, sarj 100 (envanter: once %3, sonra %4)", round time, _class, _before, _after]];

diag_log format [
    "[TAC][NVG] pil degistirildi: '%1' | omur: %2 saat | sarj: 100",
    _class,
    [_class] call TAC_fnc_nvgGetHours
];

private _name = getText (configFile >> "CfgWeapons" >> _class >> "displayName");
if (_name isEqualTo "") then {_name = _class};

["NVG pili değiştirildi: " + _name] call TAC_fnc_nvgNotify;
