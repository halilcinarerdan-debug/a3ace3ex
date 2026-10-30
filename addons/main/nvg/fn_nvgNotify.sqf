/*
    Fonksiyon: TAC_fnc_nvgNotify
    Çalışma yeri: İstemci

    "Pil bildirimleri" ayarı açıksa ACE bildirimi gösterir.

    Parametreler:
        0: STRING - mesaj

    Dönüş: yok
*/

params [["_text", "", [""]]];

if (!TAC_nvg_notify) exitWith {};

[_text] call ace_common_fnc_displayTextStructured;
