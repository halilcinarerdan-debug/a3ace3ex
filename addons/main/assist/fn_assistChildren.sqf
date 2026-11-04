/*
    Fonksiyon: TAC_fnc_assistChildren
    Çalışma yeri: İstemci (YARDIMCI; ACE menüsü açılırken çağrılır)

    "Silah yardımı" menüsünün alt öğelerini üretir: arkadaşın durumuna göre
      - "MG besleme prosedürü": arkadaşın elinde seçili kayışlı MG var ve besleme hazır değilse
      - "Atış hazırlığı prosedürü": arkadaşın fırlatıcısı yüklü ve hazır değilse
    Adımlar silaha / başlığa özeldir ve alfabetik listelenir (doğru sırayı yardımcı bilmelidir). Arkadaşın
    hazırlık ilerlemesi birimde yayınlanan değişkenlerden okunur (TAC_pub_feed, TAC_pub_rkt).
    Tek başına test için hedef kendin olabilir (test modunda "Silah yardımı (test)" self-menüsü).

    Parametreler: ACE insertChildren: [hedef, oyuncu]
    Dönüş: ARRAY - ACE alt öğe listesi
*/

params ["_target", "_player"];

private _groups = [];

// --- MG besleme ---
private _mg = currentWeapon _target;
private _feed = _target getVariable ["TAC_pub_feed", []];

if (TAC_mg_feedStep && {[_mg] call TAC_fnc_wpnIsBeltFed} && {!(_feed isEqualTo [])} && {(_feed select 0) isEqualTo _mg} && {!(_feed select 1)}) then {
    private _steps = [_mg] call TAC_fnc_wpnFeedSteps;
    private _list = [];

    {
        if (_forEachIndex >= (_feed select 2)) then {_list pushBack [_x select 0, _forEachIndex]};
    } forEach _steps;

    _list sort true;

    _groups pushBack [[
        "TAC_assist_feed",
        "MG besleme prosedürü",
        "",
        {},
        {true},
        {},
        nil
    ] call ace_interact_menu_fnc_createAction, _list apply {
        _x params ["_label", "_index"];

        [[
            format ["TAC_assist_feedStep_%1", _index],
            _label,
            "",
            {
                params ["_target", "_player", "_index"];
                [_player, _target, "feed", _index] call TAC_fnc_assistStep;
            },
            {true},
            {},
            _index
        ] call ace_interact_menu_fnc_createAction, [], _target]
    }, _target];
};

// --- Roketatar hazirlik ---
private _launcher = secondaryWeapon _target;
private _prep = _target getVariable ["TAC_pub_rkt", []];

if (TAC_rkt_prepare && {!(_launcher isEqualTo "")} && {(_target ammo _launcher) > 0} && {!(_prep isEqualTo [])} && {(_prep select 0) isEqualTo _launcher} && {!(_prep select 1)}) then {
    private _mags = secondaryWeaponMagazine _target;
    private _steps = [_launcher, if (_mags isEqualTo []) then {""} else {_mags select 0}] call TAC_fnc_rktPrepSteps;
    private _list = [];

    {
        if (_forEachIndex >= (_prep select 2)) then {_list pushBack [_x select 0, _forEachIndex]};
    } forEach _steps;

    _list sort true;

    _groups pushBack [[
        "TAC_assist_rocket",
        "Atış hazırlığı prosedürü",
        "",
        {},
        {true},
        {},
        nil
    ] call ace_interact_menu_fnc_createAction, _list apply {
        _x params ["_label", "_index"];

        [[
            format ["TAC_assist_rocketStep_%1", _index],
            _label,
            "",
            {
                params ["_target", "_player", "_index"];
                [_player, _target, "rocket", _index] call TAC_fnc_assistStep;
            },
            {true},
            {},
            _index
        ] call ace_interact_menu_fnc_createAction, [], _target]
    }, _target];
};

_groups
