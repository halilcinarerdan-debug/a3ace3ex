/*
    Fonksiyon: TAC_fnc_wpnScan
    Çalışma yeri: İstemci (debug konsolu: "Yerel çalıştır"). Taranacak mod YÜKLÜYKEN çalıştır.

    Bir modun (TMT, RHS, CUP... fark etmez) silahlarını ve sabit silahlarını TARAR ve bu sistemin her biri için ne
    atadığını gösterir. Uyumluluğu doğrulamak ve genel (kalibre yedeği) profile düşen silahları bulmak içindir.

    Her kişisel silah (tüfek / MG / tabanca / fırlatıcı) için: sınıf [oyundaki görünen ad] | kategori | güvenilirlik profili (etiket, MRBS,
    kalite) | kayışlı MG mi | fırlatıcıysa tür ve taban ateşlenmeme. "GENEL" işareti = tabloda adı bulunamadı,
    kalibre / kategoriye göre genel değer atandı. Sabit silah araçları (StaticWeapon) için: araç | silah | tür.
    Çıktı ekrana özet, RPT'ye ("[TAC][SCAN]" önekli satırlar) ve panoya (Ctrl+V) gider.

    Kullanım:
        ["tmt"] call TAC_fnc_wpnScan      // classname'i "tmt" ile BAŞLAYAN / içeren silahlar ve statikler
        [""] call TAC_fnc_wpnScan         // HEPSİ (çok uzun olur)
    Elle düzeltmek için: "MRBS tablosu" (TAC_wpn_mrbsTable), "MG olarak zorla" (TAC_wpn_mgTable),
    "Ateşlenmeme tablosu" (TAC_rkt_table) CBA ayarları; kalıcı eşleştirme için tablolardaki alt dizeler.

    Parametreler:
        0: STRING - classname'de aranacak küçük harfli parça (önek ya da içerik)

    Dönüş: STRING - rapor
*/

params [["_filter", "", [""]]];

_filter = toLower _filter;

private _lines = [];
private _generic = 0;
private _total = 0;

private _weapons = ("getNumber (_x >> 'scope') >= 2" configClasses (configFile >> "CfgWeapons")) select {
    private _name = toLower (configName _x);

    (_filter isEqualTo "" || {(_name find _filter) >= 0}) && {(getNumber (_x >> "type")) in [1, 2, 4]}
};

{
    private _weapon = configName _x;
    private _type = getNumber (_x >> "type");
    private _row = "";
    private _name = format ["%1 [%2]", _weapon, getText (_x >> "displayName")];

    if (_type == 4) then {
        private _profile = [_weapon] call TAC_fnc_rktProfile;
        _row = format ["%1 | firlatici | %2 | %3 | taban atesleneme %4%%", _name, _profile select 0, _profile select 2, (round ((_profile select 1) * 1000)) / 10];

        if ((_profile select 2) find "genel" >= 0 || {(_profile select 2) find "Genel" >= 0}) then {_generic = _generic + 1; _row = _row + " | GENEL"};
    } else {
        private _cat = [_weapon] call TAC_fnc_wpnCategory;
        private _profile = [_weapon] call TAC_fnc_wpnProfile;
        _row = format ["%1 | %2 | %3 | MRBS %4 | %5 | kayisli MG: %6", _name, if (_cat isEqualTo []) then {"-"} else {_cat select 0}, _profile select 3, _profile select 0, _profile select 4, [_weapon] call TAC_fnc_wpnIsBeltFed];

        if ((_profile select 3) find "kalibreye" >= 0 || {(_profile select 3) isEqualTo "Genel"}) then {_generic = _generic + 1; _row = _row + " | GENEL"};
    };

    _total = _total + 1;
    _lines pushBack _row;
} forEach _weapons;

// Sabit silahlar
private _statics = ("getNumber (_x >> 'scope') >= 2 && {configName _x isKindOf 'StaticWeapon'}" configClasses (configFile >> "CfgVehicles")) select {
    _filter isEqualTo "" || {((toLower (configName _x)) find _filter) >= 0}
};

{
    private _vehClass = configName _x;
    private _turretWeapon = (getArray (_x >> "weapons")) param [0, ""];
    private _turret = (configProperties [_x >> "Turrets", "isClass _x", true]) param [0, configNull];

    if (!isNull _turret) then {_turretWeapon = (getArray (_turret >> "weapons")) param [0, _turretWeapon]};

    _lines pushBack format ["[STATIK] %1 [%4] | silah %2 | tur %3", _vehClass, _turretWeapon, [_turretWeapon] call TAC_fnc_trtKind, getText (_x >> "displayName")];
} forEach _statics;

private _summary = format ["Tarama '%1': %2 kisisel silah | %3 GENEL profile dustu | %4 statik silah", _filter, _total, _generic, count _statics];

diag_log ("[TAC][SCAN] " + _summary);
{diag_log ("[TAC][SCAN] " + _x)} forEach _lines;

private _report = _summary + endl + (_lines joinString endl);

copyToClipboard _report;
hint _summary;

_report
