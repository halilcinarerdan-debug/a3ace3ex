/*
    Fonksiyon: TAC_fnc_rktHintLayout
    Çalışma yeri: İstemci

    Elindeki fırlatıcı için hazırlık görselinin çizimini verir. Fırlatıcı ailesi, TAC_fnc_rktPrepSteps ile AYNI
    sırayla (ilk eşleşen) bulunur; her aile için tablodaki parça listesi o ailenin hazırlık adımlarıyla birebir
    aynı sıradadır (adım i = parça i). Başlığa özel ek adım gelirse (adet bir fazla) "Başlık fünyesi" parçası
    son adımdan önce eklenir. Adet başka türlü uyuşmazsa görsel gösterilmez.
    Arka bölge (backblast) kontrolü adım değildir: oyuncu kendisi ayarlar.

    KAYNAK DURUMU: M136 AT4, M72, M141 BDM adım sırası FM 3-23.25'ten (2006). Diğer tüm aileler (RPG-7,
    RPG-18/22/26, Panzerfaust, NLAW, SMAW, Carl Gustaf, Javelin, Stinger, Igla, TOW, Metis/Kornet, SPG-9, Titan)
    KAYNAKSIZ, genel bilgiyle yazıldı; resmi kılavuz gelince düzeltilmeli.

    Parça türleri (sade bloklar, kapalı -> açık durum):
        pin   nakliye / emniyet pimi (çıkınca solar)      cover  uç kapağı (kalkar)
        sight nişangah (kalkar)                           lever  horoz / emniyet kolu (kalkar)
        stop  omuz dayanağı (açılır)                      ext    iç tüp (geriye uzanır)
        box   takılan birim: pil, soğutucu, başlık (tüpe oturur)
        light durum ışığı: güç, kilit, soğutma (kırmızı -> yeşil)
        sights AT4'e özel: gez + arpacık (iki şekil, iki etiket)

    Parametreler:
        0: OBJECT - oyuncu birimi

    Dönüş: ARRAY - [anahtar, başlık, sabit şekiller [[alan, renk]], parçalar] ; görsel yoksa []
             parça = [adım no, [şekiller], [[etiket alanı, metin], ...]]
             şekil = [kapalı alan, açık alan, kapalı renk, açık renk]
*/

params [["_unit", objNull, [objNull]]];

if (!TAC_rkt_hint) exitWith {[]};

private _weapon = secondaryWeapon _unit;
if (_weapon isEqualTo "") exitWith {[]};

private _key = [_weapon] call TAC_fnc_wpnSearchKey;

// Aile tablosu: [desenler, baslik, [[tur, etiket, (x)], ...]]  -- rktPrepSteps ile AYNI sira
private _table = [
    [["rpg7", "rpg32", "csla_p27"], "RPG-7", [["cover", "Emniyet kapağı"], ["box", "Başlık"], ["lever", "Horoz"]]],
    [["panzerfaust", "pf60", "pzf44"], "Panzerfaust", [["lever", "Emniyet"], ["sight", "Nişangah"]]],
    [["m141", "bdm"], "M141 BDM", [["pin", "Nakliye pimi"], ["ext", "İç tüp"], ["light", "Tüp kilidi"], ["sight", "Nişangah"], ["cover", "Ateşleme kapağı"]]],
    [["m72"], "M72 LAW", [["pin", "Emniyet pimi"], ["ext", "Tüp"], ["light", "Kilit"], ["sight", "Nişangah"]]],
    [["m136", "at4"], "M136 AT4", [["pin", "Nakliye pimi", 0.60], ["stop", "Omuz dayanağı", 0.30], ["sights", "Gez|Arpacık"], ["lever", "Horoz kolu", 0.78]]],
    [["rpg18", "rpg22", "rpg26", "rpg75"], "RPG-18/22/26", [["pin", "Emniyet pimi"], ["ext", "Tüp"]]],
    [["nlaw", "apilas"], "NLAW / APILAS", [["cover", "Kapaklar"], ["sight", "Nişangah"]]],
    [["smaw", "mk153"], "SMAW", [["light", "Tüp kilidi"], ["lever", "Fünye ayarı"], ["lever", "Horoz"]]],
    [["maaws", "carl", "mraws", "pzf84", "pzf3"], "Carl Gustaf", [["light", "Kama kilidi"], ["lever", "Emniyet / mod"], ["lever", "Horoz"]]],
    [["javelin"], "Javelin", [["box", "BCU"], ["light", "CLU güç"], ["light", "Soğutma"]]],
    [["stinger", "fim92"], "Stinger", [["box", "BCU / soğutucu"], ["light", "Güç"], ["light", "IFF / arayıcı"]]],
    [["igla", "strela", "9k38", "9k32", "9k34", "fim43", "redeye"], "Igla / Strela", [["box", "Pil-soğutma"], ["light", "Güç"], ["light", "Arayıcı"]]],
    [["tow"], "TOW", [["box", "Fırlatma tüpü"], ["box", "Kablo / optik"], ["light", "Gece nişangahı"], ["light", "Güç"]]],
    [["milan", "metis", "eryx", "kornet", "konkurs", "fagot", "spike", "stugna", "mapats", "9k133", "9k113", "9k115", "9k111", "9m133", "9m113"], "ATGM", [["box", "Füze tüpü"], ["box", "Yönlendirme birimi"], ["light", "Güç / soğutma"]]],
    [["spg9", "spg-9", "recoilless"], "SPG-9", [["light", "Namlu kilidi"], ["box", "Mermi / kama"], ["lever", "Emniyet / tetik"]]],
    [["titan", "vorona"], "Titan / Vorona", [["light", "Güç"], ["light", "Arayıcı"]]]
];

private _index = _table findIf {(_x select 0) findIf {(_key find _x) >= 0} >= 0};
if (_index < 0) exitWith {[]};

(_table select _index) params ["_patterns", "_title", "_defs"];

private _mags = secondaryWeaponMagazine _unit;
private _magazine = if (_mags isEqualTo []) then {currentMagazine _unit} else {_mags select 0};
private _stepCount = count ([_weapon, _magazine] call TAC_fnc_rktPrepSteps);
private _n = count _defs;

if (_stepCount != _n && {_stepCount != (_n + 1)}) exitWith {[]};

private _defsAll = +_defs;

if (_stepCount == (_n + 1)) then {
    _defsAll = (_defsAll select [0, _n - 1]) + [["box", "Başlık fünyesi"]] + (_defsAll select [_n - 1, 1]);
};

[format ["%1 - Atışa hazırlık", _title], _defsAll] call TAC_fnc_procHintBuild
