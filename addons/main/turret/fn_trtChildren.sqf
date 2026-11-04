/*
    Fonksiyon: TAC_fnc_trtChildren
    Çalışma yeri: İstemci (ACE etkileşim menüsü açılırken)

    Sabit silahın ACE etkileşim menüsü alt öğeleri (gunner, yardımcı ve yakındaki herkes kullanabilir):
      MG      : "Besleme prosedürü" (adımlar silaha özel, ALFABETİK; yalnızca hazır değilse), "Arızayı gider
                (ayrıntılı)" (arızalıysa), "Temizle" (bakım kiti), "Yağla" (silah yağı)
      Güdümlü : "Atış hazırlığı prosedürü" (adımlar fırlatıcıya ve başlığa özel; hazır değilse), "Pili değiştir"
                (yedek pil), "Ateşlenmeyen mühimmatı çıkar" (ateşlenmeme ve bekleme bittiyse)
    Doğru sırayı oyuncu bilmelidir (kalan adımlar alfabetik listelenir).

    Parametreler: ACE insertChildren: [hedef (araç), oyuncu]
    Dönüş: ARRAY - ACE alt öğe listesi
*/

params ["_veh", "_player"];

private _weapon = ((_veh weaponsTurret [0])) param [0, ""];
private _kind = [_weapon] call TAC_fnc_trtKind;

if (_kind isEqualTo "other") exitWith {[]};

private _state = [_veh, _weapon] call TAC_fnc_trtState;
private _actions = [];

private _plain = {
    params ["_id", "_label", "_kind", "_cond"];

    [[
        _id,
        _label,
        "",
        {
            params ["_target", "_player", "_kind"];
            [_player, _target, _kind] call TAC_fnc_trtDo;
        },
        _cond,
        {},
        _kind
    ] call ace_interact_menu_fnc_createAction, [], _veh]
};

private _group = {
    params ["_id", "_title", "_steps", "_progress", "_stepKind"];

    private _list = [];

    {
        if (_forEachIndex >= _progress) then {_list pushBack [_x select 0, _forEachIndex]};
    } forEach _steps;

    _list sort true;

    [[_id, _title, "", {}, {true}, {}, nil] call ace_interact_menu_fnc_createAction, _list apply {
        _x params ["_label", "_index"];

        [[
            format ["%1_%2", _id, _index],
            _label,
            "",
            {
                params ["_target", "_player", "_params"];
                [_player, _target, _params select 0, _params select 1] call TAC_fnc_trtStep;
            },
            {true},
            {},
            [_stepKind, _index]
        ] call ace_interact_menu_fnc_createAction, [], _veh]
    }, _veh]
};

if (_kind isEqualTo "mg") then {
    if (TAC_mg_feedStep && {!(_state select 5)}) then {
        _actions pushBack (["TAC_trt_feed", "Besleme prosedürü", [_weapon] call TAC_fnc_wpnFeedSteps, _state select 10, "feed"] call _group);
    };

    if (_state select 14) then {
        _actions pushBack (["TAC_trt_clearjam", "Arızayı gider (ayrıntılı)", "clearjam", {true}] call _plain);
    };

    _actions pushBack (["TAC_trt_clean", "Silahı temizle", "clean", {[_this select 1, "TAC_WeaponCleaningKit"] call TAC_fnc_wpnHasItem}] call _plain);
    _actions pushBack (["TAC_trt_lube", "Silahı yağla", "lube", {[_this select 1, "TAC_WeaponOil"] call TAC_fnc_wpnHasItem}] call _plain);
} else {
    private _mag = (((_veh magazinesTurret [0])) param [0, ""]);

    if (TAC_rkt_prepare && {!(_state select 5)}) then {
        _actions pushBack (["TAC_trt_prep", "Atış hazırlığı prosedürü", [_weapon, _mag] call TAC_fnc_rktPrepSteps, _state select 10, "rocket"] call _group);
    };

    if (TAC_rkt_guided) then {
        _actions pushBack (["TAC_trt_battery", "Pili değiştir", "battery", {[_this select 1, "TAC_MissileBattery"] call TAC_fnc_wpnHasItem}] call _plain);
    };

    if (_state select 2) then {
        _actions pushBack (["TAC_trt_remove", "Ateşlenmeyen mühimmatı çıkar", "remove", {time >= ([_this select 0, (((_this select 0) weaponsTurret [0])) param [0, ""]] call TAC_fnc_trtState) select 3}] call _plain);
    };
};

_actions
