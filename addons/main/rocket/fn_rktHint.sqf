/*
    Fonksiyon: TAC_fnc_rktHint
    Çalışma yeri: İstemci

    Hazırlık görselini gösterir: fırlatıcının yalnızca prosedürde dokunulan parçaları, siyah zeminde sade
    bloklar. Etkileşim YOKTUR: adımlar ACE menüsünden yapılır, bu yalnızca görsel geri bildirimdir.
    Yapılan adımların parçaları "açık" çizilir (pim çıkar, omuz dayanağı açılır, gez ve arpacık kalkar, horoz
    kolu kalkar); hatalı sırada ya da yeniden yüklemede (R) ilerleme sıfırlanınca hepsi "kapalı" görünür.
    Görsel TAC_rkt_hintTime sn sonra hızla (0.2 sn) solar. Boyut ve köşe istemci ayarı (TAC_rkt_hintSize, TAC_rkt_hintCorner). Kontroller (display 46) ilk gösterimde bir kez kurulur.

    Parametreler:
        0: OBJECT - oyuncu birimi (yalnızca ACE_player için gösterilir)

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]]];

if (!hasInterface || {!(_unit isEqualTo ACE_player)}) exitWith {};

private _layout = [_unit] call TAC_fnc_rktHintLayout;
if (_layout isEqualTo []) exitWith {};

private _display = findDisplay 46;
if (isNull _display) exitWith {};

_layout params ["_layoutKey", "_title", "_statics", "_parts"];

// Boyut ve kose (istemci ayari): zemin 1.5 x 0.78 tasarim biriminde, secilen kosede kenar boslugu birakir
private _s = (safeZoneH min (safeZoneW / 1.6)) * (TAC_rkt_hintSize / 100);
private _corner = TAC_rkt_hintCorner;   // 0 sag ust, 1 sol ust, 2 sag alt, 3 sol alt
private _margin = 0.03 * safeZoneH;
private _left = if (_corner in [1, 3]) then {safeZoneX + _margin} else {safeZoneX + safeZoneW - _margin - (1.5 * _s)};
private _top = if (_corner in [0, 1]) then {safeZoneY + _margin} else {safeZoneY + safeZoneH - _margin - (0.78 * _s)};
private _ox = _left - (0.05 * _s);
private _oy = _top - (0.06 * _s);
private _textSize = (_s * 1.6) max 0.45;

private _built = uiNamespace getVariable ["TAC_hint_data", []];
private _geoKey = [_layoutKey, safeZoneW, safeZoneH, _corner, _s];

if (
    _built isEqualTo []
    || {!((_built select 0) isEqualTo _geoKey)}
    || {(_built select 1) findIf {isNull _x} >= 0}
) then {
    {ctrlDelete _x} forEach (if (_built isEqualTo []) then {[]} else {_built select 1});

    private _all = [];

    private _fnRect = {
        params ["_r"];
        [_ox + ((_r select 0) * _s), _oy + ((_r select 1) * _s), (_r select 2) * _s, (_r select 3) * _s]
    };

    private _fnBlock = {
        params ["_rect", "_color"];
        private _c = _display ctrlCreate ["RscText", -1];
        _c ctrlSetPosition ([_rect] call _fnRect);
        _c ctrlSetBackgroundColor _color;
        _c ctrlSetFade 1;
        _c ctrlCommit 0;
        _all pushBack _c;
        _c
    };

    private _fnText = {
        params ["_rect", "_text", "_size"];
        private _c = _display ctrlCreate ["RscStructuredText", -1];
        _c ctrlSetPosition ([_rect] call _fnRect);
        _c ctrlSetStructuredText parseText format ["<t align='center' size='%1' color='#dddddd'>%2</t>", _size * _textSize, _text];
        _c ctrlSetFade 1;
        _c ctrlCommit 0;
        _all pushBack _c;
        _c
    };

    // Siyah zemin
    [[0.05, 0.06, 1.5, 0.78], [0, 0, 0, 0.92]] call _fnBlock;
    [[0.05, 0.065, 1.5, 0.07], _title, 1] call _fnText;

    {
        _x params ["_rect", "_color"];
        [_rect, _color] call _fnBlock;
    } forEach _statics;

    [[1.30, 0.52, 0.25, 0.04], "ÖN", 0.9] call _fnText;

    private _partData = [];

    {
        _x params ["_step", "_shapes", "_labels"];

        private _shapeData = _shapes apply {
            _x params ["_closed", "_open", "_cc", "_oc"];
            private _c = [_closed, _cc] call _fnBlock;
            [_c, [_closed] call _fnRect, [_open] call _fnRect, _cc, _oc]
        };

        {
            _x params ["_rect", "_text"];
            [_rect, _text, 0.9] call _fnText;
        } forEach _labels;

        _partData pushBack [_step, _shapeData];
    } forEach _parts;

    _built = [_geoKey, _all, _partData];
    uiNamespace setVariable ["TAC_hint_data", _built];
};

_built params ["", "_ctrls", "_partData"];

private _weapon = secondaryWeapon _unit;
private _state = [_unit, _weapon] call TAC_fnc_rktGetState;
private _prepared = _state select 5;
private _progress = _state param [10, 0];

{
    _x params ["_step", "_shapeData"];

    private _done = _prepared || {_step < _progress};

    {
        _x params ["_c", "_closed", "_open", "_cc", "_oc"];
        _c ctrlSetPosition ([_closed, _open] select _done);
        _c ctrlSetBackgroundColor ([_cc, _oc] select _done);
    } forEach _shapeData;
} forEach _partData;

// Tum kontroller gorunur; parca konumlari ve renkleri yumusakca gecer (sade: 0.15 sn)
{
    _x ctrlSetFade 0;
    _x ctrlCommit 0.15;
} forEach _ctrls;

private _token = (uiNamespace getVariable ["TAC_hint_token", 0]) + 1;
uiNamespace setVariable ["TAC_hint_token", _token];

[{
    params ["_token"];

    if (_token != (uiNamespace getVariable ["TAC_hint_token", 0])) exitWith {};

    {
        _x ctrlSetFade 1;
        _x ctrlCommit 0.2;
    } forEach ((uiNamespace getVariable ["TAC_hint_data", [0, []]]) select 1);
}, [_token], TAC_rkt_hintTime] call CBA_fnc_waitAndExecute;
