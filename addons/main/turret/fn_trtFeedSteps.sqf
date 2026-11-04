/*
    Fonksiyon: TAC_fnc_trtFeedSteps
    Çalışma yeri: İstemci

    Sabit silahın besleme prosedürü (silaha ve kalibreye özel). Önce silah adına, sonra mühimmat kalibresine bakılır:
      M2 / .50 BMG (12.7x99)        : kapak, kayış (açık yan aşağı), kapat, sürgü kolunu 2 kez çek, BOŞLUK (headspace) ve zamanlama kontrolü
      DShK / NSV / Kord / KPV (12.7x108, 14.5x114) : kapak, kayışı tırnağa oturt, kapat, sürgü kolu, gaz ayarı kontrolü
      Bombaatar (Mk19, GMG 40 mm; AGS-30 / AGS-17 30 mm) : kapak, kayış (kutu), kapat, kolu 2 kez çek, emniyeti aç
      diğer kayışlı (7.62 statik vb.) : kişisel MG tablosu (TAC_fnc_wpnFeedSteps: PKM, M240, MG3...)

    Parametreler:
        0: STRING - silah classname
        1: OBJECT - (isteğe bağlı) araç (şarjör yedek kaynağı)

    Dönüş: ARRAY - [[metin, süre], ...]
*/

params [["_weapon", "", [""]], ["_veh", objNull, [objNull]]];

private _key = [_weapon] call TAC_fnc_wpnSearchKey;
private _cfg = configFile >> "CfgWeapons" >> _weapon;
private _mags = getArray (_cfg >> "magazines");

if (_mags isEqualTo [] && {!isNull _veh}) then {_mags = _veh magazinesTurret [0]};

private _ammo = toLower (if (_mags isEqualTo []) then {""} else {getText (configFile >> "CfgMagazines" >> (_mags select 0) >> "ammo")});
private _hit = {params ["_list"]; (_list findIf {(_key find _x) >= 0 || {(_ammo find _x) >= 0}}) >= 0};

if (["m2hb", "m2_", "_m2", "browning", "127x99"] call _hit) exitWith {
    [["Besleme kapağını aç", 2], ["Kayışı yerleştir (açık yan aşağı)", 3], ["Kapağı kapat", 1.5], ["Sürgü kolunu iki kez çek", 3], ["Boşluk (headspace) ve zamanlama kontrolü", 3]]
};

if (["dshk", "nsv", "kord", "kpv", "zpu", "127x108", "145x114"] call _hit) exitWith {
    [["Besleme kapağını aç", 2], ["Kayışı tırnağa oturt", 3], ["Kapağı kapat", 1.5], ["Sürgü kolunu çek", 2.5], ["Gaz ayarını kontrol et", 2]]
};

if (["mk19", "gmg", "ags", "40x53", "30x29", "30mm"] call _hit) exitWith {
    [["Besleme kapağını aç", 2], ["Kayış / kutuyu yerleştir", 3], ["Kapağı kapat", 1.5], ["Kolu iki kez çek", 3], ["Emniyeti aç", 1.5]]
};

[_weapon] call TAC_fnc_wpnFeedSteps
