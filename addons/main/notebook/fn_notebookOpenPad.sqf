/*
    Fonksiyon: TAC_fnc_notebookOpenPad
    Çalışma yeri: İstemci

    Gelişmiş mod: Notepad gibi düz bir metin editörü açar. Oyuncu istediğini yazar;
    metin ESC / KAYDET VE KAPAT ile ve her tuş bırakılışında yerel olarak saklanır,
    pencere her açıldığında kaldığı yerden devam eder.

    Pencere modal diyalog (createDialog) olduğundan yazarken WASD vb. oyunu etkilemez.
    ZAMAN/KONUM EKLE düğmesi, metnin sonuna "[30.10 14:32 | Grid 123456 | 087° | 142 m ASL] "
    satırı ekler (basit moddaki otomatik kaydın aynısı).

    Parametreler: yok
    Dönüş: yok
*/

if (!isNull findDisplay 91700) exitWith {};
if (!createDialog "TAC_NotepadDialog") exitWith {};

private _display = findDisplay 91700;
if (isNull _display) exitWith {};

private _w = 0.5 * safeZoneW;
private _h = 0.75 * safeZoneH;
private _x = safeZoneX + (safeZoneW - _w) / 2;
private _y = safeZoneY + (safeZoneH - _h) / 2;

private _titleH = 0.045;
private _btnH = 0.045;
private _btnW = 0.2;
private _pad = 0.01;

private _background = _display ctrlCreate ["RscText", -1];
_background ctrlSetPosition [_x, _y, _w, _h];
_background ctrlSetBackgroundColor [0.18, 0.18, 0.18, 1];
_background ctrlCommit 0;

private _title = _display ctrlCreate ["RscText", 91702];
_title ctrlSetPosition [_x, _y, _w, _titleH];
_title ctrlSetBackgroundColor [0.12, 0.12, 0.12, 1];
_title ctrlCommit 0;

private _edit = _display ctrlCreate ["TAC_RscNotepadEdit", 91701];
_edit ctrlSetPosition [_x + _pad, _y + _titleH + _pad, _w - 2 * _pad, _h - _titleH - _btnH - 3 * _pad];
_edit ctrlSetText (missionNamespace getVariable ["TAC_notebook_text", ""]);
_edit ctrlCommit 0;

// Tuş bırakılınca kaydet (yapıştırma, silme, yazma - hepsi). Control olayı: [control, key, shift, ctrl, alt]
_edit ctrlAddEventHandler ["KeyUp", {
    [ctrlParent (_this select 0)] call TAC_fnc_notebookPadSave;
}];

private _btnY = _y + _h - _btnH - _pad;

private _stampButton = _display ctrlCreate ["RscButtonMenu", -1];
_stampButton ctrlSetPosition [_x + _pad, _btnY, _btnW, _btnH];
_stampButton ctrlSetText "ZAMAN / KONUM EKLE";
_stampButton ctrlAddEventHandler ["ButtonClick", {
    private _display = ctrlParent (_this select 0);
    private _edit = _display displayCtrl 91701;
    private _text = ctrlText _edit;
    private _newline = toString [10];

    // Yarım satırın ortasına yapışmasın: gerekirse önce satır sonu ekle.
    if (!(_text isEqualTo "") && {(_text select [(count _text) - 1, 1]) != _newline}) then {
        _text = _text + _newline;
    };

    private _entry = [date, getPosASL ACE_player, getDir ACE_player];
    _edit ctrlSetText (_text + format ["[%1] ", [_entry] call TAC_fnc_notebookFormatEntry]);
    ctrlSetFocus _edit;

    [_display] call TAC_fnc_notebookPadSave;
}];
_stampButton ctrlCommit 0;

private _closeButton = _display ctrlCreate ["RscButtonMenu", -1];
_closeButton ctrlSetPosition [_x + _w - _pad - _btnW, _btnY, _btnW, _btnH];
_closeButton ctrlSetText "KAYDET VE KAPAT";
_closeButton ctrlAddEventHandler ["ButtonClick", {
    private _display = ctrlParent (_this select 0);
    [_display] call TAC_fnc_notebookPadSave;
    _display closeDisplay 1;
}];
_closeButton ctrlCommit 0;

// ESC (DIK = 1): kaydet ve kapat. true -> duraklatma menüsü açılmasın.
_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];

    if (_key == 1) exitWith {
        [_display] call TAC_fnc_notebookPadSave;
        _display closeDisplay 2;
        true
    };

    false
}];

// Başlık sayacını doldur ve imleci yazı kutusuna ver.
[_display] call TAC_fnc_notebookPadSave;
ctrlSetFocus _edit;
