/*
    Fonksiyon: TAC_fnc_zoomScan
    Çalışma yeri: İstemci (debug konsolu: "Yerel çalıştır"). RHS ve istediğin tüm modlar YÜKLÜYKEN çalıştır.

    Taban sınıf yaması (zoom/CfgWeapons.hpp) yalnızca opticsZoom değerini KENDİ tanımlamayan silahlara
    miras geçer. RHS gibi modlar çoğu silahta kendi değerini tanımlar; bu araç o silahları bulur ve
    yama dosyalarını üretir (Ironsight modunun "config builder"ının eşi):

        [0] call TAC_fnc_zoomScan   -> zoom/overrides.hpp içeriği (class X: Parent { ... };)
        [1] call TAC_fnc_zoomScan   -> zoom/required.hpp içeriği (#define TAC_ZOOM_REQ_ADDONS ...)
        []  call TAC_fnc_zoomScan   -> yalnızca özet (kaç sınıf, hangi modlar)

    Çıktı panoya kopyalanır (Ctrl+V) ve RPT'ye "[TAC][ZOOM-SCAN]" önekiyle satır satır yazılır
    (pano çok uzunsa RPT'den al). Üretilen sınıflar bağımlılık sırasına dizilir; üst sınıfı da
    yamalanan sınıfın tanımı üst sınıftan sonra gelir, yamalanmayan üst sınıflar dışarıdan bildirilir.
    Silah (Rifle/Pistol/Launcher soyundan) ve kendi opticsZoomMin/Max/Init alanı olan her sınıf dahildir
    (scope 0 taban sınıflar da, çünkü değer çoğu zaman orada durur).

    Not: Rifle/Pistol/Launcher/UGL taban sınıfları zaten yamalıdır, taramadan çıkarılır; vanilla
    Rifle_Base_F gibi ara sınıflar kendi değerini taşıyorsa listede çıkar (RHS'in miras aldığı yer).

    Parametreler:
        0: NUMBER - (isteğe bağlı) 0 = overrides.hpp, 1 = required.hpp, verilmezse özet

    Dönüş: STRING - üretilen metin (özet modunda özet)
*/

params [["_mode", -1, [0]]];

// Taban yamanin zaten kapsadigi siniflar.
// _skip: zoom/CfgWeapons.hpp'nin TANIMLADIGI siniflar. _declared: orada ayrica DISARIDAN bildirilen (class X;) siniflar.
private _skip = ["rifle", "pistol", "pistol_base_f", "launcher", "grenadelauncher", "ugl_f"];
private _declared = _skip + ["default", "riflecore", "pistolcore", "launchercore"];
private _all = configFile >> "CfgWeapons";

// [ad, ust sinif adi, config]
private _found = [];

{
    private _cfg = _x;
    private _name = configName _cfg;

    if (
        !((toLower _name) in _skip)
        && {(_name isKindOf ["Rifle", _all]) || {_name isKindOf ["Pistol", _all]} || {_name isKindOf ["Launcher", _all]}}
        && {count (configProperties [_cfg, "(toLower (configName _x)) in ['opticszoommin','opticszoommax','opticszoominit']", false]) > 0}
    ) then {
        _found pushBack [_name, configName (inheritsFrom _cfg), _cfg];
    };
} forEach ("true" configClasses _all);

// --- Bagimlilik sirasi: ust sinif yamalaniyorsa ondan sonra --------------------
private _names = _found apply {toLower (_x select 0)};
private _ordered = [];
private _pending = +_found;

while {count _pending > 0} do {
    private _remaining = _pending apply {toLower (_x select 0)};
    private _ready = _pending select {!((toLower (_x select 1)) in _remaining)};

    // Dongu / cozulemeyen bagimlilik: kalanlari oldugu gibi ekle, sonsuz donguyu onle.
    if (count _ready == 0) then {_ready = +_pending};

    _ordered append _ready;
    _pending = _pending select {!(_x in _ready)};
};

// --- Dis (yamalanmayan) ust siniflar ve gerekli CfgPatches --------------------
private _externals = [];
private _addons = [];

{
    _x params ["_name", "_parent", "_cfg"];

    if (!((toLower _parent) in _names) && {!(_parent in _externals)}) then {
        _externals pushBack _parent;
    };

    _addons append (configSourceAddonList _cfg);
    _addons append (configSourceAddonList (configFile >> "CfgWeapons" >> _parent));
} forEach _ordered;

_addons = (_addons arrayIntersect _addons) select {!((toLower _x) in ["tac_main"])};
_addons sort true;

// --- Metin ---------------------------------------------------------------------
private _lines = [];

if (_mode == 0) then {
    {_lines pushBack format ["class %1;", _x]} forEach (_externals select {!((toLower _x) in _declared)});
    _lines pushBack "";

    {
        _x params ["_name", "_parent"];
        _lines pushBack format ["class %1: %2", _name, _parent];
        _lines pushBack "{";
        _lines pushBack "    opticsZoomMin = TAC_ZOOM_FOV;";
        _lines pushBack "    opticsZoomMax = TAC_ZOOM_FOV;";
        _lines pushBack "    opticsZoomInit = TAC_ZOOM_FOV;";
        _lines pushBack "};";
    } forEach _ordered;
};

if (_mode == 1) then {
    _lines pushBack ("#define TAC_ZOOM_REQ_ADDONS" + (_addons apply {format [", ""%1""", _x]} joinString ""));
};

private _summary = format [
    "TAC zoom taramasi: %1 sinif kendi zoom degerini tanimliyor | %2 dis ust sinif | %3 CfgPatches gerekli%4%5Kullanim: [0] call TAC_fnc_zoomScan -> zoom/overrides.hpp ; [1] call TAC_fnc_zoomScan -> zoom/required.hpp",
    count _ordered,
    count _externals,
    count _addons,
    endl,
    if (_addons isEqualTo []) then {""} else {format ["Modlar: %1%2", _addons joinString ", ", endl]}
];

private _text = if (_mode in [0, 1]) then {_lines joinString endl} else {_summary};

if (_mode in [0, 1]) then {
    copyToClipboard _text;
    {diag_log ("[TAC][ZOOM-SCAN] " + _x)} forEach _lines;
    hint format ["%1%2%2Panoya kopyalandi (%3 satir); RPT'de '[TAC][ZOOM-SCAN]' onekiyle de var.", _summary, endl, count _lines];
} else {
    diag_log ("[TAC][ZOOM-SCAN] " + _summary);
    hint _summary;
};

_text
