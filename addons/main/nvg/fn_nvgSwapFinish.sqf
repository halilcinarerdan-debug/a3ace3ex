/*
    Fonksiyon: TAC_fnc_nvgSwapFinish
    Çalışma yeri: İstemci

    Pil değiştirmeyi tamamlar:
      1. Seçilen pil envanterden düşülür.
         removeItem'in dönüş değerine GÜVENİLMEZ (sürüme göre Bool veya hiçbir şey olabilir): pilin
         envanter sayısı önce/sonra karşılaştırılır. Pil gerçekten çıkarılamadıysa HİÇBİR ŞEY değişmez
         (bedava pil olmasın) ve oyuncuya hata gösterilir. Süre içinde pil envanterden çıkmışsa
         (atılmış/verilmiş) yine hiçbir şey değişmez.
      2. Takılı eski pil varsa kalan şarjına göre kademeye çevrilip (TAC_fnc_nvgTierClass) envantere
         iade edilir; yer yoksa yere düşer. Bitik pil "bitik pil" eşyası olur.
      3. Yeni pil takılır: şarj = pilin taşıdığı şarj (dolu pil %100, ~%50 pil %50), takılı pil ana
         sınıfı kaydedilir (tüketim hızı o pilin ömrüne göre belirlenir), düşük pil efektleri sıfırlanır.

    Sonuç TAC_nvg_lastSwap değişkenine yazılır (call TAC_fnc_nvgDebug gösterir).

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: STRING - takılacak pilin classname'i

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_class", "", [""]]];

if (isNull _unit) exitWith {};

_unit setVariable ["TAC_nvg_swapUntil", 0];

private _before = {(toLower _x) isEqualTo (toLower _class)} count (items _unit);

if (_class isEqualTo "" || {_before == 0}) exitWith {
    missionNamespace setVariable ["TAC_nvg_lastSwap", format ["t=%1 | BASARISIZ: bitiste '%2' envanterde yok", round time, _class]];
    diag_log format ["[TAC][NVG] pil degistirme basarisiz: '%1' envanterde bulunamadi", _class];
    ["Envanterde NVG bataryası yok.", true] call TAC_fnc_nvgNotify;
};

_unit removeItem _class;
private _after = {(toLower _x) isEqualTo (toLower _class)} count (items _unit);

if (_after >= _before) exitWith {
    missionNamespace setVariable ["TAC_nvg_lastSwap", format ["t=%1 | BASARISIZ: '%2' envanterden cikarilamadi (once %3, sonra %4)", round time, _class, _before, _after]];
    diag_log format ["[TAC][NVG] pil degistirme basarisiz: '%1' envanterden cikarilamadi (once %2, sonra %3)", _class, _before, _after];
    ["NVG bataryası envanterden çıkarılamadı.", true] call TAC_fnc_nvgNotify;
};

// Eski pili iade et (yeni pil cikinca bir yer acildi).
private _returned = "";

if (_unit getVariable ["TAC_nvg_hasBattery", true]) then {
    _returned = [_unit getVariable ["TAC_nvg_installedClass", ""], (_unit getVariable ["TAC_nvg_charge", 100]) / 100] call TAC_fnc_nvgTierClass;
    [_unit, _returned] call TAC_fnc_nvgPlaceItem;
};

private _info = [_class] call TAC_fnc_nvgBatteryInfo;

_unit setVariable ["TAC_nvg_hasBattery", true];
_unit setVariable ["TAC_nvg_charge", (_info select 1) * 100];
_unit setVariable ["TAC_nvg_installedClass", _info select 0];
_unit setVariable ["TAC_nvg_lowWarned", false];
call TAC_fnc_nvgClearEffects;

missionNamespace setVariable ["TAC_nvg_lastSwap", format ["t=%1 | BASARILI: '%2' takildi, sarj %3 | iade: '%4' (envanter: once %5, sonra %6)", round time, _class, round ((_info select 1) * 100), _returned, _before, _after]];

diag_log format [
    "[TAC][NVG] pil degistirildi: '%1' (ana sinif '%2') | omur: %3 saat | sarj: %4 | iade edilen: '%5'",
    _class,
    _info select 0,
    [_info select 0] call TAC_fnc_nvgGetHours,
    round ((_info select 1) * 100),
    _returned
];

private _name = getText (configFile >> "CfgWeapons" >> _class >> "displayName");
if (_name isEqualTo "") then {_name = _class};

["NVG pili değiştirildi: " + _name] call TAC_fnc_nvgNotify;
