/*
    Fonksiyon: TAC_fnc_notebookFormatEntry
    Çalışma yeri: İstemci (saf fonksiyon, yan etkisi yok)

    Bir not kaydını okunur metne çevirir:
        "30.10 14:32  |  Grid 123456  |  087°  |  142 m ASL"

    Parametreler:
        0: ARRAY - kayıt [date, posASL, dir]

    Dönüş: STRING
*/

params [["_entry", [], [[]], 3]];

_entry params ["_date", "_posASL", "_dir"];

// Başına sıfır doldurma: [7, 3] -> "007"
private _pad = {
    params ["_value", "_digits"];

    private _text = str _value;
    while {count _text < _digits} do {
        _text = "0" + _text;
    };

    _text
};

private _stamp = format [
    "%1.%2 %3:%4",
    [_date select 2, 2] call _pad,
    [_date select 1, 2] call _pad,
    [_date select 3, 2] call _pad,
    [_date select 4, 2] call _pad
];

private _heading = [(round _dir) mod 360, 3] call _pad;

format [
    "%1  |  Grid %2  |  %3°  |  %4 m ASL",
    _stamp,
    mapGridPosition _posASL,
    _heading,
    round (_posASL select 2)
]
