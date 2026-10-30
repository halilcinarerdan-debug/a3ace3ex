/*
    Fonksiyon: TAC_fnc_notebookShow
    Çalışma yeri: İstemci

    "Notları Oku" eyleminin gövdesi. Kaydırılabilir bir not defteri penceresi açar
    (yeni kayıt en üstte). KAPAT / ESC ile kapanır, TEMİZLE tüm notları siler.
    Ayrı bir description.ext diyalog tanımı gerektirmez: kontroller ctrlCreate ile kurulur.

    Parametreler: yok
    Dönüş: yok
*/

// Zaten açıksa ikinci pencere açma.
if (!isNull (uiNamespace getVariable ["TAC_notebook_display", displayNull])) exitWith {};

private _mainDisplay = findDisplay 46;
if (isNull _mainDisplay) exitWith {};

// --- İçerik -----------------------------------------------------------------
private _entries = missionNamespace getVariable ["TAC_notebook_entries", []];

private _content = if (_entries isEqualTo []) then {
    "<t color='#9aa0a6'>Kayıtlı not yok.</t>"
} else {
    private _lines = [];
    {
        _lines pushBack format [
            "<t color='#8fbf6a'>#%1</t>  %2",
            _forEachIndex + 1,
            [_x] call TAC_fnc_notebookFormatEntry
        ];
    } forEach _entries;

    reverse _lines;
    _lines joinString "<br/>"
};

// --- Pencere ----------------------------------------------------------------
private _display = _mainDisplay createDisplay "RscDisplayEmpty";
uiNamespace setVariable ["TAC_notebook_display", _display];

private _w = 0.36 * safeZoneW;
private _h = 0.70 * safeZoneH;
private _x = safeZoneX + (safeZoneW - _w) / 2;
private _y = safeZoneY + (safeZoneH - _h) / 2;

private _titleH = 0.05;
private _btnH = 0.045;
private _btnW = 0.16;
private _pad = 0.01;

private _background = _display ctrlCreate ["RscText", -1];
_background ctrlSetPosition [_x, _y, _w, _h];
_background ctrlSetBackgroundColor [0.04, 0.05, 0.04, 0.92];
_background ctrlCommit 0;

private _title = _display ctrlCreate ["RscText", -1];
_title ctrlSetPosition [_x, _y, _w, _titleH];
_title ctrlSetText "  TAKTİK NOT DEFTERİ";
_title ctrlSetBackgroundColor [0.16, 0.22, 0.12, 1];
_title ctrlCommit 0;

// Kaydırılabilir alan
private _groupW = _w - 2 * _pad;
private _groupH = _h - _titleH - _btnH - 3 * _pad;

private _group = _display ctrlCreate ["RscControlsGroup", -1];
_group ctrlSetPosition [_x + _pad, _y + _titleH + _pad, _groupW, _groupH];
_group ctrlCommit 0;

private _text = _display ctrlCreate ["RscStructuredText", -1, _group];
_text ctrlSetStructuredText parseText format ["<t size='1.05'>%1</t>", _content];
_text ctrlSetPosition [0, 0, _groupW - 0.03, 0.1];
_text ctrlCommit 0;
_text ctrlSetPositionH ctrlTextHeight _text;
_text ctrlCommit 0;

// Butonlar
private _btnY = _y + _h - _btnH - _pad;

private _closeButton = _display ctrlCreate ["RscButtonMenu", -1];
_closeButton ctrlSetPosition [_x + _w - _pad - _btnW, _btnY, _btnW, _btnH];
_closeButton ctrlSetText "KAPAT";
_closeButton ctrlAddEventHandler ["ButtonClick", {
    (ctrlParent (_this select 0)) closeDisplay 1;
}];
_closeButton ctrlCommit 0;

private _clearButton = _display ctrlCreate ["RscButtonMenu", -1];
_clearButton ctrlSetPosition [_x + _pad, _btnY, _btnW, _btnH];
_clearButton ctrlSetText "TEMİZLE";
_clearButton ctrlAddEventHandler ["ButtonClick", {
    missionNamespace setVariable ["TAC_notebook_entries", []];
    (ctrlParent (_this select 0)) closeDisplay 2;
    ["Not defteri temizlendi."] call ace_common_fnc_displayTextStructured;
}];
_clearButton ctrlCommit 0;

// ESC (DIK = 1) ile kapat; true döndürerek duraklatma menüsünün açılmasını engelle.
_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];

    if (_key == 1) exitWith {
        _display closeDisplay 2;
        true
    };

    false
}];
