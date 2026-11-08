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
    [["rpg7", "rpg32"], "RPG-7", [["cover", "Emniyet kapağı"], ["box", "Başlık"], ["lever", "Horoz"]]],
    [["panzerfaust", "pf60"], "Panzerfaust", [["lever", "Emniyet"], ["sight", "Nişangah"]]],
    [["m141", "bdm"], "M141 BDM", [["pin", "Nakliye pimi"], ["ext", "İç tüp"], ["light", "Tüp kilidi"], ["sight", "Nişangah"], ["cover", "Ateşleme kapağı"]]],
    [["m72"], "M72 LAW", [["pin", "Emniyet pimi"], ["ext", "Tüp"], ["light", "Kilit"], ["sight", "Nişangah"]]],
    [["m136", "at4"], "M136 AT4", [["pin", "Nakliye pimi", 0.60], ["stop", "Omuz dayanağı", 0.30], ["sights", "Gez|Arpacık"], ["lever", "Horoz kolu", 0.78]]],
    [["rpg18", "rpg22", "rpg26", "rpg75"], "RPG-18/22/26", [["pin", "Emniyet pimi"], ["ext", "Tüp"]]],
    [["nlaw", "apilas"], "NLAW / APILAS", [["cover", "Kapaklar"], ["sight", "Nişangah"]]],
    [["smaw", "mk153"], "SMAW", [["light", "Tüp kilidi"], ["lever", "Fünye ayarı"], ["lever", "Horoz"]]],
    [["maaws", "carl", "mraws"], "Carl Gustaf", [["light", "Kama kilidi"], ["lever", "Emniyet / mod"], ["lever", "Horoz"]]],
    [["javelin"], "Javelin", [["box", "BCU"], ["light", "CLU güç"], ["light", "Soğutma"]]],
    [["stinger", "fim92"], "Stinger", [["box", "BCU / soğutucu"], ["light", "Güç"], ["light", "IFF / arayıcı"]]],
    [["igla", "strela", "9k38", "9k32", "9k34"], "Igla / Strela", [["box", "Pil-soğutma"], ["light", "Güç"], ["light", "Arayıcı"]]],
    [["tow"], "TOW", [["box", "Fırlatma tüpü"], ["box", "Kablo / optik"], ["light", "Gece nişangahı"], ["light", "Güç"]]],
    [["metis", "eryx", "kornet", "konkurs", "fagot", "spike", "stugna", "mapats", "9k133", "9k113", "9k115", "9k111", "9m133", "9m113"], "ATGM", [["box", "Füze tüpü"], ["box", "Yönlendirme birimi"], ["light", "Güç / soğutma"]]],
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

private _total = count _defsAll;

private _fnLabel = {
    params ["_cx", "_above", "_row", "_text"];
    [[_cx - 0.125, [0.71 + (0.05 * _row), 0.21 - (0.05 * _row)] select _above, 0.25, 0.04], _text]
};

private _parts = [];
private _belowCount = 0;
private _aboveCount = 0;

{
    _x params ["_kind", "_text", ["_fixedX", -1]];

    private _step = _forEachIndex;
    private _px = if (_fixedX >= 0) then {_fixedX} else {0.36 + (_forEachIndex * (0.86 / _total))};
    private _shapes = [];
    private _width = 0.05;
    private _above = false;

    switch (_kind) do {
        case "pin": {
            _width = 0.03;
            _shapes = [[[_px, 0.51, 0.03, 0.10], [_px, 0.58, 0.03, 0.10], [0.85, 0.15, 0.15, 1], [0.25, 0.25, 0.25, 0.3]]];
        };
        case "cover": {
            _width = 0.05;
            _shapes = [[[_px, 0.385, 0.05, 0.12], [_px, 0.30, 0.05, 0.05], [0.8, 0.45, 0.15, 1], [0.4, 0.4, 0.4, 0.4]]];
        };
        case "sight": {
            _width = 0.07;
            _above = true;
            _shapes = [[[_px, 0.355, 0.07, 0.025], [_px + 0.02, 0.29, 0.025, 0.09], [0.55, 0.55, 0.55, 1], [0.85, 0.85, 0.85, 1]]];
        };
        case "lever": {
            _width = 0.12;
            _above = true;
            _shapes = [[[_px, 0.355, 0.12, 0.025], [_px, 0.27, 0.03, 0.11], [0.55, 0.5, 0.2, 1], [0.9, 0.7, 0.2, 1]]];
        };
        case "stop": {
            _width = 0.13;
            _shapes = [[[_px, 0.51, 0.13, 0.03], [_px, 0.51, 0.03, 0.18], [0.60, 0.48, 0.2, 1], [0.78, 0.62, 0.25, 1]]];
        };
        case "ext": {
            _px = 0.14;
            _width = 0.30;
            _shapes = [[[0.30, 0.41, 0.30, 0.08], [0.10, 0.41, 0.30, 0.08], [0.45, 0.48, 0.4, 1], [0.55, 0.6, 0.5, 1]]];
        };
        case "box": {
            _width = 0.10;
            _shapes = [[[_px, 0.62, 0.10, 0.07], [_px, 0.51, 0.10, 0.07], [0.35, 0.35, 0.4, 0.35], [0.35, 0.5, 0.7, 1]]];
        };
        case "light": {
            _width = 0.05;
            _above = true;
            _shapes = [[[_px, 0.405, 0.05, 0.05], [_px, 0.405, 0.05, 0.05], [0.75, 0.15, 0.15, 1], [0.2, 0.8, 0.25, 1]]];
        };
        case "sights": {
            _px = 0.34;
            _width = 0.07;
            _above = true;
            _shapes = [
                [[0.34, 0.355, 0.07, 0.025], [0.36, 0.29, 0.025, 0.09], [0.55, 0.55, 0.55, 1], [0.85, 0.85, 0.85, 1]],
                [[1.26, 0.355, 0.07, 0.025], [1.28, 0.29, 0.025, 0.09], [0.55, 0.55, 0.55, 1], [0.85, 0.85, 0.85, 1]]
            ];
        };
    };

    private _row = 0;

    if (_above) then {
        _row = _aboveCount mod 2;
        _aboveCount = _aboveCount + 1;
    } else {
        _row = _belowCount mod 2;
        _belowCount = _belowCount + 1;
    };

    private _labels = [];

    if (_kind isEqualTo "sights") then {
        private _names = _text splitString "|";
        _labels = [
            [0.34 + 0.035, true, 0, _names select 0] call _fnLabel,
            [1.26 + 0.035, true, 0, _names select 1] call _fnLabel
        ];
    } else {
        _labels = [[_px + (_width / 2), _above, _row, _text] call _fnLabel];
    };

    _parts pushBack [_step, _shapes, _labels];
} forEach _defsAll;

[
    format ["%1_%2", _title, _total],
    format ["%1 - Atışa hazırlık", _title],
    [
        [[0.28, 0.38, 1.10, 0.13], [0.34, 0.37, 0.33, 1]],
        [[1.38, 0.40, 0.04, 0.09], [0.22, 0.24, 0.21, 1]]
    ],
    _parts
]
