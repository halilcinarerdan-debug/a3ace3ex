/*
    Fonksiyon: TAC_fnc_nvgOnVisionMode
    Çalışma yeri: İstemci (CBA "visionMode" oyuncu olayı)

    NVG (görüş modu 1) açıldığında tüketim döngüsünü başlatır; başka bir moda geçilince
    (veya NVG çıkarılınca) durdurur ve efektleri temizler. Pil bitmişse NVG'nin açılmasına
    izin vermez.

    Parametreler:
        0: OBJECT - oyuncu birimi
        1: NUMBER - görüş modu (0 normal, 1 NVG, 2 termal)

    Dönüş: yok
*/

params ["_unit", "_visionMode"];

if (isNull _unit || {!TAC_nvg_enabled}) exitWith {
    call TAC_fnc_nvgStop;
};

if (_visionMode == 1 && {!((hmd _unit) isEqualTo "")}) then {
    private _charge = _unit getVariable ["TAC_nvg_charge", 100];

    // Pil bitmiş: cihaz açılmaz.
    if (_charge <= 0) exitWith {
        _unit action ["NVGogglesOff", _unit];
        ["NVG pili bitmiş. ACE menüsü > NVG Pil Değiştir"] call TAC_fnc_nvgNotify;
    };

    ["NVG pili: " + ((str (round _charge)) + "%")] call TAC_fnc_nvgNotify;
    call TAC_fnc_nvgStart;
} else {
    call TAC_fnc_nvgStop;
};
