/*
    Fonksiyon: TAC_fnc_notebookPadSave
    Çalışma yeri: İstemci

    Gelişmiş modda editördeki metni oyuncunun YEREL deposuna (missionNamespace) yazar ve
    başlıktaki karakter sayacını günceller. Her tuş bırakılışında ve kapatırken çağrılır;
    böylece pencere nasıl kapanırsa kapansın yazılan metin kaybolmaz.
    Metin ağa yayınlanmaz: kişiye özel, sunucuya yük yok.

    Sınır ("Maksimum karakter" ayarı) aşılırsa fazlası kesilir.

    Parametreler:
        0: DISPLAY - TAC_NotepadDialog

    Dönüş: yok
*/

params [["_display", displayNull, [displayNull]]];

private _edit = _display displayCtrl 91701;
if (isNull _edit) exitWith {};

private _max = round TAC_notebook_maxChars;
private _text = ctrlText _edit;

if (count _text > _max) then {
    _text = _text select [0, _max];
    _edit ctrlSetText _text;
};

missionNamespace setVariable ["TAC_notebook_text", _text];

private _title = _display displayCtrl 91702;
if (!isNull _title) then {
    _title ctrlSetText format ["  NOT DEFTERİ     %1 / %2", count _text, _max];
};
