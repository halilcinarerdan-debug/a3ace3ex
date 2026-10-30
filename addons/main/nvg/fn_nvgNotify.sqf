/*
    Fonksiyon: TAC_fnc_nvgNotify
    Çalışma yeri: İstemci

    ACE bildirimi gösterir. "Pil bildirimleri" ayarı kapalıysa gösterilmez; hata mesajları
    (pil yok, pil çıkarılamadı) ayardan bağımsız olsun diye _force = true ile çağrılır.

    Parametreler:
        0: STRING - mesaj
        1: BOOL   - (isteğe bağlı) true: ayarı yok say, her zaman göster. Varsayılan: false

    Dönüş: yok
*/

params [["_text", "", [""]], ["_force", false, [false]]];

if (!_force && {!TAC_nvg_notify}) exitWith {};

[_text] call ace_common_fnc_displayTextStructured;
