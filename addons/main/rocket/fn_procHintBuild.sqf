/*
    Fonksiyon: TAC_fnc_procHintBuild
    Çalışma yeri: İstemci

    Prosedür görseli için parça listesinden çizim üretir (roket ve makineli tüfek ortak kullanır).
    Parçalar ince tüp gövdesi üzerinde eşit aralıkla dizilir; ayrıntı ve parça türleri
    TAC_fnc_rktHintLayout başlığında.

    Parametreler:
        0: STRING - görsel başlığı (tam metin)
        1: ARRAY  - parça tanımları [[tür, etiket, (x)], ...] ; adım i = parça i

    Dönüş: ARRAY - [anahtar, başlık, sabit şekiller, parçalar] (TAC_fnc_procHint biçimi)
*/

params [["_title", "", [""]], ["_defsAll", [], [[]]]];

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
    _title,
    [
        [[0.28, 0.38, 1.10, 0.13], [0.34, 0.37, 0.33, 1]],
        [[1.38, 0.40, 0.04, 0.09], [0.22, 0.24, 0.21, 1]]
    ],
    _parts
]
